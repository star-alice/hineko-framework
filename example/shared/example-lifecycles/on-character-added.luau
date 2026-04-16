local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local OnCharacterAddedLifecycle = {}
OnCharacterAddedLifecycle.__index = OnCharacterAddedLifecycle
OnCharacterAddedLifecycle.priority = 20

function OnCharacterAddedLifecycle.new()
	local self = setmetatable({}, OnCharacterAddedLifecycle)
	return self
end

function OnCharacterAddedLifecycle:OnInit()
	local LocalPlayer = Players.LocalPlayer
	local lifecycleManager = Loader:getLifecycleManager()
	local listeners = {}

	lifecycleManager:onListenerAdded("OnCharacterAdded", function(module)
		table.insert(listeners, module)
	end)

	lifecycleManager:onListenerRemoved("OnCharacterAdded", function(module)
		local index = table.find(listeners, module)
		if index then
			table.remove(listeners, index)
		end
	end)

	local function onCharacterAdded(character)
		for _, module in listeners do
			local callback = module.OnCharacterAdded
			if callback then
				callback(module, character)
			end
		end
	end

	LocalPlayer.CharacterAdded:Connect(function(character: Model)
		onCharacterAdded(character)
	end)

	if LocalPlayer.Character then
		onCharacterAdded(LocalPlayer.Character)
	end
end

return OnCharacterAddedLifecycle
