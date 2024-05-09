local Event = require("event")
export type Event<T...> = Event.Event<T...>

local Types = require("../types")

local function indexMeta<I, T...>(self: Event<T...>, idx: I)
	if not self._disposed then
		return Event[idx]
	end

	return nil
end

--[=[
	@class Exports
	@private


]=]
return {
	_indexMeta = indexMeta,

	--[=[
		@prop EVENT_READY Event
		@within Exports
	]=]

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

	--[=[
		@prop EVENT_REGISTERED Event
		@within Exports
	]=]

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

	--[=[
		@prop EVENT_UNREGISTERED Event
		@within Exports
	]=]

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

	--[=[
		@prop EVENT_LOG_APPEND Event
		@within Exports
	]=]

	EVENT_LOG_APPEND = setmetatable(
		{
			id = "logAppend",
			listeners = {},
			_disposed = false,
		} :: Event<Types.LogMessage>,
		{
			__index = indexMeta,
		}
	),

	--[=[
		@prop EVENT_LOG_WRITE Event
		@within Exports
	]=]

	EVENT_LOG_WRITE = setmetatable(
		{
			id = "logWrite",
			listeners = {},
			_disposed = false,
		} :: Event<Types.LogMessage>,
		{
			__index = indexMeta,
		}
	),
}
