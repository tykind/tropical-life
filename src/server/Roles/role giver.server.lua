-- @Desc Give roles to players when they step on pads
-- @Author Tykind
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local quickPrivateData = require(ServerStorage.Modules.quickData)
local quickPublicData = require(ReplicatedStorage.Modules.quickData)

local dataParser = require(quickPublicData.modules["Data parser"].Module)

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

for _, pad in pairs(rolePadsFolder:GetChildren()) do
    local touchPart : Part = pad:FindFirstChild("Touch")
	local roleName : StringValue = touchPart:FindFirstChild("roleName")
    touchPart.Touched:Connect(function(otherPart)
        --> Check if a player was touched :flushed:
        local target, char = getPlayerFromPart(otherPart)
        if target then
            local playerData = dataParser:parseData(target)
            
			if playerData.role:get() ~= roleName then
				playerData.role:set(roleName.Value)
				-- Set body configurations
			end
        end
    end)
end