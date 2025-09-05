-- !optimize 2
-- !strict

local __Types = require(script.Parent.Parent.__Types)

export type Module = {
    Get: () -> table,
    Set: () -> table,
    Update:(callback: (oldvalue: {}) -> {}) -> table
}

export type TableModule = __Types.Attribute<Module, table>

local Table = {}
Table.__index = Table
Table.Name = nil
Table.__subscribed = false

function Table.New(value: table): TableModule
    if value == nil then
        error(`[{script.name}]: Must have value`)
    elseif type(value) ~= "table" then
        error(`[{script.name}]: value must be of type table`)
    end

    warn("[DefaultModules.Table]: UNTESTED")

    local self

    self = {
        Value = value
    }
    setmetatable(self, Table)

    return self
end

function Table:Get(): table
    return self.Value 
end

-- TODO add GetSafe method

function Table:Set(value: table): table
    self.Value = value
    return self.Value
end

function Table:Update(callback: (oldvalue: {}) -> table): {}
    local success: boolean
    local newValue: {}

    success, newValue = pcall(function()
        return callback(self.Value)
    end)

    if success == false then
        error(`[{script.Name}]: callback function failed`)
    end

    return newValue
end

return Table