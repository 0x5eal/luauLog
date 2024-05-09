export type LogMessage = {
	scope: LogScope,
	message: string,
	timestamp: number,
	target: string,
}

export type LogScope = "INFO" | "WARN" | "ERROR" | "DEBUG" | "TRACE"

export type Writer<T> = {
	enabled: (self: Writer<T>, scope: LogScope) -> boolean,
	writeAll: (self: Writer<T>, ...any) -> string,
	flush: boolean,
} & T

export type Formatter = {
	fmt: (self: Formatter, message: LogMessage) -> string,
}

return "<types>"
