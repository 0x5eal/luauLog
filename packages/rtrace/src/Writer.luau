local Types = require("../../log-core/src/types")
local LOG_SCOPES = require("Enum/Level")

local RtraceWriter = {
	maxLogLevel = LOG_SCOPES["TRACE" :: Types.LogScope],
	flush = true,
}
type RtraceWriterExt = {
	maxLogLevel: number,
}
export type RtraceWriter = Types.Writer<RtraceWriterExt>

function RtraceWriter:writeAll(...): string
	return string.format(...)
end

function RtraceWriter.enabled(self: RtraceWriter, scope: Types.LogScope)
	return LOG_SCOPES[string.upper(scope) :: Types.LogScope] <= self.maxLogLevel
end

return RtraceWriter :: RtraceWriter
