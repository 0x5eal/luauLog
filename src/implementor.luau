local Types = require("types")
local Events = require("events/exports")
local LogBuffer = require("buffer")

local Implementor = {}
Implementor.Prototype = {}
export type Implementor = typeof(Implementor) & {
	writer: Types.Writer?,
	formatter: Types.Formatter,
	buffer: LogBuffer.LogBuffer,
}

function Implementor.register(
	writer: Types.Writer?,
	formatter: Types.Formatter,
	options: {
		truncateLimit: number?,
		existingStore: { Types.LogMessage }?,
	}
)
    Events.EVENT_REGISTERED:_fire()

	local buffer = setmetatable({
		truncateLimit = options.truncateLimit or 1000,
		store = options.existingStore or {},
	}, {
		__index = LogBuffer,
	})

	return setmetatable(
		{
			writer = writer,
			formatter = formatter,
			buffer = buffer,
		} :: Implementor,
		{
			__index = Implementor.Prototype,
		}
	)
end

function Implementor.Prototype.getImplementorInstance(self: Implementor)
	return self
end

function Implementor.Prototype.log(self: Implementor, scope: Types.LogScope, writer, toTruncate: boolean, ...)
	writer = writer or self.writer
	self.buffer:append(writer, {
		truncate = true,
		scope = scope,
	})
end
