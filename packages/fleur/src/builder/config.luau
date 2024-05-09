-- Builder class for setting logger config

local Types = require("../../../log-core/src/types")
local LOG_SCOPES = require("../enum/scope")
local Implementor = require("../../../log-core/src/implementor")
local Writer = require("../writer")
local Formatter = require("../formatter")
local Events = require("../../../log-core/src/events/event")
local indexMeta = require("../../../log-core/src/events/exports")._indexMeta

local ConfigBuilder = {}
export type ConfigBuilder = typeof(ConfigBuilder) & {
	levels: {
		[string]: number,
	},
	filterPredicate: (msg: Types.LogMessage) -> boolean, -- TODO: Implement runtime filtering
	formatTmpl: string,
	truncateLimit: number,
}

local EVENT_FLEUR_REGISTER = setmetatable(
	{
		id = "ready",
		listeners = {},
		_disposed = false,
	} :: Events.Event<ConfigBuilder>,
	{
		__index = indexMeta, -- TODO: Remove usage of private API
	}
)

function ConfigBuilder.new()
	return setmetatable({
		levels = {},
	}, {
		__index = ConfigBuilder,
	})
end

function ConfigBuilder.format(self: ConfigBuilder, format: string)
	self.formatTmpl = format
	return self
end

function ConfigBuilder.level(self: ConfigBuilder, level: Types.LogScope | number)
	if typeof(level) == "string" then
		self.levels["all"] = LOG_SCOPES[level :: Types.LogScope] or error("Unsupported log scope: " .. level)
	elseif typeof(level) == "number" then
		self.levels["all"] = level
	else
		error("Level must be enum LOG_SCOPES or type LogScope")
	end

	return self
end

function ConfigBuilder.levelFor(self: ConfigBuilder, target: string, level: Types.LogScope | number)
	if typeof(level) == "string" then
		self.levels[target] = LOG_SCOPES[level :: Types.LogScope] or error("Unsupported log scope: " .. level)
	elseif typeof(level) == "number" then
		self.levels[target] = level
	else
		error("Level must be enum LOG_SCOPES or type LogScope")
	end

	return self
end

function ConfigBuilder.filter(self: ConfigBuilder, predicate: (msg: Types.LogMessage) -> boolean)
	self.filterPredicate = predicate
	return self
end

function ConfigBuilder.limit(self: ConfigBuilder, limit: number)
	self.truncateLimit = limit
	return self
end

function ConfigBuilder.buildAndApply(self: ConfigBuilder)
	local w = Writer
	w.maxLogLevel = self.levels["all"]

	local _impl = Implementor.register(w, Formatter(self.formatTmpl), {
		truncateLimit = self.truncateLimit,
	})

	EVENT_FLEUR_REGISTER:_fire(nil, self)
	-- NOTE: EVENT_REGISTER is handled in interface.luau
end

return {
	ConfigBuilder = ConfigBuilder,
	EVENT_FLEUR_REGISTER = EVENT_FLEUR_REGISTER,
}