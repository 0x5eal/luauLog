local Implementor = require("implementor")
local Types = require("types")

type LogMethod = <W>(impl: Implementor.Implementor<W>, target: string, writer: Types.Writer<W>?) -> ()

--[=[
	@class Log

	Internal Log class that developers use to create logs
]=]

return setmetatable(
	{} :: {
		--[=[
			@function error
			@within Log

			@param impl Implementor
			@param target string
			@param writer Writer

			@return ()
		]=]
		error: LogMethod,

		--[=[
			@function warn
			@within Log

			@param impl Implementor
			@param target string
			@param writer Writer

			@return ()
		]=]
		warn: LogMethod,

		--[=[
			@function info
			@within Log

			@param impl Implementor
			@param target string
			@param writer Writer

			@return ()
		]=]
		info: LogMethod,

		--[=[
			@function debug
			@within Log

			@param impl Implementor
			@param target string
			@param writer Writer

			@return ()
		]=]
		debug: LogMethod,

		--[=[
			@function trace
			@within Log

			@param impl Implementor
			@param target string
			@param writer Writer

			@return ()
		]=]
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
