local Event = require("event")
export type Event<T...> = Event.Event<T...>

local function metamethodIdx<I, T...>(self: Event<T...>, idx: I)
	if not self._disposed then
		return Event[idx]
	end

	return nil
end

return {
	EVENT_READY = setmetatable(
		{
			id = "ready",
			listeners = {},
			_disposed = false,
		} :: Event<()>,
		{
			__index = metamethodIdx,
		}
	),

	EVENT_REGISTERED = setmetatable(
		{
			id = "registered",
			listeners = {},
			_disposed = false,
		} :: Event<()>,
		{
			__index = metamethodIdx,
		}
	),

	EVENT_LOG_APPEND = setmetatable(
		{
			id = "log",
			listeners = {},
			_disposed = false,
		} :: Event<string>,
		{
			__index = metamethodIdx,
		}
	),

	EVENT_LOG_WRITE = setmetatable(
		{
			id = "log",
			listeners = {},
			_disposed = false,
		} :: Event<{
			scope: "INFO" | "WARN" | "ERROR" | "DEBUG" | "TRACE",
			message: string,
			timestamp: number,
		}>, -- Type inlined to prevent circular dependency
		{
			__index = metamethodIdx,
		}
	),
}
