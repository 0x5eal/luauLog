local Implementor = require("implementor")
local Types = require("types")

type LogMethod = (impl: Implementor.Implementor, target: string, writer: Types.Writer?) -> ()

return setmetatable(
	{} :: {
		error: LogMethod,
		warn: LogMethod,
		info: LogMethod,
		debug: LogMethod,
		trace: LogMethod,
	},
	{
		__index = function(self, scope: Types.LogScope): LogMethod
			return function(impl: Implementor.Implementor, target: string, writer: Types.Writer?, ...)
				impl:log(target, scope, writer, true, ...)
			end
		end,
	}
)
