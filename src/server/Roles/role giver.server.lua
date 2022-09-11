-- @Desc Give roles to players when they step on pads
-- @Author Tykind
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local quickPrivateData = require(ServerStorage.Modules.quickData)
local quickPublicData = require(ReplicatedStorage.Modules.quickData)

local rolesBody = require(quickPrivateData.modules["Role body"].Module)
local dataParser = require(quickPublicData.modules["Data parser"].Module)

local Teams = game:GetService("Teams")

---> @Section Additional utilities

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
						task.spawn(function()
							rolesBody:normalScale(target, char, scalingPercent)
						end)
						target:LoadCharacter()
						playerData.role:set(roleName)

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