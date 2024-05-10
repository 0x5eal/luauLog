local ORDERED_LOG_LEVELS = table.freeze(setmetatable({
	["TRACE"] = 5,
	["DEBUG"] = 4,
	["ERROR"] = 3,
	["WARN"] = 2,
	["INFO"] = 1,
}, {
	__index = function(_, level)
		error("No log level defined for " .. level)
	end,
}))

return ORDERED_LOG_LEVELS
