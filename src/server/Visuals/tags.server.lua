--> @Desc Player tags handler
--> @Author Tykind
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local quickData = require(ServerStorage.Modules.quickData)

local ClientEvents = ReplicatedStorage.Remotes.Client
local TagFolder = workspace.BillboardGUI.User

local changeNickname : RemoteEvent = ClientEvents.changeNickname
local tag = require(quickData.modules["Tag system"].Module)

---> @Section Utilities

local function setPremiumTag(self : tag.tag, emoji : string) : boolean
    local displayName : TextLabel = self.TagObject.Display
    
    local foundPremiumEmoji = displayName:FindFirstChild("PremiumEmoji")

    if foundPremiumEmoji then
        foundPremiumEmoji.Value = emoji
    else
        local foundPremiumEmoji = Instance.new("StringValue", displayName)
        foundPremiumEmoji.Name = "PremiumEmoji"
        
        task.spawn(function()
            while true do task.wait(.5)
                if not(displayName.Text:find(foundPremiumEmoji.Value)) then
                    displayName.Text = ("%s %s"):format(displayName.Text, foundPremiumEmoji.Value)
                end
            end
        end)
    end

    return true
end

---> @Section Main handler
local setOfPeople = {}

Players.PlayerAdded:Connect(function(player)
    local userTag = tag.new(player, TagFolder)
    
    --> @Info Gamepass alteres on the tag
    userTag:gamepassAlterer(79793686, setPremiumTag, {"😎"})
    userTag:gamepassAlterer(79793731, setPremiumTag, {"👑"})

    table.insert(setOfPeople, {
        Player = player,
        UserTag = userTag
    })
end)

Players.PlayerRemoving:Connect(function(player)
    for i, info in pairs(setOfPeople) do
        local plr : Player = info[1]
        if plr == player then
            table.remove(setOfPeople, i)
        end
    end
end)

changeNickname.OnServerEvent:Connect(function(player : Player, to : string?)
    for _, info in pairs(setOfPeople) do
        local plr : Player, tag : tag.tag  = info.Player, info.UserTag
        if plr == player then
            return pcall(tag.setNickname, tag, to)
        end
    end
end)