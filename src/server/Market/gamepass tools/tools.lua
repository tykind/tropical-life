--> @Desc Gives tools connected to gamepasses
--> @Author Tykind and forbrad
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Tools = ServerStorage.Tools

---> @Section Main handler


local toollist = {}

local function addtool(player, tool)
	
	local permanentTool = tool:Clone()
	permanentTool.Parent = player:WaitForChild("StarterGear", 5)

	local backpackTool = tool:Clone()
	backpackTool.Parent = player.Backpack

end

Players.PlayerAdded:Connect(function(player) 
	toollist[player.UserId] = Tools:GetChildren()
	for idx, tool in pairs(toollist[player.UserId]) do
		if not tool:FindFirstChild("gamepassId") then
			table.remove(toollist[player.UserId], idx)     
		else
			if MarketplaceService:UserOwnsGamePassAsync(player.UserId, tool.gamepassId.Value) then
				addtool(player, tool)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player) 
	toollist[player.UserId]  = nil 
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, pass_id, was_purchased)
	if was_purchased then
		for _, tool in pairs(toollist[player.UserId]) do
			if tool.gamepassId.Value == pass_id then
				addtool(player, tool)
			end
		end
	end
end)