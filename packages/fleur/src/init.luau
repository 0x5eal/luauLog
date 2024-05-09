local fleur = require("interface")

local anonymous = function()
    fleur.warn("warning from an anonymous function")
end

function main()
    fleur.ConfigBuilder.new()
        :level("TRACE")
        :format("{time} [{level}][{target}] {message}")
        :buildAndApply()
    
    fleur.info("hello from a function!")
    anonymous()
end

return main()