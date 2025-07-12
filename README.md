<div align="center">

# Cerebral
**Roblox Player State Management**\
*watch my data for me?*

[About](#about) |
[Supported Platforms](#supported-platforms) |
[Use](#use)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

> [!WARNING]
> Cerebral is in its early stages. So much so that there is no current version.

> [!WARNING]
> Cerebral does not currently interact with DataStore.

## About
**Cerebral** is a Roblox Player State Management Tool. This tool is created to make managing Player Data through the server as seemeless and error free as possible, so you can spend more time the fun stuff rather than wondering why your *Money* is not increasing.

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