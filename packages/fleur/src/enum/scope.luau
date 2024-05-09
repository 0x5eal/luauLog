local ORDERED_LOG_SCOPES = table.freeze(setmetatable({
	["TRACE"] = 5,
	["DEBUG"] = 4,
	["ERROR"] = 3,
	["WARN"] = 2,
	["INFO"] = 1,
}, {
	__index = function(_, scope)
		error("No log scope defined for " .. scope)
	end,
}))

return ORDERED_LOG_SCOPES
