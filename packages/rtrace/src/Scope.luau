-- Scopes are initialized within blocks, and are used to time different
-- operations between logs, scopes are a wrapped function provided to rtrace,
-- which we pcall and benchmark
local Types = require("../../log-core/src/types")
local Events = require("../../log-core/src/events/exports")
local Logger = require("Logger")
local Formatter = require("Formatter")

firstLog = {}
Events.EVENT_LOG_WRITE:listen(function(registrarId: string, logMessage: Types.LogMessage<Formatter.RtraceMetadata>)
	firstLog = logMessage

	for idx, listener in Events.EVENT_LOG_WRITE.listeners do
		if listener.registrar == registrarId then
			table.remove(Events.EVENT_LOG_WRITE, idx)
		end
	end
end)

local Scope = {}

function Scope.enter<T>(level: Types.LogScope, scopeName: string, fn: (logger: Logger.Logger) -> T): T
	local logger = Logger(true)
	local ok, ret = pcall(fn, logger)

	if not ok then
		logger.error(ret)

		if level == "TRACE" then
			logger.trace(debug.traceback())
		end
	end

	-- TODO: Print total time
	logger = Logger(false)

	return ret
end

return Scope
