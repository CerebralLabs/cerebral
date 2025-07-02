local __Types = require(script.Parent.Parent.__Types)

export type Module = {
    Get: () -> boolean,
    Set: (value: boolean) -> (),
    Flip: () -> (),
    SetFalse: () -> (),
    SetTrue: () -> ()
}

--[[ 
Type for the Cereberal Bool Default Module
]] -- Skip out on Name, Value, New, GetSafe, Set
export type BoolModule = __Types.Attribute<Module, boolean>

local Bool = {}
Bool.__index = Bool
Bool.Name = nil
Bool.__subscribed = false

function Bool.New(value: boolean)
    if value == nil then
        error(`[{script.Name}]: Must have value`)
    elseif type(value) ~= "boolean" then
        error(`[{script.Name}]: value be of type boolean`)
    end

    local self

    self = {
        Value = value
    }
    setmetatable(self, Bool)

    return self
end

function Bool:Get(): boolean
    return self.Value
end

function Bool:GetSafe(): boolean
    return self:Get()
end

function Bool:Set(value: boolean)
    if value == nil then
        error(`[{script.Name}]: Must have name`)
    elseif type(value) ~= "boolean" then
        error(`[{script.Name}]: value be of type boolean`)
    end

    self.value = value
end

function Bool:Flip()
    self.value = not self.value
end

function Bool:SetFalse()
    self.Value = false
end

function Bool:SetTrue()
    self.Value = true
end

return Bool