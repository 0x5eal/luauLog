local fleur = require("interface")

local anonymous = function()
	fleur.warn("warning from an anonymous function")
end

function main()
	fleur.ConfigBuilder
		.new()
		:level("TRACE")
		:format("{time} [{level}][{target}] {message}")
		:levelFor("main", "DEBUG")
		:buildAndApply()

	fleur.info("hello from a function!")
	fleur.trace("some trace which shouldn't show up")
	anonymous()
end

return main()
