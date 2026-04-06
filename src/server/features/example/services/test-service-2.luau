local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestService = require(script.Parent["test-service"])
local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local TestService = {}
TestService.__index = TestService

export type Props = {
	dependencie: {
		TestService: TestService.Self,
	},
}

export type Self = typeof(setmetatable({} :: Props, TestService))

function TestService.new()
	local self = setmetatable({}, TestService)

	return self
end

function TestService.OnStart(self: Self)
	self.dependencie = {
		TestService = Loader:getDependency(script.Parent["test-service"]),
	}

	print("Received:", self.dependencie.TestService:Hello())
end

return TestService
