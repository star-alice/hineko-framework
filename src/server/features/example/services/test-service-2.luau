local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestService = require(script.Parent["test-service"])
local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local TestService2 = {}
TestService2.__index = TestService2

export type Props = {
	dependencie: {
		TestService: TestService.Self,
	},
}

export type Self = typeof(setmetatable({} :: Props, TestService2))

function TestService2.new()
	local self = setmetatable({}, TestService2)

	return self
end

function TestService2.OnStart(self: Self)
	self.dependencie = {
		TestService = Loader:getDependency(script.Parent["test-service"]),
	}

	print("Received:", self.dependencie.TestService:Hello())
end

return TestService2
