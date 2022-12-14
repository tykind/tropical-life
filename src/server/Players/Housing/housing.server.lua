--> @Desc Housing system set up
--> @Author Tykind
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local quickData = require(ServerStorage.Modules["quickData"])
local Remotes = ReplicatedStorage.Remotes

local PlayerDataParser = require(quickData.modules["Data parser"].Module)
local Housing = require(quickData.modules["Housing"].Module)
local quickTypes = require(quickData.modules.Types.Module)

local houseEvent : RemoteEvent = Remotes.Client.houseEvent
local houseInvitation : RemoteEvent = Remotes.Server.houseInvitation

---> @Section Housing constants

local rnd = Random.new(tick() * 1000) --> 1000 random offset
local maxTaxPercentage = 20
local hpReqActive, lasthpReqTime = false, nil

---> @Section Create all houses

local function taxGenerator(housePrice)
	return housePrice - (housePrice - (housePrice * (rnd:NextInteger(1, maxTaxPercentage) / 100)))
end

for _, HouseObj in pairs(workspace.Houses:GetChildren()) do
	local House = Housing:createHouse(HouseObj, taxGenerator)
	House:generateTax()

	local DoorPrompt: ProximityPrompt = HouseObj.Door.DoorInteraction
	local BirthdayHat : MeshPart = HouseObj:FindFirstChild("Birthday Hat")

	--> @Note Add liseners to the houses

	local debounce
	ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		if prompt == DoorPrompt then
			if not(debounce) then
				debounce = true
				if prompt.ActionText == "Purchase" then
					--> Handle door purchase
					local succ, err = pcall(function()
						House:purchase(player)
					end)
	
					if succ then
						prompt.Enabled = false
					else
						House:setCanPurchase(true)
					end

					debounce = false
				end
			end
		end

		if BirthdayHat and not(hpReqActive) and #Players:GetPlayers() > 1 and BirthdayHat.throwParty == prompt then
			local EndLocation : Part = BirthdayHat.to
			
			--> Verify integrity of house request
			local requestVerified = true

			if House.Owner ~= player then
				requestVerified = false
			end

			if lasthpReqTime and tick() - lasthpReqTime < 15 then
				requestVerified = false
			end

			if requestVerified then
				--> @Info Request was verified so it's OKAY to proceed
				hpReqActive = true
				lasthpReqTime = tick()
				houseInvitation:FireAllClients(player.UserId, EndLocation.Position)
				task.wait(17)

				hpReqActive = false
			end
		end
	end)

	--> @Info Manual fix for house not setting owner (Temp) Owner
	local config = HouseObj.Configuration
	local OwnerValue : NumberValue = config.Owner

	OwnerValue:GetPropertyChangedSignal("Value"):Connect(function()
		if OwnerValue.Value == 0 then
			--> @Info Changed to default, we'll wait for process see if it resets....
			local start = tick()
			while true do task.wait()
				if tick() - start > 2 then
					--> @Info Proceed to reset house manually
					House:setOwner(nil)
					if House.reset then
						House.reset(House) --> @Info Should handle if player is not there
					end

					House:setCanPurchase(true) --> Allow players to buy it
					break
				end

				--> @Info Check if the thing actually executed
				if DoorPrompt.Enabled then
					break	
				end
			end
		end
	end)

	--> @Info Assist Manual Fix

	task.spawn(function()
		while true do task.wait()
			local oldId = OwnerValue.Value
			if OwnerValue.Value ~= 0 and not(Players:GetPlayerByUserId(oldId)) then
				OwnerValue.Value = 0
				House:removeGlobalCache(oldId)
			end
		end
	end)

    House:setCanPurchase(true) --> Allow players to buy it
end

---> @Section Handle house even stuff

houseEvent.OnServerEvent:Connect(function(player, eventName : string)
	if #eventName > 20 then return end --> Security reason
	local playerData = PlayerDataParser:parseData(player)

	if playerData.house:get() then
		if eventName == "lock" then
			local Door = playerData.house:get():FindFirstChild("Door")
			if Door then
				Door.CanCollide = not Door.CanCollide
			end
			return "locked house"
		elseif eventName == "sell" then
			--> @Info Find our house object
			local House = Housing:getHouseFromPlayer(player)
			if House then
				return pcall(House.sell, House, player)
			end
		end
	end
end)