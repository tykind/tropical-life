--> @Desc House item function
--> @Author Tykind
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TestService = game:GetService("TestService")
local quickData = require(script.Parent.Parent.quickData)

local PlayerDataParser = require(quickData.modules["Data parser"].Module)
local QuickTypes = require(quickData.modules["Types"].Module)

---> @Section Basic functions
local currentOwners = {}
local house: QuickTypes.House = {
	Price = 0,
	Connections = {},
	OnSell = {},
	OnBuy = {},
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
	self.ObjectRef.Configuration.Owner.Value = if target then target.UserId else 0
	-- --> @Info Create connection and execute left
	-- self.Connections["PlayerLeft"] = Players.PlayerRemoving:Connect(function(plr)
	-- 	if plr == target then
	-- 		--> @Info now since the owner left we can also call the provided function
	-- 		self.Owner = nil

	-- 		if onceLeft then
	-- 			onceLeft(self, target)
	-- 		elseif self.reset then
	-- 			self.reset(self, target)
	-- 		end
	-- 	end
	-- end)

	--> @Info Adding player to a queue of removing
	if target then
		table.insert(currentOwners, {
			UserId = target.UserId,
			House = self
		})
	end
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
	self:setCanPurchase(false)
	
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
	

	TestService:Message(("[HOUSE SYSTEM EVENT] - Purchased | %s Setup : %s | New Owner : %s"):format(self.ObjectRef.Name, 
		tostring(self.setup), target.Name)) --> Log event
end

function house:sell(target: Player, ignoreReturn : boolean?)
	assert(target == self.Owner, "you aren't the owner")


	--> @Info Check if we ignore the return of money
	if not ignoreReturn then
		local data = PlayerDataParser:parseData(target)
		assert(data, "not loaded yet?")

		--> @Info give them a small percentage of the original price and remove ownership
		local afterPercentage = (self.Price * 80 / 100)

		data.cash:add(self.Price - afterPercentage)
		data.house:set(nil)
	end

	-- if self.Connections["PlayerLeft"] then
	-- 	local conn: RBXScriptConnection = self.Connections["PlayerLeft"]
	-- 	self.Connections["PlayerLeft"] = nil

	-- 	conn:Disconnect()
	-- end

	self:setOwner(nil)

	for i, houseInfo in pairs(currentOwners) do
		if houseInfo.UserId == target.UserId then
			table.remove(currentOwners, i)
		end
	end

	if self.reset then
		self.reset(self, target)
	end

	self:setCanPurchase(true)
	TestService:Message(("[HOUSE SYSTEM EVENT] - Sold | %s Reset : %s | Old Owner : %s | Ignored return : %s"):format(self.ObjectRef.Name, 
	tostring(self.reset), target.Name, tostring(ignoreReturn))) --> Log event
end

local function trySellOnLeft(player : Player, currentOwnerIndex : number, House : QuickTypes.House, tries : number)
	if tries >= 10 then
		--> @Info Just reset home manually
		House:setOwner(nil)

		table.remove(currentOwners, currentOwnerIndex)

		if House.reset then
			House.reset(House, player)
		end
		return
	end

	local succ, err = pcall(House.sell, House, player, true) --> Sell money safely without giving out money (since it's unsafe, might not add anyways)
	if not(succ) and not(err:match("you aren't the owner")) then 
		TestService:Fail(("[HOUSE SYSTEM] - %s | try %d"):format(err, tries)) --> Log error
		task.wait(.5)
		trySellOnLeft(player, House, tries + 1)
		return
	end
	
	table.remove(currentOwners, currentOwnerIndex)
end

Players.PlayerRemoving:Connect(function(player)
	for i, houseInfo in pairs(currentOwners) do
		if houseInfo.UserId == player.UserId then
			--> @Info Found our player
			trySellOnLeft(player, i, houseInfo.House, 0)
		end
	end
end)

return house
