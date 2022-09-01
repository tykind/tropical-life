--> @Desc Quickly set up folder for player data
--> @Author Tykind
local Players = game:GetService('Players')

Players.PlayerAdded:Connect(function(player)
    local playerData = Instance.new("Folder", player)
    playerData.Name = "player data"
end)