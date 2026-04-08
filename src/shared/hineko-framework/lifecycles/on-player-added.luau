local Players = game:GetService("Players")

local Loader = require(script.Parent.Parent)

local OnPlayerAdded = {}
OnPlayerAdded.__index = OnPlayerAdded
OnPlayerAdded.priority = 20

export type Self = typeof(setmetatable({}, OnPlayerAdded))

function OnPlayerAdded.new(): Self
	local self = setmetatable({}, OnPlayerAdded) :: Self
	return self
end

function OnPlayerAdded:OnInit()
	local onPlayerAddedCallbacks: { ModuleScript } = {}
	local lifecycleManager = Loader:getLifecycleManager()

	lifecycleManager:onListenerAdded("OnPlayerAdded", function(module)
		table.insert(onPlayerAddedCallbacks, module)
	end)

	lifecycleManager:onListenerRemoved("OnPlayerAdded", function(module)
		local index = table.find(onPlayerAddedCallbacks, module)
		if index then
			table.remove(onPlayerAddedCallbacks, index)
		end
	end)

	local function AddedCallback(player: Player)
		for _, module in onPlayerAddedCallbacks do
			local playerAdded = module.OnPlayerAdded
			if playerAdded then
				playerAdded(module, player)
			end
		end
	end

	Players.PlayerAdded:Connect(AddedCallback)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			AddedCallback(player)
		end)
	end
end

return OnPlayerAdded
