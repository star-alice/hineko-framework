--!optimize 2
local Logger = require(script.Parent.logger)
local Event = require(script.Parent.event)
local LoaderEventTypes = require(script.Parent.Parent.types["loader-events"])
local LifecycleManager = require(script.Parent["lifecycle-manager"])
local Messages = require(script.Parent.Parent.constants.messages)

type Event<T> = Event.Event<T>

local Loader = {}
Loader.__index = Loader

type Props<EventType, TClass> = {
	_lifecycleManager: LifecycleManager.Self,
	_paths: { Folder },
	_events: { [string]: Event<EventType> },
	_ignited: boolean,
	_singletons: { [ModuleScript]: TClass },
}

export type Self = typeof(setmetatable({}, Loader))

function Loader.new<EventType, TClass>()
	local self = setmetatable({} :: Props<EventType, TClass>, Loader) :: Self

	self._paths = {}
	self._ignited = false
	self._lifecycleManager = LifecycleManager.new()
	self._singletons = {}
	self._events = {
		ignited = Event.new("Ignited") :: Event<LoaderEventTypes.IgnitedResult>,
		moduleLoaded = Event.new("ModuleLoaded") :: Event<LoaderEventTypes.ModuleLoadedResult>,
		moduleError = Event.new("ModuleError") :: Event<LoaderEventTypes.ModuleErrorResult>,
		finished = Event.new("Finished") :: Event<LoaderEventTypes.IgnitedResult>,
	} :: { [LoaderEventTypes.Names]: Event<EventType> }

	return self
end

-- - - Public functions
--[[
    Ignites the loader, allowing it to start loading modules. This should be called after all paths have been added and before any modules are required.
]]
function Loader.ignite(self: Self)
	assert(not self._ignited, Messages.ERROR.ALREADY_IGNITED)

	-- Starting module loading
	self:_loadModulesFromPath(script.Parent.Parent.lifecycles)
	self._ignited = true
	self._events.ignited:fire()

	Logger:log("Loader", "Loader ignited. Starting to load modules...")
	self:_loadAllModules()

	-- Running OnStart
	for module, class in self._singletons do
		local onStart = class.OnStart

		if not onStart or type(onStart) ~= "function" then
			continue
		end

		local success, err = pcall(onStart, class)

		if not success then
			Logger:log("Loader", `Cannot run OnStart of module {module.Name}: {err}`, "error")
			continue
		end

		Logger:log("Loader", `OnStart of {module.Name} runned with success!`)
	end

	self._events.finished:fire()
	Logger:log("Loader", "All modules loaded and started!")
end

function Loader.debugMode(self: Self, state: boolean)
	shared.HINEKO_FRAMEWORK_DEBUG = state
	Logger:log("Loader", "Debug mode activated! Additional debug information will be logged.")
end

function Loader.isIgnited(self: Self): boolean
	return self._ignited
end

function Loader.getEvent<T>(self: Self, eventName: LoaderEventTypes.Names): Event<T>?
	return self._events[eventName]
end

function Loader.getLifecycleManager(self: Self): LifecycleManager.Self
	return self._lifecycleManager
end

function Loader.getDependency<T>(self: Self, module: ModuleScript): T?
	assert(self._ignited, Messages.ERROR.NOT_IGNITED)
	assert(self._singletons[module], Messages.ERROR.MODULE_NOT_FOUND(module.Name))
	return self._singletons[module]
end

function Loader.getModuleByClass<T>(self: Self, class: T): ModuleScript?
	assert(self._ignited, Messages.ERROR.NOT_IGNITED)

	for module, moduleClass in self._singletons do
		if moduleClass == class then
			return module
		end
	end

	return nil
end

--[[
    Adds a folder to the loader's paths. The loader will search these folders for modules to load. This should be called before ignition.
]]
function Loader:addPath(folder: Folder)
	assert(not self._ignited, Messages.ERROR.NOT_IGNITED)
	assert(folder:IsA("Folder"), Messages.ERROR.INVALID_PATH)

	table.insert(self._paths, folder)
	Logger:log("Loader", `Added new path: {folder.Name} at {folder:GetFullName()}`)
end

--[[
    Works like when you implements the any interface, but it's used for lifecycles.
    Can be called at module definition time (before ignition) to declare which lifecycles a class uses.
    The loader will automatically register the lifecycles after the module is instantiated.
    @param class The class table to mark with lifecycle declarations
    @param ... Lifecycle names to register (e.g. "OnPlayerAdded", "OnPlayerRemoved")
]]
function Loader.implements<T>(
	self: Self,
	class: { __lifecycles: { string } },
	... -- Lifecycles to register the module
)
	if not class.__lifecycles then
		class.__lifecycles = {}
	end

	for _, lifecycle in { ... } do
		table.insert(class.__lifecycles, lifecycle)
	end
end

--[[
    Unloads a module from the loader. This will remove the module from the loader's registry and fire any necessary cleanup callbacks on lifecycles. Use this if you want to reload a module later or if you want to remove it from the game.
]]
function Loader:unload(module: ModuleScript)
	assert(self._ignited, Messages.ERROR.NOT_IGNITED)
	assert(self._singletons[module], Messages.ERROR.MODULE_NOT_FOUND(module.Name))

	self._singletons[module] = nil
	Logger:log("Loader", `Module '{module.Name}' has been unloaded.`)

	local __listeners = self._singletons[module] and self._singletons[module].__listeners or {}

	for lifecycle, _ in __listeners do
		self._lifecycleManager:_remove(lifecycle, module)
	end
end

-- - - Private functions
function Loader._loadModule(self: Self, module: ModuleScript)
	assert(module.Parent and module.Parent:IsA("Folder"), Messages.ERROR.INVALID_PATH)

	local success, result = pcall(require, module)

	if not success then
		Logger:log("Loader", `Failed to load module '{module.Name}': {result}`, "error")
		self._events.moduleError:fire({ name = module.Name, error = result })
		return
	end

	-- Try to run the OnInit callback inside the module if it exists
	local class = result.new()
	local initCallback = class.OnInit

	if initCallback and type(initCallback) == "function" then
		local initSuccess, initError = pcall(initCallback, class)

		if not initSuccess then
			Logger:log("Loader", `Initialization failed for module '{module.Name}': {initError}`, "error")
			self._events.moduleError:fire({ name = module.Name, error = initError })
			return
		end
	end

	self._singletons[module] = class

	-- Auto-register lifecycles declared via :implements() at module definition time
	if result.__lifecycles then
		if not class.__listeners then
			class.__listeners = {}
		end

		for _, lifecycle in result.__lifecycles do
			class.__listeners[lifecycle] = true
			self._lifecycleManager:_add(lifecycle, class)
		end
	end

	self._events.moduleLoaded:fire({ name = module.Name, module = result })
end

function Loader._loadModulesFromPath(self: Self, path: Folder)
	for _, item in path:GetChildren() do
		if item:IsA("ModuleScript") then
			self:_loadModule(item)
		elseif item:IsA("Folder") then
			self:_loadModulesFromPath(item)
		end
	end
end

function Loader._loadAllModules(self: Self)
	for _, path in self._paths do
		self:_loadModulesFromPath(path)
	end
end

return Loader
