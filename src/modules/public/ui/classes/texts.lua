--> @Desc Button objects
--> @Author Tykind
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local quickData = require(ReplicatedStorage.Modules.quickData)

local CoreTypes = require(quickData.modules.Types.Module)

---> @Section Basic library starter

local txt : CoreTypes.UIText = {
    Connections = {}
}
txt.__index = txt

local function parseTextObject(button : GuiMain, labelType : number?)
    if not(labelType) then
        return button --> @NOT_NEEDED
    end

    local ret
    --> @CHECK_KNOWN_TYPES
    if labelType == 1 then
        ret =  button:FindFirstChild("Input")
    end

    return ret --> @FOUND_txt
end

function txt.new(button : GuiMain, labelType : number?)
    local parsedText = parseTextObject(button, labelType)
    assert(parsedText, "Couldn't parse your text!")

    return setmetatable({
        Object = parsedText,
        Parent = parsedText.Parent
    }, txt)
end

---> @Section useful functions

function txt:get() : string
    return self.Object.Text
end

function txt:set(what : string)
    self.Object.Text = what
end

function txt:bindChangedValue(value : ValueBase)
    self.Connections["bindedValue"] = value:GetPropertyChangedSignal("Value"):Connect(function()
        self:set(tostring(value.Value))
    end)
end

function txt:unbindChangedValue()
    self:destroyKnownConnection("bindedValue")
end

function txt:destroy()
    self.Object:Destroy()
    table.clear(self.Connections)
end

function txt:destroyKnownConnection(name : string)
    local conn = self.Connections[name]
    self.Connections[name] = nil
    conn:Disconnect()
end

return txt