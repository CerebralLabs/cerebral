<div align="center">

# Cerebral
**Roblox Player State Management**\
*watch my data for me?*

[About](#about) |
[Supported Platforms](#supported-platforms) |
[Use](#use) | 
[Road Map](#road-map)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

> [!WARNING]
> Cerebral is in its early stages and is **unstable**. **Do not use in production**

## About
**Cerebral** is a Roblox Player State Management Tool. This tool is created to make managing Player Data through the server as seemeless and error free as possible, so you can spend more time on the fun stuff rather than wondering why your *Money* is not increasing.

## Supported Platforms
**Cerebral** is currently posted on [Wally](www.wally.run) under `cerebrallabs/cerebral`. Roblox Store support is planned.

## Use
### Set Up
```luau
local Players = game:GetService("Players")

local Cerebral = require(--[[path to Cerebral]])

Cerebral:DefineAgentAttributes({
    "money" = Cereberal:Create("number"),
    "xp" = Cereberal:Create("number"),
    "is_admin" = Cerebral:Create("boolean"),
    "pet_name" = Cerebral:Create("string"),
})

local function PlayerAdded(player: Player)
    local agent: Cerebral.Agent
    local playerData

    agent = Cerebral:NewAgent(player)
    playerData = -- Some dataStore getter function

    Cerebral:NewAgent(player, playerData)
end

local function RemovePlayer(player: Player)
    Cerebral:RemoveAgent(player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoved:Connect(RemovePlayer)
```

### Use
Imagine a buy station.
```luau
local Cerebral = require(--[[path to Cerebral]])
local proximitySensor = script.--[[path to proximitySensor]]

local COST = 50

proximitySensor.Triggered:Connect(function(player: Player)
    local playerMoney = Cerebral:GetAgent(player):GetAttribute("money")
    if playerMoney:Get() >= COST then
        playerMoney:Decrement(COST)
        --[[award player whatever this proximitySensor is connected to]]
    else
        --[[notify user "NOT ENOUGH MONEY]]
    end
end)
```

### Road Map
In no particular order:

#### 1. Add migrations for `ds_data.data` to better allow for the transfer of data models. I want these to act similarly to how postgres migrates its databases. 

For instance, if we wish to change the name of a attribute name, like `money` to `coins`, we would have the migration move the attribute to the new name upon the player joining the server. 

Additionally, these migrations will (and must) be labeled cardinally. So when a player that has not logged on in a while, their data can migrate thorugh several migrations without breaking anything.

Example:
```luau
-- migration 1
Cerebral:Migrate({version = 1}, function(oldData)
    local newData = oldData
    newData.ds_data.data.coins = oldData.ds_data.data.money
    newData.ds_data.data.money = nil

    return newData
end)
```

NOTE: Cerebral should store migrations in the data store. Unsure how to go about this, but we want to raise all the flags if a migration is missing. 

#### 2. Create more secure default modules.

Take a module that tracks `experience`. `experience` should never be able to decrease. The developer should know this, but adding additoinal protections, like:

```luau
Cerebral:DefineAttributes({ 
    --                            Module Type | Options
    "experience" = Cerebral:Create("number", { protected = true }) 
})
```

would be welcomed. Additionally, adding in the `options` functionality via a table supports forward thinking. 