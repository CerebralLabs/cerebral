--!strict

local Types = require(script.Parent.__Types)

export type Agent = Types.Agent & {
	AddAttribute: (self: Agent, class: any, initialValue: any, name: string) -> Types.Attribute<any, any>,
	GetAttribute: (self: Agent, className: string) -> Types.Attribute<any, any>,
	UpdateTable: (self: Agent, attribute: string, callback: (any) -> any) -> any,
	AddPlayerFolder: (self: Agent, folderName: string) -> Instance
}

local Agent = {}
Agent.__index = Agent

-- Creates new Agent and adds to Cerebral control
function Agent.New(player: Player): Agent
	if typeof(player) ~= "Instance" then
		error(`[{script.Name}]: Must have player`)
	end

	local self

	self = {
		player = player,
		attributes = {},
	}
	setmetatable(self, Agent)

	return (self :: any) :: Agent
end

-- Adds an attribute to a Agent
function Agent:AddAttribute<A, B>(class: Types.Attribute<A, B>, initValue: B, name: string): Types.Subscribed<A, B>
	if name == nil then
		error(`[{script.Name}]: Must have a name for class`)
	elseif type(name) ~= "string" then
		error(`[{script.Name}]: name must be of type string`)
	elseif initValue == nil then
		error(`[{script.Name}]: Must have initValue`)
	end

	self.attributes[name] = class.New(initValue)
	return self.attributes[name] :: Types.Subscribed<typeof(class), typeof(initValue)>
end

--[[
Returns an attribute of an Agent
 
WARNING: Can fail if attribute does not exist
]]
function Agent:GetAttribute<A>(attribute: string)
	if attribute == nil then
		error(`[{script.Name}]: Must have attribute`)
	elseif type(attribute) ~= "string" then
		error(`[{script.Name}]: attribute must be of type string`)
	end

	local class: A

	class = self.attributes[attribute]

	if class == nil then
		error(`[{script.Name}]: attribute [{attribute}] does not exist in {self.player.Name}`)
	end

	return class
end

--[[
UNTESTED: If the agent has an attribute that is a table (say for inventory),
this allows the user to update that table like they would a SharedTable.

DEVELOPER NOTE: Currently, tables are not an accepted value type. This is a priority.
]] -- Update function similar to how SharedTables updated
function Agent:UpdateTable<A>(attribute: string, callback: (oldValue: A & {}) -> A & {}): A & {}
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

-- Consider making private?
-- Adds folder to Agent's player
-- should we consider using attributes instead?
function Agent:AddPlayerDataFolder(folderName: string): Instance
	local folder = Instance.new("Folder")
	folder.Name = folderName
	folder.Parent = self.player
	return folder
end

function Agent:GetSafeData(): {}
	local safeData: {}
	
	safeData = {}

	for _, attribute in self.attributes do
		local data: Types.JSONAcceptable
		local name: string

		name = attribute.Name
		if name == nil then 
			error(`[{script.Name}]: attribute does not have name!`)
		end

		if typeof(attribute["GetSafe"]) ~= "function" then
			error(`[{script.Name}]: attribute [{name}] does not have GetSafe function!`)
		end
		data = attribute:GetSafe()

		-- What happens if data is nil?
		safeData[name] = data
	end

	return safeData
end

return Agent
