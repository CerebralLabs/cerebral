--!optimize 2
--!strict

-- Constants --

-- Dependencies --
local DefaultModules = require(script.DefaultModules)
local Signal = require(script.Signal)

-- Private --

-- Fire event when a given attribute changes
local function _onChange() end

-- Public --

---- Types ----
export type JSONAcceptable = { JSONAcceptable } | { [string]: JSONAcceptable } | number | string | boolean | buffer

export type Attribute<A, B> = typeof(setmetatable({}, {})) & {
	Name: string,
	Value: B,
	__Subscribed: boolean,
	New: (...any) -> A,
	GetSafe: (self: A) -> JSONAcceptable,
	Set: (self: A, ...any) -> (),
} & A

export type Subscribed<A, B> = Attribute<A, B> & {
	Fire: (...any) -> (),
	Connect: (...any) -> (),
	__signal: {
		Connect: (self: any, listener: (JSONAcceptable) -> ()) -> any,
		Fire: (self: any, ...any) -> ()
	},
} & A

export type Profile = {
	playerName: string,
	playerId: number,
	attributes: { [string]: {
		class: Attribute<any, any>,
		subscribed: boolean,
	} }, -- unsure if any is correct here
}

export type AvailableDefaultModules = "boolean" | "string" | "number"

export type Cerebral = {
	New: () -> (),
	AddAgent: (self: Cerebral, agent: Profile) -> (),
	RemoveAgent: (self: Cerebral, agent: Player) -> (),
	Agents: { [string]: Profile },
}

---- End of Types ----

---- Class ----

local Cerebral = {}
Cerebral.__index = Cerebral

function Cerebral.New()
	local self

	self = {
		Agents = {},
	}
	setmetatable(self, Cerebral)

	return self
end

function Cerebral:NewAgent(agent: Profile)
	self.Agents[agent.playerId] = agent
end

function Cerebral:RemoveAgent(agent: Player)
	self.Agents[agent.UserId] = nil
end

function Cerebral:GetAgent(agent: Player)
	return self.Agents[agent.UserId]
end

function Cerebral:Subscribe<A, B>(class: A): Subscribed<A, B>
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

function Cerebral:Create(type: AvailableDefaultModules, name: string): any
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

    _r.Name = name
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
