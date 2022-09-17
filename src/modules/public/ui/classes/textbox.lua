--> @Desc Button objects
--> @Author Tykind
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local quickData = require(ReplicatedStorage.Modules.quickData)

local CoreTypes = require(quickData.modules.Types.Module)

---> @Section Basic library starter

local tbox : CoreTypes.UITbox = {
    Connections = {}
}
tbox.__index = tbox

local function parseTextObject(button : GuiMain, labelType : number?)
    if not(labelType) then
        return button --> @NOT_NEEDED
    end

    local ret
    --> @CHECK_KNOWN_TYPES
    if labelType == 1 then
        ret =  button:FindFirstChild("Input")
    end

    return ret --> @FOUND_tbox
end

function tbox.new(button : GuiMain, labelType : number?)
    local parsedText = parseTextObject(button, labelType)
    assert(parsedText, "Couldn't parse your text!")

    return setmetatable({
        Object = parsedText,
        Parent = parsedText.Parent
    }, tbox)
end

---> @Section useful functions

function tbox:get() : string
    return self.Object.Text
end

function tbox:set(what : string)
    self.Object.Text = what
end

function tbox:bindChangedValue(value : ValueBase)
    self.Connections["bindedValue"] = value:GetPropertyChangedSignal("Value"):Connect(function()
        self:set(tostring(value.Value))
    end)
end

function tbox:bindFocusChanges(onFocus : (CoreTypes.UITbox) -> ()?, onFocusRelease : (CoreTypes.UITbox) -> ()?)
    if onFocus then
        self.Connections["focus"] = self.Object.Focused:Connect(function()
            onFocus()
        end)
    end

    if onFocusRelease then
        self.Connections["focusRelease"] = self.Object.FocusLost:Connect(function()
            onFocusRelease()
        end)
    end
end

function tbox:unbindChangedValue()
    self:destroyKnownConnection("bindedValue")
end

function tbox:destroy()
    self.Object:Destroy()
    table.clear(self.Connections)
end

function tbox:destroyKnownConnection(name : string)
    local conn = self.Connections[name]
    self.Connections[name] = nil
    conn:Disconnect()
end

return tbox