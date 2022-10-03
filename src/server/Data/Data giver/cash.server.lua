--> @Desc: Data handler
--> @Author: Tykind
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local quickData = require(ServerStorage.Modules.quickData)

local datalib = require(quickData.modules["Data handler"].Module)
local logger = require(quickData.modules["Log system"].Module)
local plrdataparser = require(quickData.modules["Data parser"].Module)

local cashContext = logger.new("CASH")
local cashHandler = datalib.new({
	Global = true,
	DataStoreName = "[cash_v0]",
	KeyMask = "+-USERID-+",
	OnUpdate = function(what, ...)
		cashContext:log(("Used %s"):format(what))
	end,
	Leaderboard = nil,
})

local rewardContext = logger.new("REWARD")
local simpleDailyReward = datalib.new({
	Global = false,
	DataStoreName = "dailyReward_v0",
	KeyMask = "User-USERID",
	OnUpdate = function(what, ...)
		rewardContext:log(("Used %s"):format(what))
	end,
	Leaderboard = nil,
})

---> @Section Set up player cash
-------------

local Tasks = {}
local rewardInfo = {
	Default = 500,
	GroupPeople = 1500
}

local defaultCash = 250
local cashPayoutTime = 120
local specialGroup = 9674247

local twoTimesCashGamepass = 79792768
local families = ReplicatedStorage.Families

local Remotes = ReplicatedStorage.Remotes
local dailyReward = Remotes.Server.dailyReward


--> @Utils
local function safeCall(obj : Instance, what : string, ...)
    local succ, ret = pcall(obj[what], obj, ...)

    if not succ then
        print(("safe call err : %s"):format(ret))
        return
    end

    return ret
end

--> @Main code

Players.PlayerAdded:Connect(function(plr)
	local dataFolder = plr:WaitForChild("player data", 5)

	if dataFolder then
		local cash = Instance.new("NumberValue")
		cash.Name = "cash"
		cash.Parent = dataFolder --> We have to do it after (Reflective)

		local succ, value = pcall(function()
			return cashHandler:Get(plr)
		end)

		--> @Info If the data service errors, we'll force the player to rejoin

		if not succ then
			--> @FORCE_REJOIN
			if not (RunService:IsStudio()) then
				if #Players:GetPlayers() == 1 then
					TeleportService:Teleport(game.PlaceId, plr)
				else
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
				end
			end
			cashContext:log(tostring(value))
			return
		end

		--> @Info Set up cash lisener so it updates in the dataservice
		cash.Value = if not value or value <= 0 then defaultCash else value

		task.spawn(function()
			local familyOwner

			families.DescendantAdded:Connect(function(descendant)
				if not descendant:IsA("Folder") then
					if descendant.Name == tostring(plr.UserId) then --> @Info our player is a member
						familyOwner = Players:GetPlayerByUserId(tonumber(descendant.Parent.Name))
					end
				end
			end)

			families.DescendantRemoving:Connect(function(descendant)
				if not descendant:IsA("Folder") then
					if descendant.Name == tostring(plr.UserId) then --> @Info our player is a member
						familyOwner = nil
					end
				end
			end)

			task.desynchronize()
			while true do task.wait(cashPayoutTime)
				--> @Note Give money, but also check for multiplication gamepass
				local receivedMoney = 10
				if MarketplaceService:UserOwnsGamePassAsync(plr.UserId, twoTimesCashGamepass) then
					receivedMoney *= 2
				end
                cash.Value += receivedMoney

				--> @Special Give to family members
				if not familyOwner then
					local ourFamily = families:FindFirstChild(tostring((plr.UserId)))
					if ourFamily then
						for _, memberPtr : ObjectValue in pairs(ourFamily:GetChildren()) do
							local memberData = plrdataparser:parseData(memberPtr.Value)
							memberData.cash:add(receivedMoney / 2) --> @Info Give 50% to family as well
						end
					end
				else
					local ownerData = plrdataparser:parseData(familyOwner)
					ownerData.cash:add(receivedMoney / 2)
				end
			end
			task.synchronize()
		end)

		--> Give daily reward
		task.spawn(function()
			local function giveReward()
				local succ, lastTime = pcall(function()
					return simpleDailyReward:Get(plr)
				end) 
		
		
				if succ and not(lastTime) or (tick() - lastTime) > 86400 then
					--> Just give and set new
					local amount = if safeCall(plr, "IsInGroup", specialGroup) then rewardInfo.GroupPeople else rewardInfo.Default
					
					cash.Value += amount
					dailyReward:FireClient(plr, amount)
					safeCall(simpleDailyReward, "Set", plr, tick())
				end
			end

			giveReward()

			while true do task.wait(86401) --> lol
				giveReward()
			end
		end)

		table.insert(Tasks, { plr, cash })
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	for idx, Task in next, Tasks do
		local p, cash = unpack(Task)
		if p == plr then
			pcall(cashHandler.Set, cashHandler, plr, cash.Value)
			table.remove(Tasks, idx)
			break
		end
	end
end)

game:BindToClose(function()
	task.spawn(function()
		task.desynchronize()
		for _, plr in pairs(Players:GetPlayers()) do
			local dataFolder = plr:WaitForChild("player data")
			if dataFolder then
				local cash: NumberValue = dataFolder:FindFirstChild("cash")
				pcall(cashHandler.Set, cashHandler, plr, cash.Value)
			end
		end
		task.synchronize()
	end)
end)

local cashLeaderboard = Instance.new("Folder", ReplicatedStorage)
cashLeaderboard.Name = "cashLeaderboard"

cashHandler:makeNumberLeaderboard(cashLeaderboard, 6, 120, (function(key)
	return key:gsub("+%-", ""):gsub("%-%+", "")
end))