--> @Desc Player data handler
--> @Author Tykind
local Players = game:GetService("Players")

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

---> @Section Parsing data

function playerData:parseData(target : Player)
    local data = target:WaitForChild("player data", 5)

    --> @Note Data folder not yet loaded or broken
    if not(data) then
        return 
    end

    return {
        ["cash"] = numval.new(data:FindFirstChild("cash") or Instance.new("NumberValue"))
    }
end

return playerData