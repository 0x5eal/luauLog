export type LogMessage = {
	scope: LogScope,
	message: string,
	timestamp: number,
}

export type LogScope = "INFO" | "WARN" | "ERROR" | "DEBUG" | "TRACE"

export type Writer = {
	enabled: (self: Writer, scope: LogScope) -> boolean,
	writeAll: (self: Writer, ...any) -> string,
	flush: boolean,
}

export type Formatter = {
	fmt: (self: Formatter, message: LogMessage) -> string,
}

return "<types>"
