local __Types = require(script.Parent.Parent.__Types)

type Module = {
	Get: () -> string,
	Set: (value: string) -> string,
	GetLen: () -> number,
	Lower: () -> string,
	Upper: () -> string,
	Concat: (value: string) -> string
}

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

function String:Get(): string
	return self.value
end

function String:Set(value: string): string
	self.value = value
	return value
end

function String:GetLen(): number
	return string.len(self.value)
end

function String:Upper(): string
	self.value = string.upper(self.value)
	return self.value
end

function String:Lower(): string
	self.value = string.lower(self.value)
	return self.value
end

function String:Concat(value: string): string
	self.value = self.value .. value
	return self.value
end

return String
