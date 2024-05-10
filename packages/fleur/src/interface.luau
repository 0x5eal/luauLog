local Serde = require("@lune/serde")
local Fs = require("@lune/fs")

local Events = require("../../log-core/src/events/exports")
local ConfigBuilder = require("builder/config")
local Implementor = require("../../log-core/src/implementor")
local Methods = require("../../log-core/src/methods")
local Ansi = require("ansi")
local Types = require("../../log-core/src/types")
local Writer = require("writer")

local DEFAULT_ENABLED_FN = Writer.enabled

impl = nil
targetLevelMap = nil
filterPredicate = nil
packageName = ""
logFilename = nil
logFiletype = ""

Events.EVENT_REGISTERED:listen(function(_: string, firedImpl: Implementor.Implementor<Writer.FleurWriter, {}>)
	impl = firedImpl
end)

ConfigBuilder.EVENT_FLEUR_REGISTER:listen(function(_: string, firedConfigBuilder: ConfigBuilder.ConfigBuilder)
	targetLevelMap = firedConfigBuilder.levels
	targetLevelMap.all = nil

	filterPredicate = firedConfigBuilder.filterPredicate
	packageName = firedConfigBuilder.package
	logFilename = firedConfigBuilder.logFilename
	logFiletype = firedConfigBuilder.logFiletype
end)

Events.EVENT_LOG_WRITE:listen(function(_: string, logMessage: Types.LogMessage<{}>)
	if logFilename == nil then
		return
	end

	local implInner = impl :: Implementor.Implementor<Writer.FleurWriter, {}>

	if logFiletype == "plaintext" then
		local formatted = Ansi.normalize(implInner.formatter:fmt(logMessage) .. "\n")

		if not Fs.isFile(logFilename) then
			Fs.writeFile(logFilename, formatted)
		else
			Fs.writeFile(logFilename, Fs.readFile(logFilename) .. formatted)
		end
	end

	if logFiletype == "json" then
		for idx, field in logMessage do
			-- Remove any ANSI escape sequences
			if typeof(field) == "string" then
				logMessage[idx] = Ansi.normalize(field)
			end
		end

		if not Fs.isFile(logFilename) then
			Fs.writeFile(
				logFilename,
				Serde.encode("json", {
					[1] = logMessage,
				}, true)
			)
		else
			local newLog: { Types.LogMessage<{}> } = Serde.decode("json", Fs.readFile(logFilename))
			table.insert(newLog, logMessage)

			Fs.writeFile(logFilename, Serde.encode("json", newLog, true))
		end

		Serde.encode("json", logMessage)
	end
end)

return setmetatable(
	{
		ConfigBuilder = ConfigBuilder.ConfigBuilder,
	} :: {
		ConfigBuilder: ConfigBuilder.ConfigBuilder,
		error: (...any) -> (),
		warn: (...any) -> (),
		info: (...any) -> (),
		debug: (...any) -> (),
		trace: (...any) -> (),
	},
	{
		__index = function<T>(self: T, method: Types.LogScope)
			local lowerMethod = string.lower(method)

			if
				lowerMethod == "info"
				or lowerMethod == "warn"
				or lowerMethod == "error"
				or lowerMethod == "debug"
				or lowerMethod == "trace"
			then
				return function(...)
					while impl == nil do
						print("Waiting for Implementor to be registered")
					end

					local localImpl: Implementor.Implementor<Writer.FleurWriter, {}> = impl

					local target = debug.info(2, "n")
					local targetWriter: Writer.FleurWriter = Writer
					local targetLevel: number? = targetLevelMap[target]

					if targetLevel then
						targetWriter.maxLogLevel = targetLevel
					end

					local args = table.pack(...)

					if filterPredicate then
						targetWriter.enabled = function(w: Writer.FleurWriter, scope: Types.LogScope)
							return filterPredicate(table.unpack(args)) and DEFAULT_ENABLED_FN(w, scope)
						end
					else
						targetWriter.enabled = DEFAULT_ENABLED_FN
					end

					if target == "" then
						target = packageName .. Ansi.style(":<anonymous>", "dim")
					else
						target = packageName .. ":" .. target
					end

					Methods[string.upper(method)](localImpl, target, targetWriter, {}, ...)
				end
			end

			return nil
		end,
	}
)
