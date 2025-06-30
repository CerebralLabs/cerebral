--!optimize 2
--!strict

-- Constants --
local AGENT_FOLDER = "__Data"

-- Dependencies --
local DefaultModules = require(script.DefaultModules)
local Signal = require(script.Signal)
local Types = require(script.__Types)
local Agent = require(script.__Agent)

-- Types --
export type JSONAcceptable = Types.JSONAcceptable
export type Attribute<A, B> = Types.Attribute<A, B>
export type Subscribed<A, B> = Types.Subscribed<A, B>
export type Agent = Agent.Agent
export type AvailableDefaultModules = Types.AvailableDefaultModules
export type Cerebral = Types.Cerebral

type ClassName = string

-- Private --

-- Fire event when a given attribute changes
local function _onChange() end

-- Public --

---- Cerebral Class ----
local Cerebral = {
	Agents = {},
	__attributes = {},
}

Cerebral.__index = Cerebral

function Cerebral.New()
	local self

	self = {}
	setmetatable(self, Cerebral)

	return self
end

--[[
Defines the attributes of every joining player.

PRIORITY IMPLEMENTATION: The ClassName must match that found in the DataStore.

Example:
```
local Cerebral = Cerebral.New()
Cerebral:DefineAttributes({
	money = Cerebral:Create("number"),
	xp = Cerebral:Create("number"),
	is_admin = Cerebral:Create("boolean"),
})
```
]]
function Cerebral:DefineAgentAttributes(attributes: { [ClassName]: Attribute<any, JSONAcceptable> })
	for name, class in attributes do
		self.__attributes[name] = class
	end
end

--[[
Example of incoming playerData:
```
{
	"money": 42,
	"xp": 9999,
	"is_admin": false
}
```
]]
function Cerebral:__SetAttribute<A, B>(
	agent: Agent,
	data: JSONAcceptable & B,
	attribute: Attribute<A, B>,
	name: string
): Subscribed<A, B>
	-- Add subscription methods
	local inter = Cerebral:__Subscribe(attribute)

	-- Add the updated attribute to the Agent
	local att = Agent:AddAttribute(inter, data, name)

	-- Return updated attribute for further use
	return att
end

-- Adds a new agent to Cerebral
function Cerebral:NewAgent(player: Player, playerData: { [string]: JSONAcceptable }): Agent
	local agent: Agent
	local agentFolder: Instance
	local _att: Subscribed<any, any>
	local dataType: AvailableDefaultModules
	local storedData: any -- BoolValue | NumberValue | StringValue

	agent = Agent.New(player)
	agentFolder = agent:AddPlayerFolder(AGENT_FOLDER)

	self.Agents[player.UserId] = agent

	-- UNTESTED
	for name, data in playerData do
		if self.__attributes[name] then
			_att = Cerebral:__SetAttribute(agent, data, self.__attributes[name], name)
			dataType = typeof(_att:GetSafe()) :: AvailableDefaultModules

			if dataType == "boolean" then
				storedData = Instance.new("BoolValue")
			elseif dataType == "number" then
				storedData = Instance.new("NumberValue")
			elseif dataType == "string" then
				storedData = Instance.new("StringValue")
			else
				-- boolean, number, and string are the only available data types
				-- supported in subscriptions
				continue
			end

			storedData.Value = data
			storedData.Parent = agentFolder

			-- Automatically updates values stored under Players[player]
			_att:Connect(function(value: typeof(data))
				storedData.Value = value
			end)
		else
			warn(`[{script.Name}]: MISSING DATA. Please add attribute for {name}`)
		end
	end

	return agent
end

-- Removes an agent from Cerebral
function Cerebral:RemoveAgent(player: Player)
	self.Agents[player.UserId] = nil
end

-- Gets an agent from Cerebral
function Cerebral:GetAgent(player: Player)
	return self.Agents[player.UserId]
end

-- Subscribes to an attribute
function Cerebral:__Subscribe<A, B>(class: A): Subscribed<A, B>
	--[[
    Maybe every single class has a `state` value. This value can be anything except a table.
    Every time state changes, we trigger a fire event for that player. 
    ]]

	-- selene: allow(shadowing)
	local _class = (class :: any) :: Subscribed<A, B>

	local _s = Signal.New()
	_class.__signal = _s

	-- selene: allow(shadowing)
	function _class:Fire(...)
		_class.__signal:Fire(...)
	end

	-- selene: allow(shadowing)
	function _class:Connect(listener: (...any) -> ())
		local connection = _class.__signal:Connect(listener)
		return connection
	end

	for key, method in pairs(_class) do
		if typeof(method) == "function" and key ~= "Get" and key ~= "New" and key ~= "GetSafe" then
			(_class :: any)[key] = function(_self, ...)
				local oldValue = _self and _self.Value
				local _r = method(_self, ...)
				local newValue = _self and _self.Value

				if oldValue ~= newValue then
					_class:Fire(newValue)
				end

				return _r
			end
		end
	end

	return _class
end

-- DEVELOPER NOTE: Don't love the `any` return value
function Cerebral:Create(type: AvailableDefaultModules): any
	if type == nil then
		error(`[{script.Name}]: Must have type`)
	elseif type ~= "boolean" and type ~= "string" and type ~= "number" then
		error(`[{script.Name}]: No availbe default module for {type}`)
	end

	local _r: any

	if type == "boolean" then
		_r = DefaultModules.Bool
	elseif type == "number" then
		_r = DefaultModules.Number
	elseif type == "string" then
		_r = DefaultModules.String
	end

	return _r
end

-- Does not make much sense here unless we are polling all data within Cerebral
function Cerebral:GetData<A>(): any
	local data: {}

	data = {}

	for _, class in self.Attributes do
		data[class.Name] = class:GetSafe()
	end

	return data
end

return Cerebral
