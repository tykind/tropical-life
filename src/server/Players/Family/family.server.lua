--> @Desc Family system
--> @Author Tykind
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes
local familyRequest : RemoteEvent = Remotes.Client.familyRequest

local familiesFolder = ReplicatedStorage.Families

--> @Section Helper functions
local function ifFamilyLess(who : number, careToBeMember : boolean?, callback : () -> ())
    if not(familiesFolder:FindFirstChild(tostring(who))) then
        local found
       
        if careToBeMember then
            for _, o in pairs(familiesFolder:GetChildren()) do
                for _, v in pairs(o:GetChildren()) do
                    if v.Name == tostring(who) then
                        found = true
                        break
                    end
                end
            end
        else
            found = true
        end

        if not found then
            callback()
        end
    end
end

local function getPlayerFromId(who : number)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.UserId == who then
            return plr
        end
    end
end

--> @Section Main system
local tasks = {}
local actions = {
    create = (function(player : Player, who : number?)
        ifFamilyLess(player.UserId, true, function()
            --> @Info Create new family
            if not player:FindFirstChild("Waiting for family request") then
                local newFamily = Instance.new("Folder", familiesFolder)
                newFamily.Name = player.UserId
    
                table.insert(tasks, {
                    Player = player,
                    func = (function()
                        newFamily:Destroy()
                    end)
                })
            end
        end)
    end),
    join = (function(player : Player, who : number?)
        ifFamilyLess(player.UserId, true, function()
            --> @Info Check if family exists
            if familiesFolder:FindFirstChild(tostring(who)) and not player:FindFirstChild("Waiting for family request") then
                local owner = getPlayerFromId(who)

                if owner and not(owner:FindFirstChild("Family Request")) then
                    local requestRemote = Instance.new("RemoteEvent", owner)
                    requestRemote.Name = "Family Request"
                    
                    local accepted
                    local requestRemoteConn
                    requestRemoteConn = requestRemote.OnServerEvent:Connect(function(player, wasAccepted : boolean)
                        if type(wasAccepted) == "boolean" then
                            accepted = wasAccepted
                            requestRemoteConn:Disconnect()
                        end
                    end)

                    --> @Info wait lol

                    local booleanValue = Instance.new("BoolValue", player)
                    booleanValue.Name = "Waiting to join family"

                    --> @Info Give the player capabilities UI
                    local Handler = ServerStorage.AcceptFamily:Clone()
                    Handler.Parent = owner.PlayerGui
                    Handler.Enabled = true

                    local start = tick()
                    while true do task.wait()
                        if accepted or tick() - start > 15 then
                            break
                        end
                    end

                    requestRemote:Destroy()
                    Handler:Destroy()

                    local toPut = familiesFolder:FindFirstChild(tostring(who))
                    if accepted and toPut then
                        local newMember = Instance.new("ObjectValue")
                        newMember.Name = tostring(player.UserId)
                        newMember.Parent = toPut
                        newMember.Value = player
                    else
                        task.wait(15) --> Wait for the next request
                    end

                    booleanValue:Destroy()
                end
            end
        end)
    end),
    destroy = (function(player : Player, who : number?)
        local ourFamily = familiesFolder:FindFirstChild(tostring(player.UserId))
        if ourFamily then
            ourFamily:Destroy()
        end
    end),
    leave = (function(player : Player, who : number?)
        if not player:FindFirstChild("Waiting for family request") then
            local toPut = familiesFolder:FindFirstChild(tostring(who))
            if toPut then
                local member = toPut:FindFirstChild(tostring(player.UserId))
                if member then
                    member:Destroy()
                end
            end
        end
    end)
}

familyRequest.OnServerEvent:Connect(function(player, actionName : string?, who : number?)
    if #actionName > 20 then return end

    local action = actions[actionName]
    print(actionName, who)
    if action then
        action(player, who)
    end
end)