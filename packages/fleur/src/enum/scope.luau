local Types = require("../../../log-core/src/types")

local ORDERED_LOG_SCOPES: { [Types.LogScope]: number } = table.freeze({
	["TRACE"] = 5,
	["DEBUG"] = 4,
	["ERROR"] = 3,
	["WARN"] = 2,
	["INFO"] = 1,
})

return ORDERED_LOG_SCOPES
