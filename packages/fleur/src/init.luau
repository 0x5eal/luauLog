local fleur = require("interface")

local anonymous = function()
	fleur.warn("warning from an anonymous function")
	fleur.info("test")
	fleur.error("more test")
end

function main()
	fleur.ConfigBuilder
		.new("example")
		:level("TRACE")
		:format("{time} [{level}][{target}] {message}")
		:levelFor("main", "DEBUG")
		:logFile("{name}-{time}.log", "plaintext")
		:filter(function(...): boolean
			-- Block out this very derogatory log smh
			if select(1, ...) == "your mother" then
				return false
			end

			return true
		end)
		:buildAndApply()

	fleur.debug("hello {}", "jack")
	fleur.error("this is {libName}", {
		libName = "fleur",
	})
	fleur.info("table: {}", {
		hi = "hello",
	})
	fleur.info("hello from a function!")
	fleur.info("your mother")
	fleur.trace("some trace which shouldn't show up")
	anonymous()
end

return main()
