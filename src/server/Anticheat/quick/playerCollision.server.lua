local PhysicsService = game:GetService('PhysicsService')

	pcall(function()
		local CollideGroup = PhysicsService:CreateCollisionGroup('Players')
		PhysicsService:CollisionGroupSetCollidable('Players','Players',false)
	end)

game:GetService('Players').PlayerAdded:Connect(function(Player)
	local CHARACTER = Player.Character or Player.CharacterAdded:Wait()
	task.wait(0.2)
	for Index,BasePart in pairs(CHARACTER:GetChildren()) do
		if(BasePart:IsA('BasePart')) then
			PhysicsService:SetPartCollisionGroup(BasePart,'Players')
		end
	end
    Player.CharacterAdded:Connect(function(Character)
	task.wait(0.2)
	for Index,BasePart in pairs(Character:GetChildren()) do
		if(BasePart:IsA('BasePart')) then
			PhysicsService:SetPartCollisionGroup(BasePart,'Players')
		end
		end
	end)
end)