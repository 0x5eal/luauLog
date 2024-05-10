local Implementor = require("implementor")
local Types = require("types")

type LogMethod = <W, B>(
	impl: Implementor.Implementor<W, B>,
	target: string,
	writer: Types.Writer<W>?,
	metadata: B,
	...any
) -> ()

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
			return function<W, B>(
				impl: Implementor.Implementor<W, B>,
				target: string,
				writer: Types.Writer<W>?,
				metadata: B,
				...
			)
				impl:log(target, scope, writer, true, metadata, ...)
			end
		end,
	}
)
