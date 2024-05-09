local fleur = require("interface")

local anonymous = function()
	fleur.warn("warning from an anonymous function")
	fleur.info("test")
	fleur.error("more test")
end

function main()
	fleur.ConfigBuilder
		.new()
		:level("TRACE")
		:format("{time} [{level}][{target}] {message}")
		:levelFor("main", "DEBUG")
		:filter(function(...): boolean
			if select(1, ...) == "ligma bosack" then
				return false
			end

			return true
		end)
		:buildAndApply()

	fleur.info("hello from a function!")
	fleur.info("ligma bosack")
	fleur.trace("some trace which shouldn't show up")
	anonymous()
end

return main()
