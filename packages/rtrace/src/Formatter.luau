local Types = require("../../log-core/src/types")
local Writer = require("Writer")

local Formatter = {}
export type RtraceMetadata = {
	isScope: boolean,
	lastTimestamp: number,
}

local DEFAULT_FORMATTING_TMPL = "%s[%s %s] %s"

function Formatter.fmt(self: Types.Formatter, logMessage: Types.LogMessage<RtraceMetadata>): string
	if logMessage.metadata.isScope then
		return Writer:writeAll(
			DEFAULT_FORMATTING_TMPL,
			"   " .. logMessage.timestamp - logMessage.metadata.lastTimestamp .. "s ",
			logMessage.scope,
			logMessage.target,
			logMessage.message
		)
	end

	return Writer:writeAll(DEFAULT_FORMATTING_TMPL, "", logMessage.scope, logMessage.target, logMessage.message)
end

return Formatter
