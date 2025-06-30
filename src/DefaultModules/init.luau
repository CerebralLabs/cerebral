local Bool = require(script.Bool)
local Number = require(script.Number)
local String = require(script.String)

export type BoolModule = Bool.BoolModule
export type NumberModule = Number.NumberModule
export type StringModule = String.StringModule

return {
	Bool = Bool,
	Number = Number,
	String = String,
}
