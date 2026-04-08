local Loader = require(script.core.loader)
local Event = require(script.core.event)

export type Loader = Loader.Self
export type Event<T> = Event.Event<T>
require(script.types["loader-events"])

return Loader.new() :: Loader
