local Implementor = require("implementor")
local Types = require("types")

type LogMethod = <W>(impl: Implementor.Implementor<W>, target: string, writer: Types.Writer<W>?) -> ()

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
			return function<W>(impl: Implementor.Implementor<W>, target: string, writer: Types.Writer<W>?, ...)
				impl:log(target, scope, writer, true, ...)
			end
		end,
	}
)
