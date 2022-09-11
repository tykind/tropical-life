--> @Desc Quickly set up folder for player data
--> @Author Tykind
local Players = game:GetService('Players')
local allowReflectObj = {
    cash = {
        ReflectiveName = "[ Cash ]"
    },
}


local function createValue(parent : Instance, type : string, name : string, defaultValue : any)
    local UnkValue = Instance.new(("%sValue"):format(type))

    UnkValue.Name = name
    
    if defaultValue then
        UnkValue.Value = defaultValue
    end
    
    UnkValue.Parent = parent
end

Players.PlayerAdded:Connect(function(player)
    local playerData = Instance.new("Folder")
    playerData.Name = "player data"

    --> @Info Reflects data from playerData onto a public leaderstats

    local leaderStats = Instance.new("Folder", player)
    leaderStats.Name = "leaderstats"

    playerData.ChildAdded:Connect(function(obj)
        local reflectiveData = allowReflectObj[obj.Name]
        if reflectiveData then
            local clonedObj : Instance = obj:Clone()
            clonedObj.Parent = leaderStats
            clonedObj.Name = reflectiveData.ReflectiveName

            if obj:IsA("ValueBase") then
                obj:GetPropertyChangedSignal("Value"):Connect(function()
                    clonedObj.Value = obj.Value
                end)
            end
        end
    end)

    --> @Info Finish setup with player data folder

    playerData.Parent = player

    --> @Info Add objs to the folder, these aren't handle just yet.

    createValue(playerData, "String", "role", "Parent")
    createValue(playerData, "Object", "house")
end)