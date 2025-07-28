--!strict

-- Dependencies --
local Types = require(script.Parent.__Types)
local DataStore = require(script.Parent.__DataStore)

-- Constants --

-- Types --
export type Agent = Types.Agent & {
	player: Player,
	ds_data: {[string]: Types.JSONAcceptable},
	AddAttribute: (self: Agent, class: any, initialValue: any, name: string) -> Types.Attribute<any, any>,
	GetAttribute: (self: Agent, className: string) -> Types.Attribute<any, any>,
	UpdateTable: (self: Agent, attribute: string, callback: (any) -> any) -> any,
	AddPlayerFolder: (self: Agent, folderName: string) -> Instance
}

-- What the Player data looks like in cerebral
export type PlayingTemplate = {
	playerId: number, -- player.UserId
	attributes: { Types.Attribute<any, any> }, -- All the attributes, is converted to data at save
	DataId: number, -- Data id; increments after each safe
	metaData: {
		sessions: number, -- total logins
		lastUpdate: number, -- last update
		lastLogin: number, -- last login
		profileCreationTime: number, -- when the profile was created
	}
}

-- What the Player data looks like in DataStore
export type StoringTemplate = {
	playerId: number, -- player.UserId,
	data: { [string]: Types.JSONAcceptable }, -- All the data from each attributes [.Name] = .GetSafe()
	DataId: number, -- Data id; increments after each save.
	metaData: {
		sessions: number, -- total logins; wont be the same of DataId
		lastUpdate: number, -- last update
		lastLogin: number, -- last login
		profileCreationTime: number, -- when the profile was created
	}
}

-- Private --

-- For new players with no data
local function newPlayer(player: Player)
	if typeof(player) ~= "Instance" then
		error(`[{script.Name}]: Must have player`)
	end


	return {
		ds_data = {
			data = {}
		}
	}
end

local function getAgentData(player: Player)
	local data: {}

	data = DataStore:GetPlayerData(player)
end

-- Public --
---- Agent Class ----

local Agent = {}
Agent.__index = Agent

-- Creates new Agent and adds to Cerebral control
-- TODO:
-- A new Agent must get the data from the datastore and return it in
-- self.data
function Agent.New(player: Player): Agent
	if typeof(player) ~= "Instance" then
		error(`[{script.Name}]: Must have player`)
	end

	local self
	local data

	data = getAgentData(player) or newPlayer(player)

	self = {
		player = player,
		attributes = {},
		ds_data = data
	}
	setmetatable(self, Agent)

	return (self :: any) :: Agent
end

-- Adds an attribute to a Agent
function Agent:__AddAttribute<A, B>(class: Types.Attribute<A, B>, initValue: B, name: string): Types.Subscribed<A, B>
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
DEVELOPER NOTE: What do I want this to look like in the DataStore?
{
	player_id: number,
	server_id: number,
	data_id: number,
	data: {
		...
	},
	meta_data: {
		session_count: number,
	}
}

And then serverside...
Seems silly tbh, could we not just convert everything to attributes?
{
	player: Player,
	attributes: ...,
	ds_data: {
		data: { [string]: JSON }
	}
}
]]
function Agent:SaveToDataStore()
	local safe_data

	-- Get safe data from current attributes
	safe_data = self:GetSafeData()

	for name, data in safe_data do
		if self.ds_data.data[name] then
			self.ds_data.data[name] = data
		end
	end

	-- returns data with updated data_id upon success
	self.ds_data.data = DataStore:UpdatePlayerData(self.player, safe_data)
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
