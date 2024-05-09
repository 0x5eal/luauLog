local Uuid = require("../../vendor/uuid")

--[=[
	@class Event
	@private


]=]
local Event = {}

export type Listener<T...> = {
	registrar: string,
	registerTimestamp: number,
	onDispatch: (registrarId: string, T...) -> (),
}

export type Event<T...> = typeof(Event) & {
	id: string,
	listeners: { Listener<T...> },
	_disposed: boolean,
}

--[=[
	@method listen
	@within Event

	@param handler (registrarId: string, unknown...) -> ()

	@return string
]=]
function Event.listen<T...>(self: Event<T...>, handler: (registrarId: string, T...) -> ())
	local registrarId = Uuid()

	table.insert(
		self.listeners,
		{
			registrar = registrarId,
			registerTimestamp = os.time(),
			onDispatch = handler,
		} :: Listener<T...>
	)

	return registrarId
end

--[=[
	@method _fire
	@within Event

	@param registrarId string
	@param ... ...any

	@return ()
]=]
function Event._fire<T...>(self: Event<T...>, registrarId: string?, ...)
	for _, listener in self.listeners do
		if registrarId and listener.registrar == registrarId then
			listener.onDispatch(listener.registrar, ...)
		elseif not registrarId then
			listener.onDispatch(listener.registrar, ...)
		end
	end
end

return Event
