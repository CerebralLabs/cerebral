--!strict
--!optimize 2

-- Dependencies --
local DataStoreService = game:GetService("DataStoreService")

local Types = require(script.Parent.__Types)

-- Constants --
local MAX_ATTEMPTS = 10
local RETRY_TIME = 0.2
local DATA_STORE_NAME = "Cerebral_DB"

-- Private --
local function waitOnDataStore(ds_service: DataStoreService, enum: typeof(Enum))
    local attempts: number
    local success: boolean

    attempts = 0
    success = false

    repeat
        while ds_service:GetRequestBudgetForRequestType(enum) < 1 do
            warn("Data store budget depleted. Waiting")
            task.wait(attempts * RETRY_TIME)
        end

        success = true
    until success or attempts == MAX_ATTEMPTS

    if not success then
        error(`[{script.Name}]: DataStore budget completed depleted`)
    end

    return
end

-- Public --

---- DataStore Class ----

local DataStore = {}
DataStore.__index = DataStore

-- DataStore Constructor
function DataStore.New<A>(): Types.DataStore<A>
    local self

    self = {
        DataStoreName = DATA_STORE_NAME
    }
    setmetatable(self, DataStore)

    return self
end

function DataStore:GetPlayerData<A>(player: Player, _kickPlayerOnFail: boolean): A
    local ds: DataStoreService
    local success: boolean
    local data: {}
    local kickPlayerOnFail: boolean

    ds = DataStoreService:GetDataStore(self.DataStoreName)
    kickPlayerOnFail = if _kickPlayerOnFail == nil then true else _kickPlayerOnFail

    success, data = pcall(function()
        waitOnDataStore(ds, Enum.DataStoreRequestType.GetAsync) -- yeilds
        return ds:GetAsync(player.UserId)
    end)

    if success then
        return data
    end

    -- If GetPlayerData reaches this point, kick the player
    if kickPlayerOnFail then
        player:Kick("Failed to get user data. Please try again later.")
    end

    return {}
end

function DataStore:UpdatePlayerData<A>(
    player: Player,
    data: A
): A
   local ds: DataStoreService
   local success: boolean
   local err: string

    ds = DataStoreService:GetDataStore(self.DataStoreName)
   success, err = pcall(function()
        waitOnDataStore(ds, Enum.DataStoreRequestType.UpdateAsync) -- yields
        if data then
            ds:UpdateAsync(player.UserId, function(oldValue)
                if data.DataId == oldValue.DataId then
                    data.DataId += 1
                    return data
                else
                    return nil
                end
            end)
        end
   end)

    if success then
        return data
    end

    warn(`[{script.Name}]: Could not update player [{player.Name}] data.`)
    warn(data)

    if err then
        warn(`[{script.Name}] ERROR: {err}`)
    end

    return {}
end

return DataStore