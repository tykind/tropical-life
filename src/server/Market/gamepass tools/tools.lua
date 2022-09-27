--> @Desc Gives tools connected to gamepasses
--> @Author Tykind
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Tools = ServerStorage.Tools

---> @Section Main handler

local function toolCheck(player : Player, ourToolList : {[number] : Tool})
    for idx, tool : Tool in pairs(ourToolList) do
        local gamepassValue : NumberValue = tool:FindFirstChild("gamepassId")

        if MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassValue.Value) then
            --> @Info Make the player accquire the tools
            local permanentTool = tool:Clone()
            permanentTool.Parent = player:WaitForChild("StarterGear", 5)

            local backpackTool = tool:Clone()
            backpackTool.Parent = player.Backpack
            
            table.remove(ourToolList, idx)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    local ourToolList = Tools:GetChildren()
    
    --> @Info Filter tools
    for idx, tool in pairs(ourToolList) do
        if not tool:FindFirstChild("gamepassId") then
            table.remove(ourToolList, idx)            
        end
    end

    toolCheck(player, ourToolList) --> @Info Quick now

    while true do task.wait(5)
        if #ourToolList == 0 then
            break
        end
        toolCheck(player, ourToolList)
    end
end)