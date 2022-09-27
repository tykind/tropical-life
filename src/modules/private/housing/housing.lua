--> @Desc House system
--> @Note Handle configuration on table
-->
--> @Author Tykind
local Players = game:GetService("Players")
local quickData = require(script.Parent.Parent.quickData)

local House = require(quickData.modules['House'].Module)
local QuickTypes = require(quickData.modules["Types"].Module)

---> @Section Basic functions

local housing : QuickTypes.HousingSystem = {
    Houses = {}
}

function housing:createHouse(object : Model, taxGen : (number) -> (number))
    local configuration : Configuration = object:FindFirstChildOfClass("Configuration")
    assert(configuration, "Model doesn't have house configuration")

    local house : QuickTypes.House = House.new(object, taxGen)
    quickData:copyConfigurationData(house, configuration:GetChildren(), {
        ["Class"] = true,
        ["Price"] = true 
    })

    table.insert(self.Houses, house)
    return house
end

function housing:getHouseFromPlayer(player : Player)
    for _, House : QuickTypes.House in pairs(self.Houses) do
        if House.Owner == player then
            --> @Info Found our house
            return House
        end
    end
end

return housing