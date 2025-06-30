local __Types = require(script.Parent.Parent.__Types)

type Module = {}

export type StringModule = __Types.Attribute<Module, string> 

local String = {}
String.__index = String
String.Name = nil
String.__subscribed = false

function String.New(value: string)
	if value == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(value) ~= "string" then
		error(`[{script.Name}]: value be of type string`)
	end

	local self

	self = {
		Value = value,
	}
	setmetatable(self, string)

	return self
end

return String
