--> @Desc House item function
--> @Author Tykind
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local quickData = require(script.Parent.Parent.quickData)

local PlayerDataParser = require(quickData.modules["Data parser"].Module)
local QuickTypes = require(quickData.modules["Types"].Module)

---> @Section Basic functions

local house: QuickTypes.House = {
	Price = 0,
	Connections = {},
	OnSell = {},
	OnBuy = {}
}
house.__index = house

function house.new(actualObject: Model, taxGen: (number) -> (number))
	local createHouse = setmetatable({
		TaxGenerator = taxGen,
		ObjectRef = actualObject,
		Identifier = HttpService:GenerateGUID(true),
	}, house)

    for _, houseFunctions in pairs(script.Parent.functions:GetChildren()) do
        if houseFunctions.Name == actualObject.Configuration.Class.Value then
            local funcs = require(houseFunctions)

            createHouse.setup = funcs.setup
            createHouse.reset = funcs.reset
        end
    end

	createHouse:setPublicConfig("Identifier", createHouse.Identifier)
	return createHouse
end

function house:setCanPurchase(boolean: boolean)
	self.CanPurchase = boolean
end

function house:canBePurchased()
	return self.CanPurchase
end

function house:setResetFunction(resetFunc: (any...) -> () | nil)
	self.reset = resetFunc
end

function house:setSetupFunction(setupFunc: (any...) -> () | nil)
	self.setup = setupFunc
end

function house:setOwner(target: Player, onceLeft: (any...) -> () | nil)
	--> @Info Disconnect old connection if it exists
	self.Owner = target

	--> @Info Create connection and execute left
	self.Connections["PlayerLeft"] = Players.PlayerRemoving:Connect(function(plr)
		if plr == target then
			--> @Info now since the owner left we can also call the provided function
			self.Owner = nil

			if onceLeft then
				onceLeft(self, target)
			elseif self.reset then
				self.reset(self, target)
			end
		end
	end)
end

function house:setPublicConfig(name: string, value: any)
	local ObjectRefConfig = self.ObjectRef:FindFirstChildOfClass("Configuration")
	assert(ObjectRefConfig, "expected property configuration")
	ObjectRefConfig[name].Value = value
end

function house:onSell(callback, ...)
	table.insert(self.OnSell, callback)
end

function house:onBuy(callback, ...)
	table.insert(self.OnBuy, callback)
end

---> @Section Economics based

function house:generateTax()
	self.Tax = self.TaxGenerator(self.Price)

	self:setPublicConfig("Tax", self.Tax)
end

function house:getTax()
	return self.Tax
end

function house:purchase(target: Player, onceLeft: (any...) -> () | nil)
	assert(self.CanPurchase, "can't buy this")
	assert(not(self.Owner), "somebody already owns this") --> Just don't overwrite someone elses home

	--> @Info Now handle purchasing
	local data = PlayerDataParser:parseData(target)
	local fullPrice = self.Price

	assert(data, "not loaded yet?")
    assert(not(data.house:get()), "You already own a property")
	assert(fullPrice <= data.cash:get(), "not enough money")

	--> @Info Remove their money and set their house reference
	data.cash:sub(fullPrice) --> Remove money
	data.house:set(self.ObjectRef) --> Give them house reference

	self:setOwner(target, onceLeft)
	self.setup(self) --> Set up house stuff

	for _, funcs in pairs(self.OnBuy) do
		funcs()
	end
end

function house:sell(target: Player)
	assert(target == self.Owner, "you aren't the owner")

	local data = PlayerDataParser:parseData(target)
	assert(data, "not loaded yet?")

	--> @Info give them a small percentage of the original price and remove ownership
	local afterPercentage = (self.Price * 80 / 100)

	data.cash:add(self.Price - afterPercentage)
	data.house:set(nil)

	if self.Connections["PlayerLeft"] then
		local conn: RBXScriptConnection = self.Connections["PlayerLeft"]
		self.Connections["PlayerLeft"] = nil

		conn:Disconnect()
	end

	self.Owner = nil

	for _, funcs in pairs(self.OnSell) do
		funcs()
	end

	if self.reset then
		self.reset(self, target)
	end
end

return house
