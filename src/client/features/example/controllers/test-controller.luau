local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared["hineko-framework"])

local TestController = {}
TestController.__index = TestController

export type Self = typeof(setmetatable({}, TestController))

function TestController.new()
	local self = setmetatable({}, TestController)
	return self
end

function TestController:OnInit()
	print("TestController has been initialized!")
end

function TestController:OnTick(deltaTime)
	print("Tick:", deltaTime)
end

function TestController:OnStart()
	print("TestController has started!")
end

Loader:implements(TestController, "OnTick")
return TestController
