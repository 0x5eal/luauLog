local Events = require("../../log-core/src/events/exports")
local Implementor = require("../../log-core/src/implementor")
local Methods = require("../../log-core/src/methods")
local Types = require("../../log-core/src/types")
local indexMeta = require("../../log-core/src/events/exports")._indexMeta
local Writer = require("Writer")
local Formatter = require("Formatter")

impl = nil

Events.EVENT_REGISTERED:listen(
	function(_: string, firedImpl: Implementor.Implementor<Writer.RtraceWriter, Formatter.RtraceMetadata>)
		impl = firedImpl
	end
)

currentLog = {}
firstLog = {}

Events.EVENT_LOG_WRITE:listen(function(_: string, logMessage: Types.LogMessage<Formatter.RtraceMetadata>)
	currentLog = logMessage
end)

local EVENT_RTRACE_REGISTERED = setmetatable(
	{
		id = "rtraceReady",
		listeners = {},
		_disposed = false,
	} :: Events.Event<string>,
	{
		__index = indexMeta, -- TODO: Remove usage of private API
	}
)

packageName = nil
EVENT_RTRACE_REGISTERED:listen(function(_: string, firedPackageName: string)
	packageName = firedPackageName
end)

local Logger = {}
export type Logger = typeof(Logger) & {
	isScope: boolean,
}

function constructor(isScope: boolean)
	return setmetatable({
		isScope = isScope,
	}, {
		__index = function(self: Logger, method: "info" | "warn" | "error" | "debug" | "init")
			if method == "info" or method == "warn" or method == "error" or method == "debug" then
				return function(...)
					while impl == nil do
						print("Waiting for Implementor to be registered")
					end

					if packageName == nil then
						print("Package not registered, please call Logger.init first!")
					end

					local implInner: Implementor.Implementor<Writer.RtraceWriter, Formatter.RtraceMetadata> = impl

					local target = debug.info(2, "n")
					local targetWriter: Writer.RtraceWriter = Writer

					if target == "" then
						target = packageName .. ":<anonymous>"
					else
						target = packageName .. ":" .. target
					end

					local metadata: Formatter.RtraceMetadata = {
						isScope = self.isScope,
						lastTimestamp = currentLog.timestamp,
					}

					Methods[string.upper(method)](implInner, target, targetWriter, metadata, ...)
				end
			end

			if method == "init" then
				return function(name: string, maxLogLevel: number)
					local w = Writer
					w.maxLogLevel = maxLogLevel

					EVENT_RTRACE_REGISTERED:_fire(nil, name)
					-- FIXME: Don't cast to any here
					local _impl = Implementor.register(Writer, Formatter :: any, {
						truncateLimit = 1000,
					})
				end
			end

			return nil
		end,
	})
end

return constructor
