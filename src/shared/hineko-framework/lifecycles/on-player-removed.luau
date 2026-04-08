local Players = game:GetService("Players")

local Loader = require(script.Parent.Parent)

local OnPlayerRemoved = {}
OnPlayerRemoved.__index = OnPlayerRemoved
OnPlayerRemoved.priority = 20

export type Self = typeof(setmetatable({}, OnPlayerRemoved))

function OnPlayerRemoved.new(): Self
	local self = setmetatable({}, OnPlayerRemoved) :: Self
	return self
end

function OnPlayerRemoved:OnInit()
	local onPlayerRemovedCallbacks: { ModuleScript } = {}
	local lifecycleManager = Loader:getLifecycleManager()

	lifecycleManager:onListenerAdded("OnPlayerRemoved", function(module)
		table.insert(onPlayerRemovedCallbacks, module)
	end)

	lifecycleManager:onListenerRemoved("OnPlayerRemoved", function(module)
		local index = table.find(onPlayerRemovedCallbacks, module)
		if index then
			table.remove(onPlayerRemovedCallbacks, index)
		end
	end)

	local function RemovedCallback(player: Player)
		for _, module in onPlayerRemovedCallbacks do
			local playerRemoved = module.OnPlayerRemoved
			if playerRemoved then
				playerRemoved(module, player)
			end
		end
	end

	Players.PlayerRemoving:Connect(RemovedCallback)
end

return OnPlayerRemoved
