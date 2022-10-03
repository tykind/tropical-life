local TestService = game:GetService("TestService")
local quickData = require(script.Parent.Parent.Parent.quickData)

local PlayerDataParser = require(quickData.modules['Data parser'].Module)
local QuickTypes = require(quickData.modules['Types'].Module)

local function onReset(self : QuickTypes.House, target : Player)
    local HouseModel = self.ObjectRef
    local Door = HouseModel.Door
    local HouseSurfaceUI : SurfaceGui = Door.Part.SurfaceGui

    HouseSurfaceUI.Enabled = false
    Door.CanCollide = true
    Door.DoorInteraction.Enabled = true

    TestService:Message(("Restarted house %s"):format(self.ObjectRef.Name))
end

local function setupHouse(self : QuickTypes.House)
    local HouseModel = self.ObjectRef
    local Door = HouseModel.Door
    local HouseSurfaceUI : SurfaceGui = Door.Part.SurfaceGui
    
    HouseSurfaceUI.Owner.Text = ("OWNER -> %s"):format(self.Owner.Name)
    HouseSurfaceUI.Enabled = true
    Door.CanCollide = false

    TestService:Message(("Set up house %s"):format(self.ObjectRef.Name))
end

return {
    setup = setupHouse,
    reset = onReset
}