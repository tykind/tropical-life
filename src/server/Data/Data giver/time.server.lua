--> @Desc: Data handler
--> @Author: Tykind
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local quickData = require(ServerStorage.Modules.quickData)

local datalib = require(quickData.modules["Data handler"].Module)
local logger = require(quickData.modules["Log system"].Module)

local playedTimeContext = logger.new("playedTime")
local playedTimeHandler = datalib.new({
	Global = true,
	DataStoreName = "[playedTime_v0]",
	KeyMask = "+-USERID-+",
	OnUpdate = function(what, ...)
		playedTimeContext:log(("Used %s"):format(what))
	end,
	Leaderboard = nil,
})

---> @Section Set up player playedTime
-------------

local Tasks = {}

local defaultplayedTime = 1
local playedTimePayoutTime = 60

Players.PlayerAdded:Connect(function(plr)
	local dataFolder = plr:WaitForChild("player data", 5)

	if dataFolder then
		local playedTime = Instance.new("NumberValue")
		playedTime.Name = "play time"
		playedTime.Parent = dataFolder --> We have to do it after (Reflective)

		local succ, value = pcall(function()
			return playedTimeHandler:Get(plr)
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
			playedTimeContext:log(tostring(value))
			return
		end

		--> @Info Set up playedTime lisener so it updates in the dataservice
		playedTime.Value = if not value or value <= 0 then defaultplayedTime else value

		task.spawn(function()
			task.desynchronize()
			while true do task.wait(playedTimePayoutTime)
				--> @Note Give money, but also check for multiplication gamepass
                playedTime.Value += 1
			end
			task.synchronize()
		end)

		task.spawn(function()
			task.desynchronize()
			while true do task.wait(120)
				playedTimeHandler:Set(plr, playedTime.Value)
			end
			task.synchronize()
		end)

		table.insert(Tasks, { plr, playedTime })
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	for idx, Task in next, Tasks do
		local p, playedTime = unpack(Task)
		if p == plr then
			pcall(playedTimeHandler.Set, playedTimeHandler, plr, playedTime.Value)
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
				local playedTime: NumberValue = dataFolder:FindFirstChild("play time")
				pcall(playedTimeHandler.Set, playedTimeHandler, plr, playedTime.Value)
			end
		end
		task.synchronize()
	end)
end)

local timeLeaderboard = Instance.new("Folder", ReplicatedStorage)
timeLeaderboard.Name = "timeLeaderboard"

playedTimeHandler:makeNumberLeaderboard(timeLeaderboard, 120, (function(key)
	return key:gsub("+%-", ""):gsub("%-%+", "")
end))