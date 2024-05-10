local Types = require("types")
local Events = require("events/exports")
local LogBuffer = require("buffer")

local Implementor = {}
Implementor.Prototype = {}
export type Implementor<W, B> = typeof(Implementor.Prototype) & {
	writer: Types.Writer<W>?,
	formatter: Types.Formatter,
	buffer: LogBuffer.LogBuffer<B>,
}

isRegistered = false
local _registerEventId = Events.EVENT_REGISTERED:listen(function(_: string)
	isRegistered = true
end)
local _unregisterEventId = Events.EVENT_UNREGISTERED:listen(function(_: string)
	isRegistered = false
end)

function Implementor.register<W, B>(
	writer: Types.Writer<W>,
	formatter: Types.Formatter,
	options: {
		truncateLimit: number?,
		existingStore: { Types.LogMessage<B> }?,
	}
)
	if isRegistered then
		error("An implementor has already been registered, unregister that first")
	end

	local buffer = setmetatable({
		truncateLimit = options.truncateLimit or 1000,
		formatter = formatter,
		store = options.existingStore or {},
	}, {
		__index = LogBuffer,
	})

	local impl = setmetatable({
		writer = writer,
		formatter = formatter,
		buffer = buffer,
	}, {
		__index = Implementor.Prototype,
	})

	Events.EVENT_REGISTERED:_fire(nil, impl)
	return impl
end

function Implementor.unregister<W, B>(self: Implementor<W, B>)
	Events.EVENT_UNREGISTERED:_fire(nil, self)
end

function Implementor.Prototype.getImplementorInstance<W, B>(self: Implementor<W, B>)
	return self
end

function Implementor.Prototype.log<W, B>(
	self: Implementor<W, B>,
	target: string,
	scope: Types.LogScope,
	writer: Types.Writer<W>?,
	toTruncate: boolean,
	metadata: B,
	...
)
	self.buffer:append(writer or self.writer, {
		truncate = true,
		scope = scope,
		target = target,
		metadata = metadata,
	}, ...)
end

return Implementor
