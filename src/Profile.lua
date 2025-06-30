--!strict

local __Types = require(script.Parent.__Types)
local _Cerebral = require(script.Parent)

export type Profile = __Types.Profile & {
	AddAttribute: (self: Profile, class: any, initialValue: any, subscribe: boolean | nil) -> (),
	GetAttribute: (self: Profile, className: string) -> any,
	UpdateTable: (self: Profile, attribute: string, callback: (any) -> any) -> any,
}

local Profile = {}
Profile.__index = Profile

-- Creates new Agent and adds to Cerebral contorl
function Profile.New(player: Player, Cerebral: typeof(_Cerebral.New()))
	if typeof(player) ~= "Instance" then
		error(`[{script.Name}]: Must have player`)
	end

	local self

	self = {
		playerName = player.Name,
		playerId = player.UserId,
		attributes = {},
	}
	setmetatable(self, Profile)

	Cerebral:AddAgent((self :: any) :: Profile)

	return (self :: any) :: Profile
end

function Profile:AddAttribute<A, B>(
	class: __Types.Attribute<A, B>,
	initValue: B,
	subscribe: boolean | nil
): __Types.Attribute<A, B> | __Types.Subscribed<A, B>
	if class.Name == nil then
		error(`[{script.Name}]: Must have a name for class`)
	elseif initValue == nil then
		error(`[{script.Name}]: Must have initValue`)
	end

	if subscribe then
		local _inter = _Cerebral:Subscribe(class)
		_inter.__Subscribed = true
		self.attributes[class.Name] = _inter.New(initValue)
		return self.attributes[class.Name] :: __Types.Subscribed<typeof(class), typeof(initValue)>
	end

	class.__Subscribed = false
	self.attributes[class.Name] = class.New(initValue)
	return self.attributes[class.Name] :: __Types.Attribute<typeof(class), typeof(initValue)>
end

-- What happens if class is nil?
function Profile:GetAttribute<A>(attribute: string)
	if attribute == nil then
		error(`[{script.Name}]: Must have attribute`)
	elseif type(attribute) ~= "string" then
		error(`[{script.Name}]: attribute must be of type string`)
	end

	local class: A

	class = self.attributes[attribute]

	if class == nil then
		error(`[{script.Name}]: attribute [{attribute}] does not exist in {self.playerName}`)
	end

	return class
end

-- Update function similar to how SharedTables updated
--[[
If the agent has an attribute that is a table (say for inventory),
this allows the user to update that table like they would a SharedTable
]]
function Profile:UpdateTable<A>(attribute: string, callback: (oldValue: A & {}) -> A & {}): A & {}
	local class
	local value: A & {}
	local success: boolean
	local newValue: A & {}

	class = self:GetAttribute(attribute)
	value = class:Get()

	-- Protect the user
	success, newValue = pcall(function()
		return callback(value)
	end)

	if success == false then
		error(`[{script.Name}]: callback function failed`)
	end

	return newValue
end

return Profile
