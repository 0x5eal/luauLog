local DateTime = require("@lune/datetime")

local Types = require("../../log-core/src/types")
local Writer = require("writer")
local Ansi = require("ansi")

local Formatter = {}

local DEFAULT_FORMATTING_TMPL = "{time} [{level}][{target}] {message}"
local LEVEL_COLORMAP: { [Types.LogScope]: string } = {
	["ERROR"] = Ansi.new("error"):red():build(),
	["WARN"] = Ansi.new("warn"):yellow():build(),
	["INFO"] = Ansi.new("info"):green():build(),
	["DEBUG"] = Ansi.new("debug"):purple():build(),
	["TRACE"] = Ansi.new("trace"):cyan():build(),
}

function Formatter:fmt(logMessage: Types.LogMessage): string
	return Writer:writeAll(self.fmtTmpl, {
		time = Ansi.style(DateTime.fromUnixTimestamp(logMessage.timestamp):formatLocalTime("%Y-%m-%d %H:%M:%S"), "dim"),
		level = LEVEL_COLORMAP[logMessage.scope],
		target = Ansi.style(logMessage.target, "bold"),
		message = logMessage.message,
	})
end

local function constructor(fmt: string?)
	return setmetatable({
		fmtTmpl = fmt or DEFAULT_FORMATTING_TMPL,
}, {
    __index = Formatter,
})
end

return constructor
