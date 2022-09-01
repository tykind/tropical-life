--> @Desc House item function
--> @Author Tykind
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local quickData = require(script.Parent.Parent.quickData)

local PlayerDataParser = require(quickData.modules['Data parser'].Module)
local QuickTypes = require(quickData.modules['Types'].Module)

---> @Section Basic functions

local house : QuickTypes.House = {
    Price = 0,
    Connections = {}
}
house.__index = house

function house.new(actualObject : Model, taxGen : (number) -> (number))
    local createHouse = setmetatable({
        TaxGenerator = taxGen,
        ObjectRef = actualObject,
        Identifier = HttpService:GenerateGUID(true)
    }, house)

    createHouse:setPublicConfig("Identifier", createHouse.Identifier)
    return createHouse
end

function house:setCanPurchase(boolean : boolean)
    self.CanPurchase = boolean 
end

function house:canBePurchased()
    return self.CanPurchase
end

function house:setResetFunction(resetFunc : (any...) -> () | nil)
    self.reset = resetFunc
end

function house:setSetupFunction(setupFunc : (any...) -> () | nil)
    self.setup = setupFunc
end

function house:setOwner(target : Player, onceLeft : (any...) -> () | nil)
    --> @Note Disconnect old connection if it exists
    if self.Connections["PlayerLeft"] then
        local conn : RBXScriptConnection = self.Connections["PlayerLeft"]
        self.Connections["PlayerLeft"] = nil

        conn:Disconnected()
    end

    self.Owner = target

    --> @Note Create connection and execute left
    self.Connections["PlayerLeft"] = Players.PlayerRemoving:Connect(function(plr)
        if plr == target then
            --> @Note now since the owner left we can also call the provided function
            self.Owner = nil
            
            if onceLeft then
                onceLeft(self, target)
            elseif (self.restart) then
                self.restart(self, target)
            end
        end
    end)
end

function house:setPublicConfig(name : string, value : any)
    local ObjectRefConfig = self.ObjectRef:FindFirstChildOfClass("Configuration")
    assert(ObjectRefConfig, "expected house configuration")

    ObjectRefConfig[name].Value = value
end

---> @Section Economics based

function house:generateTax()
    self.Tax = self.TaxGenerator(self.Price)

    self:setPublicConfig("Tax", self.Tax)
end

function house:getTax()
    return self.Tax
end

function house:purchase(target : Player, onceLeft : (any...) -> () | nil)
    assert(self.CanPurchase, "can't buy this")
    assert(self.Owner, "somebody already owns this") --> Just don't overwrite someone elses home

    --> @Note Now handle purchasing
    local data = PlayerDataParser:parseData(target)
    local fullPrice = self.Price + self:getTax()

    assert(data, "not loaded yet?")
    assert(fullPrice <= data.cash:get(), "not enough money")

   --> @Note Remove their money
   data.cash:sub(fullPrice) --> Remove money and tax the money
   self:setOwner(target, onceLeft)
   self.setup(self) --> Set up house stuff
end

function house:sell(target : Player)
    assert(target == self.Owner, "you aren't the owner")
    
    local data = PlayerDataParser:parseData(target)
    assert(data, "not loaded yet?")

    --> @Note give them a small percentage of the original price and remove ownership
    local afterPercentage = (self.Price * 80/100)
    data.cash:add(self.Price - afterPercentage)
    self.Owner = nil

    if (self.restart) then
        self.restart(self, target)
    end
end

return house