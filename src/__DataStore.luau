--!strict
--!optimize 2

-- Dependencies --
local Types = require(script.Parent.__Types)
local Signal = require(script.Parent.__Packages.Signal)

-- Constants --

-- Private --

-- Public --

---- DataStore Class ----

local DataStore = {}
DataStore.__index = DataStore

-- DataStore Constructor
function DataStore.New(
    DataStoreName: string
): Types.DataStore
    local self

    self = {
        DataStoreName = DataStoreName
    }
    setmetatable(self, DataStore)

    return self
end

--[[
INCOMPLETE
Need to hash out DataStore funtionality

Saves a single players data. Good for after the player buys an item.
]]
function DataStore.SaveSinglePlayerData(agent: Types.Agent): boolean
    if agent == nil then
        warn(`[{script.Name}]: Must have agent`)
        return false
    end

    local data: {} 

    data = agent:GetSafeData()

    return true
end

return DataStore