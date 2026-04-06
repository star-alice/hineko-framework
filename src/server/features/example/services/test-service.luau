local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local TestService = {}
TestService.__index = TestService

export type Self = typeof(setmetatable({}, TestService))

function TestService.new()
	local self = setmetatable({}, TestService)

	return self
end

function TestService:OnPlayerAdded(player)
	print("Player added:", player.Name)
end

function TestService:OnPlayerRemoved(player)
	print("Player removed:", player.Name)
end

function TestService:Hello()
	return "Hello from TestService in TestService2!"
end

function TestService:OnInit()
	print("TestService has been initialized!")
end

function TestService:OnStart()
	print("TestService has started!")
end

Loader:implements(TestService, "OnPlayerAdded", "OnPlayerRemoved")
return TestService
