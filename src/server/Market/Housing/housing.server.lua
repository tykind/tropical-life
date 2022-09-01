--> @Desc Housing system set up
--> @Author Tykind
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local quickData = require(ServerStorage.Modules['quickData'])

local Housing = require(quickData.modules['Housing'].Module)

---> @Section Housing constants

local rnd = Random.new(tick() * 1000) --> 1000 random offset
local maxTaxPercentage = 20

---> @Section Create all houses

local function taxGenerator(housePrice)
    return housePrice - (housePrice - (housePrice * (rnd:NextInteger(1, maxTaxPercentage) / 100)))
end

for _, HouseObj in pairs(workspace.Houses:GetChildren()) do
    Housing:createHouse(HouseObj, taxGenerator):generateTax()
end

---> @Section Allow for house ownership and sale management
