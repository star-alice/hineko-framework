local LifecycleManager = {}
LifecycleManager.__index = LifecycleManager

export type Props = {
	_eventsCallbacks: {
		[string]: {
			onAdded: (any) -> ()?,
			onRemoved: (any) -> ()?,
		},
	},
}
export type Self = typeof(setmetatable({}, LifecycleManager))

function LifecycleManager.new(): Self
	local self = setmetatable({}, LifecycleManager) :: Self
	self._eventsCallbacks = {}
	return self
end

-- - - Public functions
--[[
	Registers a callback to be called when a module implements a specific lifecycle. The callback will be called with the module's class as an argument.

	@param event The lifecycle event to listen for
	@param callback The function to call when the event is triggered. This function should accept one argument, which will be the module's class.
]]
function LifecycleManager.onListenerAdded<T>(self: Self, event: string, callback: T)
	assert(type(callback) == "function", "Callback must be a function.")

	if not self._eventsCallbacks[event] then
		self._eventsCallbacks[event] = {}
	end

	self._eventsCallbacks[event].onAdded = callback
end

--[[
	Registers a callback to be called when a module is removed from a specific lifecycle. The callback will be called with the module's class as an argument.

	@param event The lifecycle event to listen for removal
	@param callback The function to call when the event is triggered. This function should accept one argument, which will be the module's class.
]]
function LifecycleManager.onListenerRemoved<T>(self: Self, event: string, callback: T)
	assert(type(callback) == "function", "Callback must be a function.")

	if not self._eventsCallbacks[event] then
		self._eventsCallbacks[event] = {}
	end

	self._eventsCallbacks[event].onRemoved = callback
end

-- - - Private functions
function LifecycleManager._remove<T>(self: Self, event: string, removed: T)
	local callbacks = self._eventsCallbacks[event]
	if not callbacks then
		return
	end

	if not callbacks.onRemoved then
		return
	end

	callbacks.onRemoved(removed)
end

function LifecycleManager._add<T>(self: Self, event: string, added: T)
	local callbacks = self._eventsCallbacks[event]
	if not callbacks then
		return
	end

	if not callbacks.onAdded then
		return
	end

	callbacks.onAdded(added)
end

return LifecycleManager
