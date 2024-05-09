local Stdio = require("@lune/stdio")

local Types = require("../../log-core/src/types")
local LOG_SCOPES = require("enum/scope")

-- TODO: Default options, allow customization via constructor
local FleurWriter = {
	maxLogLevel = LOG_SCOPES["TRACE" :: Types.LogScope],
	flush = true,
}
type FleurWriterExt = {
	maxLogLevel: number,
}
export type FleurWriter = Types.Writer<FleurWriterExt>

function FleurWriter:writeAll(...): string
	local fmtString: string = select(1, ...)
	local indexTable = select(2, ...)

	if typeof(fmtString) ~= "string" then
		error("First argument must be of type string")
	end

	local nextMatch = fmtString:gmatch("{%a-}")
	local varRefFound = false
	local pos = 2
	while true do
		local match = nextMatch()
		if match == nil then
			break
		end

		-- Reference substitution like {var}
		local varRef = match:match("{(%a+)}")
		if varRef then
			varRefFound = true
			if typeof(indexTable) ~= "table" then
				error("Second argument must be of type string for reference substitution")
			end

			local subValue = indexTable[varRef]

			if subValue == nil then
				error("No substitution value for substitution template: " .. varRef)
			end

			fmtString = fmtString:gsub(match, Stdio.format(subValue))
		elseif varRefFound then
			error("Cannot have both reference substitution and anonymous substitution")
		else
			-- Anonymous substitution by position: {}
			fmtString = fmtString:gsub(match, Stdio.format(select(pos, ...)))
		end

		pos += 1
	end

	return fmtString
end

function FleurWriter.enabled(self: FleurWriter, scope: Types.LogScope)
	return LOG_SCOPES[string.upper(scope) :: Types.LogScope] <= self.maxLogLevel
end

return FleurWriter :: FleurWriter
