local Rtrace = require("Rtrace")
local Scope = require("Scope")

Rtrace.init("example", 5)
Rtrace.info("hi")

Scope.enter("DEBUG", "exampleScope", function(logger)
	logger.info("hi from exampleScope!")

	for i = 1, 10, 1 do
		task.wait(1)

		if i == 4 then
			error("whoops")
		end

		logger.info("we the best music")
	end
end)

Rtrace.debug("Hello world!")
Rtrace.warn(":)")
