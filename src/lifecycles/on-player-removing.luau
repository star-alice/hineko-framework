local Players = game:GetService("Players")

local Loader = require(script.Parent.Parent)

local OnPlayerRemoving = {}
OnPlayerRemoving.__index = OnPlayerRemoving
OnPlayerRemoving.priority = 20

export type Self = typeof(setmetatable({}, OnPlayerRemoving))

function OnPlayerRemoving.new(): Self
	local self = setmetatable({}, OnPlayerRemoving) :: Self
	return self
end

function OnPlayerRemoving:OnInit()
	local onPlayerRemovingCallbacks: { ModuleScript } = {}
	local lifecycleManager = Loader:getLifecycleManager()

	lifecycleManager:onListenerAdded("OnPlayerRemoving", function(module)
		table.insert(onPlayerRemovingCallbacks, module)
	end)

	lifecycleManager:onListenerRemoved("OnPlayerRemoving", function(module)
		local index = table.find(onPlayerRemovingCallbacks, module)
		if index then
			table.remove(onPlayerRemovingCallbacks, index)
		end
	end)

	local function RemovingCallback(player: Player)
		for _, module in onPlayerRemovingCallbacks do
			local playerRemoving = module.OnPlayerRemoving
			if playerRemoving then
				playerRemoving(module, player)
			end
		end
	end

	Players.PlayerRemoving:Connect(RemovingCallback)
end

return OnPlayerRemoving
