local Implementor = require("implementor")
local Types = require("types")

type LogMethod = (impl: Implementor.Implementor, writer: Types.Writer?) -> ()

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
			return function(impl: Implementor.Implementor, writer: Types.Writer?)
				impl.Prototype:log(scope, writer)
			end
		end,
	}
)
