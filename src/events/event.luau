local Uuid = require("../../vendor/uuid")

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
