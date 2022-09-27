--> @Desc Tag system
--> @Author Tykind
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")

local playerTag = ServerStorage:FindFirstChild("PlayerTag")
local families = ReplicatedStorage.Families

---> @Section Library starter

export type tag = {
    Player: Player,
    Nickname: string?,
    Family: string?,
    TagObject: BillboardGui,

    new:  (player : Player, tagsFolder : Folder, ...any) -> tag,
    playerHasDisplayName: (self : tag) -> (),
    setDefaultNames: (self : tag) -> (),
    setNickname : (self : tag, to : string?) -> (),
    gamepassAlterer: (self : tag, gamepassId : number, func : (tag, ...any) -> boolean, args : {[number] : any}) -> ()
}

local tagsToRemove = {}
local tag : tag = {}
tag.__index = tag

function tag.new(player : Player, tagsFolder : Folder) : tag
    local tag = setmetatable({
        Player = player,
        TagObject = playerTag:Clone()
    }, tag)

    local clonedTag = tag.TagObject
    clonedTag.Name = tostring(player.UserId)
    clonedTag.Parent = tagsFolder

    tag:setDefaultNames() --> @Info Set the player name

    table.insert(tagsToRemove, {
        Player = player,
        ClonedTag = clonedTag
    })

    local function getHeight(head : BasePart, part : BasePart)
        local relative = part.Position - head.Position
	    local distance = head.CFrame.UpVector:Dot(relative)
	    local hatHeight = part.Size.Y / 2
	    return distance + hatHeight
    end

    local function characterSpawned(character : Model?)
        if character then
            local Head : MeshPart = character:WaitForChild("Head", 5)
            local Humanoid = character:FindFirstChildOfClass("Humanoid")

            Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

            if Head then
                local Tallest = 0
                
                for _, v in pairs(character:GetChildren()) do
                    if v:IsA("Accessory") then
                        local Handle = v:FindFirstAncestorWhichIsA("BasePart")
                        if Handle then
                            local Height = getHeight(Handle)

                            if Tallest < Height then
                                Tallest = Height
                            end
                        end
                    end
                end

                clonedTag.StudsOffset = Vector3.new(0, Tallest + 3.3, 0)
                task.wait()
                clonedTag.Adornee = character.Head
            end
        end
    end

    characterSpawned(player.Character or player.CharacterAdded:Wait())
    player.CharacterAdded:Connect(characterSpawned)

    ---> @Section Custom shit

    --> @SUBSEC Family tag
    local onParentLeftConn : RBXScriptConnection
    families.DescendantAdded:Connect(function(descendant)
        if not descendant:IsA("Folder") then
            if descendant.Name == tostring(tag.Player.UserId) then
                local OwnerName = tag:getPlayerNameInGame(tonumber(descendant.Parent.Name))
                clonedTag.Family.Text = ("%s's family"):format(OwnerName)
                clonedTag.Family.Visible = true

                onParentLeftConn = descendant.Parent.Destroying:Connect(function()
                    clonedTag.Family.Visible = false
                    onParentLeftConn:Disconnect()
                end)
            end
        end
    end)

    families.DescendantRemoving:Connect(function(descendant)
        if not descendant:IsA("Folder") then
            if descendant.Name == tostring(tag.Player.UserId) then
                clonedTag.Family.Visible = false

                if onParentLeftConn and onParentLeftConn.Connected then
                    onParentLeftConn:Disconnect()
                end
            end
        end
    end)

    return tag
end

function tag:playerHasDisplayName()
    return self.Player.Name ~= self.Player.DisplayName
end

function tag:getPlayerNameInGame(userId : number)
	local ourPlayer : Player = Players:GetPlayerByUserId(userId)
	local name = "Guest"
	
	if ourPlayer then
		name = if ourPlayer.Name ~= ourPlayer.DisplayName then ourPlayer.DisplayName else ourPlayer.Name		
	end
	
	return name
end

function tag:setDefaultNames()
    local userName : TextLabel = self.TagObject.Username
    local displayName : TextLabel = self.TagObject.Display
    
    displayName.Text = self.Player.DisplayName --> @Info Set player name

    --> @Info Check if the player has a display name and change
    if self:playerHasDisplayName() then
        userName.Text = ("@%s"):format(self.Player.Name)
        userName.Visible = true
    else
        userName.Visible = false
    end
end

function tag:filterTextSpace(str : string) : string
    local ret = str
    ret = string.gsub(ret, "^%s+", "")
    ret = string.gsub(ret, "%s+$", "")

    return ret
end

---> @Section Main workers

function tag:setNickname(to : string?)
    if not(to) or self:filterTextSpace(to) == "" then
        --> Return to default
        self:setDefaultNames()
        return
    end
    assert(#to <= 20, "nickname exceeded max length (20)")

    local userName : TextLabel = self.TagObject.Username
    local displayName : TextLabel = self.TagObject.Display

    local succ, filteredTextObject = pcall(TextService.FilterStringAsync, TextService, to, self.Player.UserId, Enum.TextFilterContext.PublicChat)
    if not succ then return end

    local succ, filteredText = pcall(filteredTextObject.GetNonChatStringForBroadcastAsync, filteredTextObject)

    if succ then
        self.Nickname = filteredText
    
        --> @Info Check custom Nickname and give player display name property
        displayName.Text = self.Nickname
        userName.Text = ("@%s"):format(self.Player.Name)
        userName.Visible = true
    end
end

function tag:gamepassAlterer(gamepassId : number, func : (tag, ...any) -> boolean, args : {[number] : any})
    task.wait(.1)
    task.spawn(function()
        local shouldBreak
        local function mainLoop()
            local succ, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, self.Player.UserId, gamepassId)

            if succ then
                if owns and func(self, unpack(args)) then
                    shouldBreak = true --> Executed gamepass sucessfully
                end
            end
        end

        mainLoop()

        while true do task.wait(10)
           if shouldBreak then
            break
           end

           mainLoop()
        end
    end)
end

Players.PlayerRemoving:Connect(function(player)
    for i, v in pairs(tagsToRemove) do
        if v.Player == player then
            v.ClonedTag:Destroy()
            table.remove(tagsToRemove, i)
        end
    end
end)

return tag