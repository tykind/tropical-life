--> @Desc Avatar handling system
--> @Author Tykind
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local clientRemotes = Remotes.Client

local giveClothing : RemoteEvent = clientRemotes.giveClothing