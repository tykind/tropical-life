--> @Desc Quickly set up folder for player data
--> @Author Tykind
local Players = game:GetService('Players')

local function createValue(parent : Instance, type : string, name : string, defaultValue : any)
    local UnkValue = Instance.new(("%sValue"):format(type))

    UnkValue.Name = name
    
    if defaultValue then
        UnkValue.Value = defaultValue
    end
    
    UnkValue.Parent = parent
end

Players.PlayerAdded:Connect(function(player)
    local playerData = Instance.new("Folder", player)
    playerData.Name = "player data"

    createValue(playerData, "String", "role", "Parent")
end)