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

Players.PlayerAdded:Connect(function(player)
    local userTag = tag.new(player, TagFolder)
    
    --> @Info Gamepass alteres on the tag
    userTag:gamepassAlterer(79793686, setPremiumTag, {"😎"})
    userTag:gamepassAlterer(79793731, setPremiumTag, {"👑"})

    --> @Info Nicknames

    changeNickname.OnServerEvent:Connect(function(player : Player, to : string?)
        return pcall(userTag.setNickname, userTag, to)
    end)
end)