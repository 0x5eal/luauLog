local Event = require("event")
export type Event<T...> = Event.Event<T...>

local Types = require("../types")

local function indexMeta<I, T...>(self: Event<T...>, idx: I)
	if not self._disposed then
		return Event[idx]
	end

	return nil
end

return {
	_indexMeta = indexMeta,
	EVENT_READY = setmetatable(
		{
			id = "ready",
			listeners = {},
			_disposed = false,
		} :: Event<()>,
		{
			__index = indexMeta,
		}
	),

	EVENT_REGISTERED = setmetatable(
		{
			id = "registered",
			listeners = {},
			_disposed = false,
		} :: Event<any>, -- FIXME: To prevent circular dependency
		{
			__index = indexMeta,
		}
	),

	EVENT_UNREGISTERED = setmetatable(
		{
			id = "unregistered",
			listeners = {},
			_disposed = false,
		} :: Event<any>, -- FIXME: To prevent circular dependency
		{
			__index = indexMeta,
		}
	),

	EVENT_LOG_APPEND = setmetatable(
		{
			id = "logAppend",
			listeners = {},
			_disposed = false,
		} :: Event<Types.LogMessage<any>>,
		{
			__index = indexMeta,
		}
	),

	EVENT_LOG_WRITE = setmetatable(
		{
			id = "logWrite",
			listeners = {},
			_disposed = false,
		} :: Event<Types.LogMessage<any>>,
		{
			__index = indexMeta,
		}
	),
}
