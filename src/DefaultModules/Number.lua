--!strict

-- Constants --
-- Do we need integer overflow protection?

--Dependencies --
local __Types = require(script.Parent.Parent.__Types)

-- Private --
type Module = {
	Get: () -> number,
	Increment: (number) -> number,
	Decrement: (number) -> number,
	Zero: () -> (),
	Multiply: (number) -> (),
	Divide: (number) -> (),
}

-- Public --
--[[ 
Type for the Cereberal Bool Default Module
]]
-- Skip out on Name, Value, New, GetSafe, Set
export type NumberModule = __Types.Attribute<Module, number>

local Number = {}
Number.__index = Number
Number.Name = nil
Number.__subscribed = false

function Number.New(value: number)
	if value == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(value) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	local self

	self = {
		Value = value,
	}
	setmetatable(self, Number)

	return self
end

function Number:Get(): number
	return self.Value
end

function Number:HasEnough(amt: number): boolean
	return self:Get() >= amt
end

function Number:GetSafe(): number
	return self:Get()
end

function Number:Set(value: number)
	if value == nil then
		error(`[{script.Name}]: Must have name`)
	elseif type(value) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	self.Value = value
end

function Number:Increment(value: number)
	if value == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(value) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	local _v: number = self.Value
	self.Value = _v + value
end

function Number:Decrement(value: number)
	if value == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(value) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	local _v: number = self.Value
	self.Value = _v - value
end

function Number:Zero(value: number)
	if value == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(value) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	self.Value = 0
end

function Number:Multiply(mult: number)
	if mult == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(mult) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	local _v: number = self.Value
	self.Value = _v * mult
end

function Number:Divide(div: number)
	if div == nil then
		error(`[{script.Name}]: Must have value`)
	elseif type(div) ~= "number" then
		error(`[{script.Name}]: value be of type number`)
	end

	if div == 0 then
		warn(`[{script.Name}]: div cannot be 0`)
		return
	end

	local _v: number = self.Value
	self.Value = _v / div
end

return Number
