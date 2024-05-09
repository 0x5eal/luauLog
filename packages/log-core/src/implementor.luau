local Types = require("types")
local Events = require("events/exports")
local LogBuffer = require("buffer")

--[=[
	@class Implementor


]=]
local Implementor = {}

Implementor.Prototype = {}

export type Implementor<W> = typeof(Implementor.Prototype) & {
	writer: Types.Writer<W>?,
	formatter: Types.Formatter,
	buffer: LogBuffer.LogBuffer,
}

isRegistered = false
local _registerEventId = Events.EVENT_REGISTERED:listen(function(_: string)
	isRegistered = true
end)
local _unregisterEventId = Events.EVENT_UNREGISTERED:listen(function(_: string)
	isRegistered = false
end)

--[=[
	@function register
	@within Implementor

	@param writer Writer
	@param formatter Formatter
	@param options { truncateLimite: number?, existingStore: { LogMessage? }? }?

	@return Implementor
]=]
function Implementor.register<T>(
	writer: Types.Writer<T>,
	formatter: Types.Formatter,
	options: {
		truncateLimit: number?,
		existingStore: { Types.LogMessage }?,
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

--[=[
	@method unregister
	@within Implementor

	@return ()
]=]
function Implementor.unregister<W>(self: Implementor<W>)
	Events.EVENT_UNREGISTERED:_fire(nil, self)
end

--[=[
	@method getImplementorInstance
	@within Implementor

	@return Implementor
]=]
function Implementor.Prototype.getImplementorInstance<W>(self: Implementor<W>)
	return self
end

--[=[
	@method log
	@within Implementor

	@param target string
	@param scope LogScope
	@param writer Writer
	@param toTruncate boolean

	@return Implementor
]=]
function Implementor.Prototype.log<W>(
	self: Implementor<W>,
	target: string,
	scope: Types.LogScope,
	writer: Types.Writer<W>?,
	toTruncate: boolean,
	...
)
	self.buffer:append(writer or self.writer, {
		truncate = true,
		scope = scope,
		target = target,
	}, ...)
end

return Implementor
