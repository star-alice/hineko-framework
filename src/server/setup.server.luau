local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HinekoFramework = require(ReplicatedStorage.Shared["hineko-framework"])

local ignitedEvent = HinekoFramework:getEvent("ignited")
local finishedEvent = HinekoFramework:getEvent("finished")
local moduleErrorEvent = HinekoFramework:getEvent("moduleError")
local moduleLoadedEvent = HinekoFramework:getEvent("moduleLoaded")

ignitedEvent:connect(function()
	print("HinekoFramework has ignited!")
end)

finishedEvent:connect(function()
	print("HinekoFramework has finished loading all modules!")
end)

moduleErrorEvent:connect(function(data)
	warn(`Error loading module '{data.name}': {data.error}`)
end)

moduleLoadedEvent:connect(function(data)
	print(`Module loaded - {data.name}: {data.module}`)
end)

HinekoFramework:debugMode(true)
HinekoFramework:addPath(script.Parent.features)
HinekoFramework:ignite()
