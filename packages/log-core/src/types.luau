export type LogMessage = {
	scope: LogScope,
	message: string,
	timestamp: number,
	target: string,
}

--[=[
	@type LogScope "INFO" | "WARN" | "ERROR" | "DEBUG" | "TRACE"
]=]
export type LogScope = "INFO" | "WARN" | "ERROR" | "DEBUG" | "TRACE"

--[=[
	@type Writer { enabled: (self: Writer, scope: LogScope) -> boolean, writeAll: (self: Writer, ...any) -> string, flush: boolean }
]=]
export type Writer<T> = {
	enabled: (self: Writer<T>, scope: LogScope) -> boolean,
	writeAll: (self: Writer<T>, ...any) -> string,
	flush: boolean,
} & T

--[=[
	@type Formatter { fmt: (self: Formatter, message: LogMessage) -> string }
]=]
export type Formatter = {
	fmt: (self: Formatter, message: LogMessage) -> string,
}

return "<types>"
