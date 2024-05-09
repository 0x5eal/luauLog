local Stdio = require("@lune/stdio")

local Ansi = {}
export type Ansi = typeof(Ansi) & {
	base: string,
}
export type AnsiFunction = () -> string

function Ansi.new(base: string)
	return setmetatable({ base = base }, {
		__index = function(self: Ansi, color: Stdio.Color | "build")
			if color == "build" then
				return function()
					return self.base
				end
			end

			return function()
				self.base = Stdio.color(color) .. self.base .. Stdio.color("reset")
				return self
			end
		end,
	})
end

function Ansi.style(base: string, style: "bold" | "dim")
	return Stdio.style(style) .. base .. Stdio.style("reset")
end

function Ansi.normalize(str: string): string
	return select(
		1,
		str:gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+m", "")
			:gsub("\x1b%[%d+m", "")
	)
end

return Ansi
