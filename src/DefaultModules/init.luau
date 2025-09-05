local Bool = require(script.Bool)
local Number = require(script.Number)
local String = require(script.String)
local Table = require(script.Table)

export type BoolModule = Bool.BoolModule
export type NumberModule = Number.NumberModule
export type StringModule = String.StringModule
export type TableModule = Table.TableModule

return {
	Bool = Bool,
	Number = Number,
	String = String,
	Table = Table
}
