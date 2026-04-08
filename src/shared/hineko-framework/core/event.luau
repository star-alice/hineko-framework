local Logger = require(script.Parent.logger)

local Event = {}
Event.__index = Event

export type Props<T> = {
	name: string,
	_listeners: { (T) -> () },
}

export type Self<T> = Props<T> & {
	connect: (self: Self<T>, listener: (T) -> ()) -> (),
	fire: (self: Self<T>, data: T) -> (),
}

function Event.new<T>(name: string): Self<T>
	local self = setmetatable({} :: Props<T>, Event)
	self.name = name
	self._listeners = {}
	return self
end

function Event.connect<T>(self: Self<T>, listener: (T) -> ())
	table.insert(self._listeners, listener)
end

function Event.fire<T>(self: Self<T>, data: T)
	for _, listener in self._listeners do
		local success, err = pcall(listener, data)

		if not success then
			Logger:log(self.name, string.format("Error firing event: %s", err), "error")
		end
	end
end

return Event
