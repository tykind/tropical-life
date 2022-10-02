--> @Desc Collision system
--> @Author Tykind
local PhysicsService = game:GetService('PhysicsService')
local Players = game:GetService("Players")

pcall(function()
	PhysicsService:CreateCollisionGroup('Players')
	PhysicsService:CollisionGroupSetCollidable('Players', 'Players', false)
end)

Players.PlayerAdded:Connect(function(Player)
	local char = Player.Character or Player.CharacterAdded:Wait()
	repeat task.wait() until char:FindFirstChild("Head")

	for _, BasePart in pairs(char:GetChildren()) do
		if(BasePart:IsA('BasePart')) then
			PhysicsService:SetPartCollisionGroup(BasePart, 'Players')
		end
	end

    Player.CharacterAdded:Connect(function(char)
		repeat task.wait() until char:FindFirstChild("Head")
		for _, BasePart in pairs(char:GetChildren()) do
			if(BasePart:IsA('BasePart')) then
				PhysicsService:SetPartCollisionGroup(BasePart, 'Players')
			end
		end
	end)
end)