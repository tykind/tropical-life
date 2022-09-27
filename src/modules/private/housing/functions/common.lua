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
end

local function setupHouse(self : QuickTypes.House)
    local HouseModel = self.ObjectRef
    local Door = HouseModel.Door
    local HouseSurfaceUI : SurfaceGui = Door.Part.SurfaceGui
    
    HouseSurfaceUI.Owner.Text = ("OWNER -> %s"):format(self.Owner.Name)
    HouseSurfaceUI.Enabled = true
    Door.CanCollide = false
end

return {
    setup = setupHouse,
    reset = onReset
}