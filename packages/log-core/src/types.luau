export type LogMessage<T> = {
	scope: LogScope,
	message: string,
	timestamp: number,
	target: string,
	metadata: T,
}

export type LogScope = "INFO" | "WARN" | "ERROR" | "DEBUG" | "TRACE"

export type Writer<T> = {
	enabled: (self: Writer<T>, scope: LogScope) -> boolean,
	writeAll: (self: Writer<T>, ...any) -> string,
	flush: boolean,
} & T

export type Formatter = {
	fmt: <T>(self: Formatter, message: LogMessage<T>) -> string,
}

return "<types>"
