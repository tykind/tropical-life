--> @Desc Data store system
--> @Author TyKind
local DataStoreService = game:GetService('DataStoreService')
local HttpService = game:GetService('HttpService')
local quickData = require(script.Parent.Parent.quickData)

local QuickTypes = require(quickData.modules.Types.Module)

local Data = {}
Data.__index = Data

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

return Data