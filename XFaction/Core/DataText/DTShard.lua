local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTShard'
local LogCategory = 'DTShard'

DTShard = {}
local Events = {
	'PLAYER_ENTERING_WORLD',
	'PLAYER_LOGIN',
	'PARTY_LEADER_CHANGED',
	'VIGNETTE_MINIMAP_UPDATED',
	'ZONE_CHANGED',
	'COMBAT_LOG_EVENT_UNFILTERED'
}

function DTShard:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
	self._HeaderFont = nil
	self._RegularFont = nil
	self._LDBObject = nil
	self._Tooltip = nil
	self._EpochTime = 0
	self._ShardID = 0
	self._CheckShard = true
    
    return _Object
end

function DTShard:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)
		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTSHARD_NAME'])

		self._EpochTime = GetServerTime()

		for _, _EventName in pairs (Events) do
			XFG:RegisterEvent(_EventName, self.RefreshBroker)
		end

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTShard:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTShard:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _Price (" .. type(self._Price) .. "): ".. tostring(self._Price))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function DTShard:ParseGUID(inGUID)

	self._EpochTime = GetServerTime()
	
	if inGUID ~= nil then
		local _Source, _, _, _, _ShardID, _, _ = strsplit("-", inGUID)
		
		-- Player parses don't have shard info and pets can be on shards other than the players
		if(_Source ~= 'Player' and _Source ~= 'Pet' and _ShardID ~= nil) then
			XFG:Debug(LogCategory, format("Parsed guid [%s]", inGUID))
			if(self._ShardID ~= _ShardID) then
				self._ShardID = _ShardID
				XFG:Info(LogCategory, format("Shard migration [%d]", self._ShardID))
				return true
			end
		end
	end
	
	return false
end

function DTShard:ShouldCheckShard(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._CheckShard = inBoolean
	end
	return self._CheckShard
end

function DTShard:GetBroker()
	return self._LDBObject
end

function DTShard:GetShardID()
	return self._ShardID
end

function DTShard:SetShardID(inID)
	assert(type(inID) == 'number')
	self._ShardID = inID
	return self:GetShardID()
end

function DTShard:GetEpochTime()
	return self._EpochTime
end

function DTShard:RefreshBroker(inSelf, inEvent, ...)
	-- Try to catch Blizz migrating a player to another shard outside of normal events
	if(XFG.DataText.Shard:ShouldCheckShard() == false and XFG.DataText.Shard:GetEpochTime() + XFG.Config.DataText.Shard.Timer <= GetServerTime()) then
		XFG:Debug(LogCategory, format("Checking for shard migration due to timer [%d]", XFG.Config.DataText.Shard.Timer))
		XFG.DataText.Shard:ShouldCheckShard(true)
	end

	-- Shard information is only found in a couple locations, combat logs being primary source
	-- In order to not impact performance, use CheckShard flag to indicate whether should parse log event
	if XFG.DataText.Shard:ShouldCheckShard() and inEvent == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local _, _, _, _, _, _, _, _GUID, _, _, _ = CombatLogGetCurrentEventInfo()
		if(XFG.DataText.Shard:ParseGUID(_GUID)) then
			local _Broker = XFG.DataText.Shard:GetBroker()
			_Broker.text = format(XFG.Lib.Locale['DTSHARD_SHARD_ID'], self._ShardID)
		end	
		XFG.DataText.Shard:ShouldCheckShard(false)
		return
	end

	-- Vignette is the rare spawns for a zone, their info contains shard id
	if XFG.DataText.Shard:ShouldCheckShard() and inEvent == 'VIGNETTE_MINIMAP_UPDATED' then
		local _GUID, _ = ...
		local _VignetteInfo = C_VignetteInfo.GetVignetteInfo(_GUID)
		if XFG.DataText.Shard:ParseGUID(_VignetteInfo.objectGUID) then
			local _Broker = XFG.DataText.Shard:GetBroker()
			_Broker.text = format(XFG.Lib.Locale['DTSHARD_SHARD_ID'], self._ShardID)
		end
		XFG.DataText.Shard:ShouldCheckShard(false)
		return
	end
	
	-- Events that can cause a shard migration
	if inEvent == 'PLAYER_ENTERING_WORLD' or inEvent == 'PLAYER_LOGIN' or inEvent == 'PARTY_LEADER_CHANGED' or 
		inEvent == 'PARTY_MEMBERS_CHANGED' or inEvent == 'RAID_ROSTER_UPDATE' or inEvent == 'ZONE_CHANGED' then
	
		XFG:Debug(LogCategory, 'Checking for shard migration due to event [%s]', inEvent)
		XFG.DataText.Shard:ShouldCheckShard(true)
		return
	end
end