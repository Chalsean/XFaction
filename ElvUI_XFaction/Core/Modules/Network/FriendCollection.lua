local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'FriendCollection'
local LogCategory = 'NCFriend'

FriendCollection = {}

function FriendCollection:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Friends = {}
    self._FriendCount = 0
    self._Initialized = false

    return _Object
end

function FriendCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		for i = 1, BNGetNumFriends() do
			local _AccountInfo = C_BattleNet.GetFriendAccountInfo(i)
			if(_AccountInfo ~= nil and
			   _AccountInfo.isFriend == true and 
			   _AccountInfo.gameAccountInfo.isOnline == true and 
			   _AccountInfo.gameAccountInfo.clientProgram == "WoW") then

				local _NewFriend = Friend:new()
				_NewFriend:SetKey(_AccountInfo.gameAccountInfo.gameAccountID)
				_NewFriend:SetID(_AccountInfo.gameAccountInfo.gameAccountID)
				_NewFriend:SetName(_AccountInfo.accountName)
				_NewFriend:SetTag(_AccountInfo.battleTag)
				_NewFriend:SetRealmID(_AccountInfo.gameAccountInfo.realmID)
				_NewFriend:SetUnitName(_AccountInfo.gameAccountInfo.characterName)
				_NewFriend:SetFaction(XFG.Factions:GetFactionByName(_AccountInfo.gameAccountInfo.factionName))

				-- Temporary code for alpha testing
				if(_NewFriend:GetTag() == 'Arono#11651' or
				   _NewFriend:GetTag() == 'Chalsean#1172' or
				   _NewFriend:GetTag() == 'Ironstones#1683' or
			       _NewFriend:GetTag() == 'Franklinator#1539' or
				   _NewFriend:GetTag() == 'hantevirus#1921' or
				   _NewFriend:GetTag() == 'mightyowl#111899' or
				   _NewFriend:GetTag() == 'Bicc#11211' or
				   _NewFriend:GetTag() == 'Rysal#1525') then
					self:AddFriend(_NewFriend)
				end
			end
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function FriendCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function FriendCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _FriendCount (" .. type(self._FriendCount) .. "): ".. tostring(self._FriendCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Friend in self:Iterator() do
		_Friend:Print()
	end
end

function FriendCollection:GetKey()
    return self._Key
end

function FriendCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function FriendCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Friends[inKey] ~= nil
end

function FriendCollection:GetFriend(inKey)
	assert(type(inKey) == 'number')
    return self._Friends[inKey]
end

function FriendCollection:AddFriend(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name ~= nil and inFriend.__name == 'Friend', "argument must be Friend object")
	if(self:Contains(inFriend:GetKey()) == false) then
		self._FriendCount = self._FriendCount + 1
	end
	self._Friends[inFriend:GetKey()] = inFriend
	return self:Contains(inFriend:GetKey())
end

function FriendCollection:RemoveFriend(inKey)
	assert(type(inKey) == 'number')
	if(self:Contains(inKey)) then
		table.RemoveKey(self._Friends, inKey)
		self._FriendCount = self._FriendCount - 1
	end
	return self:Contains(inKey) == false
end

function FriendCollection:GetRandomFriend(inRealm , inFaction)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
	assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")

	-- Get all the IDs for a realm (connected realms have multiple IDs)
	local _PossibleTargets = {}
	local _RealmIDs = inRealm:GetIDs()
	
	-- Find any BNet friend logged into that realm/faction
	for _, _Friend in self:Iterator() do
		if(inFaction:Equals(_Friend:GetFaction())) then
			-- Loop through all the connected realm IDs
			for _, _RealmID in pairs (_RealmIDs) do
				if(_RealmID == _Friend:GetRealmID()) then
					table.insert(_PossibleTargets, _Friend)
				end
			end
		end
	end

	if(table.getn(_PossibleTargets) == 0) then
		XFG:Debug(LogCategory, "No friends are online connected to target realm [%s] of [%s] faction", inRealm:GetName(), inFaction:GetName())
		return
	end
	
	-- Randomly select a friend as a communication bridge
	local _Random = math.random(1, table.getn(_PossibleTargets))
	return _PossibleTargets[_Random]
end

function FriendCollection:Reset()
	wipe(self._Friends)
	self._FriendCount = 0
	self._Initialized = false
end

function FriendCollection:Iterator()
	return next, self._Friends, nil
end
