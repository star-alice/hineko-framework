local RunService = game:GetService("RunService")

local Loader = require(script.Parent.Parent)

local OnRenderLifecycle = {}
OnRenderLifecycle.__index = OnRenderLifecycle
OnRenderLifecycle.priority = 20

export type Self = typeof(setmetatable({}, OnRenderLifecycle))

function OnRenderLifecycle.new(): Self
	local self = setmetatable({}, OnRenderLifecycle) :: Self
	return self
end

function OnRenderLifecycle:OnInit()
	if RunService:IsServer() then
		return
	end

	local onRenderCallbacks: { ModuleScript } = {}
	local lifecycleManager = Loader:getLifecycleManager()

	lifecycleManager:onListenerAdded("OnRender", function(module)
		table.insert(onRenderCallbacks, module)
	end)

	lifecycleManager:onListenerRemoved("OnRender", function(module)
		local index = table.find(onRenderCallbacks, module)
		if index then
			table.remove(onRenderCallbacks, index)
		end
	end)

	RunService.RenderStepped:Connect(function(deltaTime)
		for _, module in onRenderCallbacks do
			local render = module.OnRender
			if render then
				render(module, deltaTime)
			end
		end
	end)
end

return OnRenderLifecycle
