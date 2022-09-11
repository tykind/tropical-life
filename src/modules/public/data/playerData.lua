--> @Desc Player data handler
--> @Author Tykind
local playerData = {}

---> @Section Quick instance use

local numval = {}
numval.__index = numval

function numval.new(val : NumberValue)
    return setmetatable({
        val = val
    }, numval)
end

function numval:get()
    return self.val.Value
end

function numval:set(input : number)
    self.val.Value = input
end

function numval:add(amount : number)
    self.val.Value += amount
end

function numval:sub(amount : number)
    self.val.Value -= amount
end

local stringval = {}
stringval.__index = stringval

function stringval.new(val : StringValue)
    return setmetatable({
        val = val
    }, numval)
end

function stringval:get()
    return self.val.Value
end

function stringval:set(input : string)
    self.val.Value = input
end

local objectval = {}
objectval.__index = objectval

function objectval.new(val : ObjectValue)
    return setmetatable({
        val = val
    }, numval)
end

function objectval:get()
    return self.val.Value
end

function objectval:set(input : ObjectValue)
    self.val.Value = input
end

---> @Section Parsing data

function playerData:parseData(target : Player)
    local data = target:WaitForChild("player data", 5)

    --> @Note Data folder not yet loaded or broken
    if not(data) then
        return 
    end

    return {
        ["cash"] = numval.new(data:FindFirstChild("cash") or Instance.new("NumberValue")),
        ["role"] = stringval.new(data:FindFirstChild("role") or Instance.new("StringValue")),
        ["house"] = objectval.new(data:FindFirstChild("house") or Instance.new("ObjectValue"))
    }
end

return playerData