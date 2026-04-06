local Logger = require(script.Parent.logger)

local Event = {}
Event.__index = Event

export type Event<T> = {
    name: string,
    _listeners: { (T) -> () },
    connect: (self: Event<T>, listener: (T) -> ()) -> (),
    fire: (self: Event<T>, data: T) -> (),
}

function Event.new<T>(name: string): Event<T>
    local self = setmetatable({} :: any, Event)
    self.name = name
    self._listeners = {}
    return self
end

function Event.connect<T>(self: Event<T>, listener: (T) -> ())
    table.insert(self._listeners, listener)
end

function Event.fire<T>(self: Event<T>, data: T)
    for _, listener in self._listeners do
        local success, err = pcall(listener, data)

        if not success then
            Logger:log(self.name, string.format("Error firing event: %s", err), "error")
        end
    end
end

return Event