local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestService = require(script.Parent["test-service"])
local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local TestService2 = {}
TestService2.__index = TestService2
TestService2.priority = 1

export type Props = {
	dependencies: {
		TestService: TestService.Self,
	},
}

export type Self = typeof(setmetatable({} :: Props, TestService2))

function TestService2.new()
	local self = setmetatable({}, TestService2)

	self.dependencies = {
		TestService = Loader:getDependency(script.Parent["test-service"]),
	}

	return self
end

function TestService2.OnStart(self: Self)
	print("Received:", self.dependencies.TestService:Hello())
end

return TestService2
