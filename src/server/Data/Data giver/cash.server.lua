--> @Desc: Data handler
--> @Author: Tykind
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")

local quickData = require(ServerStorage.Modules.quickData)

local datalib = require(quickData.modules["Data handler"].Module)
local logger = require(quickData.modules["Log system"].Module)

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

---> @Section Set up player cash
-------------

local Tasks = {}

local defaultCash = 250
local cashPayoutTime = 120

local twoTimesCashGamepass = 79792768

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
			task.desynchronize()
			while true do task.wait(cashPayoutTime)
				--> @Note Give money, but also check for multiplication gamepass
				local receivedMoney = 10
				if MarketplaceService:UserOwnsGamePassAsync(plr.UserId, twoTimesCashGamepass) then
					receivedMoney *= 2
				end
                cash.Value += receivedMoney
			end
			task.synchronize()
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
