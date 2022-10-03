--> @Desc Data store system
--> @Author TyKind
local DataStoreService = game:GetService('DataStoreService')
local HttpService = game:GetService('HttpService')
local quickData = require(script.Parent.Parent.quickData)

local QuickTypes = require(quickData.modules.Types.Module)

local Data = {}
Data.__index = Data
Data.MaxLeaderboardCount = 20

---> @Section Starting/Common functions
-------------

function Data.new(config : QuickTypes.DataHandlerConfiguration)
	local mt = setmetatable({
		cfg = config,
		conn = nil
	}, Data)
	
	if(mt.cfg['Global']) then
		local Datastore = DataStoreService:GetOrderedDataStore(mt.cfg['DataStoreName'] or "debug_101")
		mt.conn = Datastore
	else
		local Datastore = DataStoreService:GetDataStore(mt.cfg['DataStoreName'] or "debug_101")
		mt.conn = Datastore
	end
	
	return mt
end

function Data:FixKey(key)
	if (typeof(key) == "Instance" and key:IsA('Player')) then
		key = self.cfg['KeyMask']:gsub("USERID", key.UserId)
	end
	return key
end

function Data:CallUpdate(...)
	local OnUpdate = self.cfg['OnUpdate']
	if(OnUpdate and type(OnUpdate) == "function") then
		OnUpdate(...)
	end
end


function Data:sortValues(from)
	local sorted = from
	table.sort(sorted, function(x, y)
		return x.Value > y.Value
	end)
	return sorted
end

---> @Section Base functions
-------------

function Data:Set(key, data)
	local Key = self:FixKey(key)
	self.conn:SetAsync(Key, data)
	
	self:CallUpdate("SET", key, data) --> Update
end

function Data:Increment(key, dt)
	local Key = self:FixKey(key)
	self.conn:IncrementAsync(Key, dt)
	
	self:CallUpdate("INCREMENT", key, dt) --> Update
end

function Data:Update(key, func)
	local Key = self:FixKey(key)
	local ret, keyInfo = self.conn:UpdateAsync(func)
	
	self:CallUpdate("UPDATE", key, ret, func) --> Update
	return ret, keyInfo
end


function Data:Get(key)
	local Key = self:FixKey(key)
	local ret = self.conn:GetAsync(Key)
	
	self:CallUpdate("GET", key, ret) --> Update
	return ret
end

---> @Section Special functions
-------------

function Data:SetTable(key, tbl)
    assert(not self.cfg.global, "cannot set table, datastore is limited to integers.")
	local EncodedJson = HttpService:JSONEncode(tbl)
	self:Set(EncodedJson, key)
end

function Data:safe_set(key, data)
	return self:Update(key, function(currentData, keyinfo)
		local userIDs = keyinfo:GetUserIds()
		local metadata = keyinfo:GetMetadata()
		
		if currentData ~= data then
			return data, userIDs, metadata
		else
			return currentData, userIDs, metadata
		end
	end)
end

function Data:makeNumberLeaderboard(folder : Folder, amount : number, time : number, filterKey : (string) -> string, debugName : string?)
	assert(amount <= self.MaxLeaderboardCount, "expected amount to be lower or the maximum amount of players in the data module")
	task.spawn(function()
		local function updateFolder()
			local pages = self.conn:GetSortedAsync(true, self.MaxLeaderboardCount)
			local top20 = pages:GetCurrentPage()

			for _, info in pairs(top20) do
				local name = filterKey(info.key)
				local num = info.value

				--> @Info Check if key is userid (NO TEST SUBJECTS IN HERE)
				local userId = tonumber(name)
				if userId and userId < 0 then
					continue
				end

				local found = folder:FindFirstChild(name)
				if found then
					--> @Update current one
					found.Value = num
				else
					local childs = self:sortValues(folder:GetChildren())
					if #childs >= amount then
						local Child = childs[#childs]
						
						if Child.Value >= num then
							continue
						end

						Child:Destroy()
					end

					local createdNum = Instance.new("NumberValue")
					createdNum.Name = name
					createdNum.Value = num
				
					createdNum.Parent = folder
				end
			end
		end

		updateFolder()

		while true do task.wait(time)
			updateFolder()
		end
	end)
end

return Data