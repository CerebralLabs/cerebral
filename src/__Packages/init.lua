--[[
__Packages is not really a package directory. It is no like node_modules
to Node.js. Instead, this directory harbors variours code snippets I come
across in the Luau community (proper license of course).
]]

local Signal = require(script.Signal)

local Packages = {
    Signal = Signal -- Handles Luau event signals
}

return Packages