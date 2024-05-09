local Log = require("methods")
local Implementor = require("implementor")

--[=[
	@class LogCore
]=]

--[=[
	@prop Log Log
	@within LogCore
]=]

--[=[
	@prop Implementor Implementor
	@within LogCore
]=]

return {
	Log = Log,
	Implementor = Implementor,
}
