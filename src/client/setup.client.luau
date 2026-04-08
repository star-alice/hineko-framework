local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HinekoFramework = require(ReplicatedStorage.Shared["hineko-framework"])

HinekoFramework:debugMode(true)
HinekoFramework:addPath(ReplicatedStorage.Shared["example-lifecycles"])
HinekoFramework:addPath(script.Parent.features)
HinekoFramework:ignite()
