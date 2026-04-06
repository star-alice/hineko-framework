export type LoggerType = "info" | "warn" | "error"

local Logger = {}

local LOG_BASE_NAME = "Hineko Framework"

function Logger:log(location: string, message: string, type: LoggerType?)
	if not shared.HINEKO_FRAMEWORK_DEBUG then
		return
	end

	local typeFunctions: { [LoggerType]: (string) -> () } = {
		["info"] = print,
		["warn"] = warn,
		["error"] = error,
	}

	local logFunction = typeFunctions[type or ("info" :: LoggerType)] or print
	logFunction(`[${LOG_BASE_NAME}] [${location}]: ${message}`)
end

return Logger
