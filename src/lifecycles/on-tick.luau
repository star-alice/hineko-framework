local RunService = game:GetService("RunService")

local Loader = require(script.Parent.Parent)

local OnTickLifecycle = {}
OnTickLifecycle.__index = OnTickLifecycle
OnTickLifecycle.priority = 20

export type Self = typeof(setmetatable({}, OnTickLifecycle))

function OnTickLifecycle.new(): Self
	local self = setmetatable({}, OnTickLifecycle) :: Self
	return self
end

function OnTickLifecycle:OnInit()
	local onTickCallbacks: { ModuleScript } = {}
	local lifecycleManager = Loader:getLifecycleManager()

	lifecycleManager:onListenerAdded("OnTick", function(module)
		table.insert(onTickCallbacks, module)
	end)

	lifecycleManager:onListenerRemoved("OnTick", function(module)
		local index = table.find(onTickCallbacks, module)
		if index then
			table.remove(onTickCallbacks, index)
		end
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, module in onTickCallbacks do
			local tick = module.OnTick
			if tick then
				tick(module, deltaTime)
			end
		end
	end)
end

return OnTickLifecycle
