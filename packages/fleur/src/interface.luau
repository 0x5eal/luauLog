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

Events.EVENT_REGISTERED:listen(function(_: string, firedImpl: Implementor.Implementor<Writer.FleurWriter>)
	impl = firedImpl
end)

ConfigBuilder.EVENT_FLEUR_REGISTER:listen(function(_: string, firedConfigBuilder: ConfigBuilder.ConfigBuilder)
	targetLevelMap = firedConfigBuilder.levels
	targetLevelMap.all = nil

	filterPredicate = firedConfigBuilder.filterPredicate
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
						target = Ansi.style("<anonymous>", "dim")
					end

					Methods[string.upper(method)](
						impl :: Implementor.Implementor<Writer.FleurWriter>,
						target,
						targetWriter,
						...
					)
				end
			end

			return nil
		end,
	}
)
