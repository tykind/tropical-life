--> @Desc Button objects
--> @Author Tykind
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local quickData = require(ReplicatedStorage.Modules.quickData)

local CoreTypes = require(quickData.modules.Types.Module)

---> @Section Basic library starter

local btn : CoreTypes.UIButton = {
    Connections = {}
}
btn.__index = btn

local function parseButtonObject(button : GuiMain, buttonType : number?)
    if not(buttonType) then
        return button --> @NOT_NEEDED
    end

    local ret
    --> @CHECK_KNOWN_TYPES
    if buttonType == 1 then
        ret =  button:FindFirstChild("Input")
    end

    return ret --> @FOUND_BTN
end

function btn.new(button : GuiMain, buttonType : number?) : CoreTypes.UIButton
    local parsedButton = parseButtonObject(button, buttonType)
    assert(parsedButton, "Couldn't parse your button!")

    return setmetatable({
        Object = parsedButton,
        Parent = parsedButton.Parent
    }, btn)
end

---> @Section useful functions

function btn:registerOnClick(func : () -> (), name : string?) : RBXScriptConnection
    local conn = self.Object.MouseButton1Click:Connect(func)

    if name then
        self.Connections[name] = conn
    end
    return conn
end

function btn:destroy()
    self.Object:Destroy()
    table.clear(self.Connections)
end

function btn:destroyKnownConnection(name : string)
    local conn = self.Connections[name]
    self.Connections[name] = nil
    conn:Disconnect()
end

return btn