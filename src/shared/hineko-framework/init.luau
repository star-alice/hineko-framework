local Loader = require(script.core.loader)
local Event = require(script.core.event)

export type TLoader = Loader.Self
export type TEvent<T> = Event.Event<T>
require(script.types["loader-events"])

return Loader.new() :: TLoader
