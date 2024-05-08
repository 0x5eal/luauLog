local Events = require("../../log-core/src/events/exports")
local ConfigBuilder = require("builder/config")
local Implementor = require("../../log-core/src/implementor")

Events.EVENT_REGISTERED:listen(function(registrarId: string, impl: Implementor.Implementor)
	impl:log("hi", "TRACE", nil, true, "hello {}", "world")
end)

return {
	ConfigBuilder = ConfigBuilder,
}
