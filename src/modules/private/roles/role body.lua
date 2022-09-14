--> @Desc Shapes the body of the player to role (Baby, Parent, ...)
--> @Author Tykind

---> @Section Setting up library

local rolebody = {
    scaling = {
        ["Teenager"] = .9,
        ["Kid"] = .7,
        ["Parent"] = 1,
        ["Baby"] = .5
    },
    babyImportantParts = {
        "Torso",
        "Head",
        "Baby Torso",
        "UpperTorso",
        "LowerTorso",
        "HumanoidRootPart"
    },
    oldHumanoidDescriptions = {}
}

function rolebody:babyFakeTorso(character, torso, head)
    local babyTorso = Instance.new("Part")
    babyTorso.Name = "Baby Torso"

    babyTorso.BrickColor = BrickColor.new(1)
    babyTorso.formFactor = "Symmetric"

    babyTorso.Size = Vector3.new(1,1,1)
	babyTorso.Position = torso.Position

    babyTorso.Parent = character

    local Weld0 = Instance.new("Weld", torso)
    Weld0.Part0 = torso
    Weld0.Part1 = babyTorso
    Weld0.C1 = CFrame.new(0, 0.25, 0)

    local Weld1 = Instance.new("Weld", torso)
    Weld1.Part0 = torso
    Weld1.Part1 = head
    Weld1.C1 = CFrame.new(0, -0.8, 0)

    local bodymesh = Instance.new("SpecialMesh", babyTorso)
	bodymesh.Scale = Vector3.new(1.2, 1.5, 1.2)
end

---> @Section Main functions

function rolebody:normalScale(player : Player, character : Model, percent : number)
    -- local oldCFrame = character.PrimaryPart.CFrame

    -- character = player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 5)
  
    -- if humanoid.RigType == Enum.HumanoidRigType.R6 then --> @HANDLE_R6_SCALING
    --     for _, obj in pairs(character:GetDescendants()) do
    --         if obj:IsA("Motor6D") then
    --             obj.C0 = CFrame.new((obj.C0.Position * percent)) * (obj.C0 - obj.C0.Position)
	-- 		    obj.C1 = CFrame.new((obj.C1.Position * percent)) * (obj.C1 - obj.C1.Position)
    --         end
    --     end
		
	-- 	for _, obj in pairs(character:GetDescendants()) do
	-- 		if obj:IsA("BasePart") then
    --             obj.Size = obj.Size * percent
    --         elseif(obj:IsA("Accessory")) then
    --             obj.Handle.AccessoryWeld.C0 = CFrame.new((obj.Handle.AccessoryWeld.C0.Position * percent)) * 
    --                 (obj.Handle.AccessoryWeld.C0 - obj.Handle.AccessoryWeld.C0.Position)
                    
    --             obj.Handle.AccessoryWeld.C1 = CFrame.new((obj.Handle.AccessoryWeld.C1.Position * percent)) * 
    --                 (obj.Handle.AccessoryWeld.C1 - obj.Handle.AccessoryWeld.C1.Position)

    --             obj.Handle.Mesh.Scale *= percent	
    --         end
	-- 	end
    -- elseif(humanoid.RigType == Enum.HumanoidRigType.R15) then --> @HANDLE_R15_SCALING
		local desc = humanoid:GetAppliedDescription()
        local scaleNumber = .9 * percent --> 1 being the default scale
       

		desc.DepthScale = scaleNumber
		desc.HeadScale = scaleNumber
		desc.HeightScale = scaleNumber
		desc.ProportionScale = scaleNumber
		desc.WidthScale = scaleNumber

		humanoid:ApplyDescription(desc)
    -- end
    -- character.HumanoidRootPart.CFrame = oldCFrame
end

function rolebody:makeBaby(player : Player, character : Model)
    local oldCFrame = character.PrimaryPart.CFrame

    character = player.CharacterAdded:Wait()
    repeat task.wait() until character:FindFirstChild("Head")

    local humanoid = character:WaitForChild("Humanoid", 5)

    if character:FindFirstChild("Baby Torso") then
        return
    end

    if humanoid.RigType == Enum.HumanoidRigType.R6 then --> @HANDLE_BABY_MORPHING
        local Head : BasePart, Torso : BasePart = character:FindFirstChild("Head"), character:FindFirstChild("Torso")

        --> @HEAD_SCALING & @TORSO_PROPS
        Head:FindFirstChildOfClass("SpecialMesh").Scale = Vector3.new(1, 1, 1)
        Torso.Transparency = 1
        Torso.CanCollide = false

        --> @CREATE_FACE_TORSO
        self:babyFakeTorso(character, Torso, Head)
    elseif(humanoid.RigType == Enum.HumanoidRigType.R15) then
        local Head : BasePart, Torso0, Torso1 : BasePart = character:FindFirstChild("Head"), character:FindFirstChild("LowerTorso"), character:FindFirstChild("UpperTorso")

        
        --> @HEAD_SCALING & @TORSO_PROPS
        local Mesh = Head:FindFirstChildOfClass("SpecialMesh")
        if Mesh then
            Mesh.Scale = Vector3.new(1, 1, 1)
        end
    
        humanoid.AutomaticScalingEnabled = false

        Torso0.Transparency = 1
        Torso0.CanCollide = false

        Torso1.Transparency = 1
        Torso1.CanCollide = false

        --> @CREATE_FACE_TORSO
        self:babyFakeTorso(character, Torso0, Head)
    end

     --> @REMOVE_LIBS
     for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("BasePart") and not(table.find(self.babyImportantParts, obj.Name)) then
            obj:Destroy()
        end
    end
    character.HumanoidRootPart.CFrame = oldCFrame
end

return rolebody