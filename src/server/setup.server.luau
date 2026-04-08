local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HinekoFramework = require(ReplicatedStorage.Shared["hineko-framework"])
local EventTypes = require(ReplicatedStorage.Shared["hineko-framework"].types["loader-events"])

-- stylua: ignore start
local ignitedEvent: HinekoFramework.TEvent<EventTypes.IgnitedResult> = HinekoFramework:getEvent("ignited")
local finishedEvent: HinekoFramework.TEvent<EventTypes.FinishedResult> = HinekoFramework:getEvent("finished")
local moduleErrorEvent: HinekoFramework.TEvent<EventTypes.ModuleErrorResult> = HinekoFramework:getEvent("moduleError")
local moduleLoadedEvent: HinekoFramework.TEvent<EventTypes.ModuleLoadedResult> = HinekoFramework:getEvent("moduleLoaded")
-- stylua: ignore end

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
