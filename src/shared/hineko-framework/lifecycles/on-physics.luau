local RunService = game:GetService("RunService")

local Loader = require(script.Parent.Parent)

local OnPhysicsLifecycle = {}
OnPhysicsLifecycle.__index = OnPhysicsLifecycle
OnPhysicsLifecycle.priority = 20

export type Self = typeof(setmetatable({}, OnPhysicsLifecycle))

function OnPhysicsLifecycle.new(): Self
	local self = setmetatable({}, OnPhysicsLifecycle) :: Self
	return self
end

function OnPhysicsLifecycle:OnInit()
	local onPhysicsCallbacks: { ModuleScript } = {}
	local lifecycleManager = Loader:getLifecycleManager()

	lifecycleManager:onListenerAdded("OnPhysics", function(module)
		table.insert(onPhysicsCallbacks, module)
	end)

	lifecycleManager:onListenerRemoved("OnPhysics", function(module)
		local index = table.find(onPhysicsCallbacks, module)
		if index then
			table.remove(onPhysicsCallbacks, index)
		end
	end)

	RunService.Stepped:Connect(function(deltaTime)
		for _, module in onPhysicsCallbacks do
			local physics = module.OnPhysics
			if physics then
				physics(module, deltaTime)
			end
		end
	end)
end

return OnPhysicsLifecycle
