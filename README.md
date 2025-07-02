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

> [!INFO]
> Cerebral does not currently interact with DataStore.

## About
**Cerebral** is a Roblox Player State Management Tool. This tool is created to make managing Player Data through the server as seemeless and error free as possible, so you can spend more time the fun stuff rather than wondering why your *Money* is not increasing.

## Supported Platforms
No supported platforms at the moment. In the future, **Cerebral** will be posted to the Roblox Store as well as to [Wally](www.wally.run)

## Use
```luau
local Players = game:GetService("Players")

local CerebralPackage = require(--[[path to Cerebral]])
local Cerebral = CerebralPackage.New()

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