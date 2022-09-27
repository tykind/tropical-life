--> @Desc Bundle system
--> @Author Tykind
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local ServerStorage = game:GetService("ServerStorage")

local quickServerData = require(ServerStorage.Modules["quickData"])
local quickClientData = require(ReplicatedStorage.Modules['quickData'])

local PlayerDataParser = require(quickServerData.modules["Data parser"].Module)
local Bundles = require(quickClientData.modules['Bundle Ids'].Module)

local Remotes = ReplicatedStorage.Remotes
local setBundle : RemoteEvent = Remotes.Client.setBundle

local blockedProperties = {
    "DepthScale",
    "HeadScale",
    "HeightScale",
    "ProportionScale",
    "WidthScale"
}


---> @Section Utilities

local function safeCall(obj : Instance, what : string, ...)
    local succ, ret = pcall(obj[what], obj, ...)

    if not succ then
        print(("safe call err : %s"):format(ret))
        return
    end

    return ret
end

---> @Section Main handlers

local function verifyBundleId(player : Player, bundleId : number)
    for _, BundleInfo in pairs(Bundles) do
        if BundleInfo.Id == bundleId then --> @Info Bundle id was found, so it's verified

            --> @Info Get outfit Id

            local info = safeCall(AssetService, "GetBundleDetailsAsync", bundleId)
            local outfitId

		    if info then
                for _,item in pairs(info.Items) do
                    if item.Type == "UserOutfit" then
                        outfitId = item.Id
                        break
                    end
                end
            end

            --> @Info Now get humanoid description from the Id

            if outfitId then
                local bundle = safeCall(Players, "GetHumanoidDescriptionFromOutfitId", outfitId)

                if bundle then
                    --> @Info Verify price integrety
                    if BundleInfo.Price then
                        local playerData = PlayerDataParser:parseData(player)

                        if not(playerData.cash:get() >= BundleInfo.Price) then
                            break
                        end
                        playerData.cash:sub(BundleInfo.Price)
                    end
                    return bundle
                end
            end
            break
        end
    end
end

local function applyBundle(player : Player, bundleId : number)
    local bundle = verifyBundleId(player, bundleId)
    local character = player.Character

    if bundle and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            --> @Info Save important information

            local desc = humanoid:GetAppliedDescription()

            if desc then
                for _, v in pairs(blockedProperties) do
                    bundle[v] = desc[v]
                end
            end

            --> @Info Apply new description to player

            humanoid:ApplyDescription(bundle)
        end
    end
end

setBundle.OnServerEvent:Connect(function(player, bundleId : number)
    local coolDown = player:FindFirstChild("bundleCooldown")
    if not(coolDown) then
        local newCooldown = Instance.new("StringValue", player)
        newCooldown.Name = "bundleCooldown"
        applyBundle(player, bundleId)
        task.wait(5)
        newCooldown:Destroy()
    end
end)