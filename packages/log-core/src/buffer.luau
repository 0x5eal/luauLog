local Events = require("events/exports")
local Types = require("types")

local LogBuffer = {}

export type LogBuffer = typeof(LogBuffer) & {
	truncateLimit: number,
	formatter: Types.Formatter,
	store: { Types.LogMessage },
}

function LogBuffer.append<W>(
	self: LogBuffer,
	writer: Types.Writer<W>,
	options: {
		truncate: boolean,
		scope: Types.LogScope,
		target: string,
	},
	...
)
	if writer:enabled(options.scope) then
		if options.truncate and #self.store >= self.truncateLimit then
			table.remove(self.store, 1)
		end

		table.insert(
			self.store,
			{
				scope = options.scope,
				message = writer:writeAll(...),
				timestamp = os.time(),
				target = options.target,
			} :: Types.LogMessage
		)
	end

	if writer.flush then
		-- TODO: Use formatter provided and write to stdout, then clear buffer
		-- TODO: Fire EVENT_LOG_WRITE on every iteration of write

		for pos, message in self.store do
			local formatted = self.formatter:fmt(message)
			self.store[pos] = nil

			print(formatted)
			Events.EVENT_LOG_WRITE:_fire(nil, message)
		end
	end

	Events.EVENT_LOG_APPEND:_fire(nil, options.scope)
end

return LogBuffer
