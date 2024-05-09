local Events = require("../../log-core/src/events/exports")
local ConfigBuilder = require("builder/config")
local Implementor = require("../../log-core/src/implementor")
local Methods = require("../../log-core/src/methods")
local Ansi = require("ansi")
local Types = require("../../log-core/src/types")

impl = nil

Events.EVENT_REGISTERED:listen(function(_: string, firedImpl: Implementor.Implementor)
	impl = firedImpl
end)

return setmetatable(
	{
		ConfigBuilder = ConfigBuilder,
	} :: {
		ConfigBuilder: typeof(ConfigBuilder),
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

					if target == "" then
						target = Ansi.style("<anonymous>", "dim")
					end

					Methods[string.upper(method)](impl :: Implementor.Implementor, target, nil, ...)
				end
			end

			return nil
		end,
	}
)
