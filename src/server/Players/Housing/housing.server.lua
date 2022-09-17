--> @Desc Housing system set up
--> @Author Tykind
local ServerStorage = game:GetService("ServerStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local quickData = require(ServerStorage.Modules["quickData"])
local Remotes = ReplicatedStorage.Remotes

local PlayerDataParser = require(quickData.modules["Data parser"].Module)
local Housing = require(quickData.modules["Housing"].Module)
local toggleHouseLockEvent : RemoteEvent = Remotes.Client.toggleHouseLock

---> @Section Housing constants

local rnd = Random.new(tick() * 1000) --> 1000 random offset
local maxTaxPercentage = 20

---> @Section Create all houses

local function taxGenerator(housePrice)
	return housePrice - (housePrice - (housePrice * (rnd:NextInteger(1, maxTaxPercentage) / 100)))
end

for _, HouseObj in pairs(workspace.Houses:GetChildren()) do
	local House = Housing:createHouse(HouseObj, taxGenerator)
	House:generateTax()

	--> @Note Add liseners to buy the houses
	
	local DoorPrompt: ProximityPrompt = HouseObj.Door.DoorInteraction
	local debounce
	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		if not(debounce) and prompt == DoorPrompt then
			debounce = true
			if prompt.ActionText == "Purchase" then
				--> Handle door purchase
				local succ, err = pcall(function()
					House:purchase(player)
				end)

				if succ then
					prompt.ActionText = "Sell"
				else
					print(err)
				end
				debounce = false
			elseif prompt.ActionText == "Sell" then
                local succ, err = pcall(function()
					House:sell(player)
				end)

				if succ then
					prompt.ActionText = "Purchase"
				else
					print(err)
				end
				debounce = false
			end
		end
	end)

    House:setCanPurchase(true) --> Allow players to buy it
end

toggleHouseLockEvent.OnServerEvent:Connect(function(player)
	local playerData = PlayerDataParser:parseData(player)

	if playerData.house:get() then
		local Door = playerData.house:get():FindFirstChild("Door")
		if Door then
			Door.CanCollide = not Door.CanCollide
		end
	end
end)