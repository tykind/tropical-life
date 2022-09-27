-- @Desc Give roles to players when they step on pads
-- @Author Tykind
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local quickPrivateData = require(ServerStorage.Modules.quickData)
local quickPublicData = require(ReplicatedStorage.Modules.quickData)

local rolesBody = require(quickPrivateData.modules["Role body"].Module)
local dataParser = require(quickPublicData.modules["Data parser"].Module)

local Tools = ServerStorage:WaitForChild("Tools", 5)

local Teams = game:GetService("Teams")
local roleTools = {
	["Parent"] = {
		"Stroller"
	}
}

---> @Section Additional utilities

local function toolNotFound(plr : Player, name : string)
	--> @Info First test
	for _, toolName in pairs(plr.Backpack:GetChildren()) do
		if toolName == name then
			return
		end
	end

	--> @Info Second test
	local Character = plr.Character
	if Character then
		for _, Obj in pairs(Character:GetDescendants()) do
			if Obj:IsA("Tool") and Obj.Name == name then
				return
			end
		end
	end

	return true
end

local function giveTool(plr : Player, role : string)
	local toGiveList = roleTools[role]
	if toGiveList then
		for _, tool in pairs(Tools:GetChildren()) do
			if table.find(toGiveList, tool.Name) and toolNotFound(plr, tool.Name) then
				local t = tool:Clone()
				t.Parent = plr.Backpack
			end
		end
	end
end

local function isCharacter(obj)
	while true do task.wait() 
		if obj:IsA("Workspace") then
			return
		end
		
		if not(obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid")) then
			obj = obj.Parent
			continue
		end
		
		return obj
	end
end

local function getPlayerFromPart(part : Part)
	local Character = isCharacter(part)
	if Character then
		local target = Players:GetPlayerFromCharacter(Character)

		if target then
			return target, Character
		end
	end
end

---> @Section Go through all pads and add liseners to touched events
local rolePadsFolder = workspace:FindFirstChild("Role pads")
local playerConnections = {}

for _, pad in pairs(rolePadsFolder:GetChildren()) do
    local touchPart : Part = pad:FindFirstChild("Touch")
	local roleName : string = touchPart:FindFirstChild("roleName").Value
    touchPart.Touched:Connect(function(otherPart)
        --> Check if a player was touched :flushed:
        local target, char = getPlayerFromPart(otherPart)

        if target then
            local playerData = dataParser:parseData(target)
            
			--> @ADD_SIGNAL_WHEN_DIED
			if not(playerConnections[target.UserId]) or not(playerConnections[target.UserId].CharacterAdded) then
				if not playerConnections[target.UserId] then
					playerConnections[target.UserId] = {}
				end
				playerConnections[target.UserId].CharacterAdded = target.CharacterAdded:Connect(function()
					target.Team =  Teams:FindFirstChild("Parent")
					playerData.role:set("Parent") --> @SET_PARENT_DEFAULT
					task.wait(.3)
					giveTool(target, "Parent")
				end)
			end

			if not(playerData.role:get() == roleName) then --> @IGNORE_BABY_PLAYERS
				local teamObj = Teams:FindFirstChild(roleName)
				playerData.role:set(roleName)
				-- Set body configurations
			-->	if roleName == "Baby" then
					--> Make baby
					-->task.spawn(function()
					-->	rolesBody:makeBaby(target, char)
					-->end)
					-->target:LoadCharacter()
					-->playerData.role:set(roleName)
				-->else
					--> Scale avatar
					--> @CHANGE_PLAYER_SCALE
					local scalingPercent = rolesBody.scaling[roleName]
					if scalingPercent then
						-- task.spawn(function()
							rolesBody:normalScale(target, char, scalingPercent)
						-- end)
						-- target:LoadCharacter()
						-- playerData.role:set(roleName)

						--> @GIVE_TOOL
						giveTool(target, roleName)

						--> @SET_PLAYER_TEAM
						if teamObj then
							target.Team = teamObj
						end
					end
			-->	end
			end
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Wait()
	giveTool(player, "Parent")
end)