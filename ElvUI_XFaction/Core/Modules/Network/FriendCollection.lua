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
	self._FriendsCount = 0
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

				-- There's no need to store if they are not logged into realm/faction we care about
				local _Realm = XFG.Realms:GetRealmByID(_AccountInfo.gameAccountInfo.realmID)
				local _Faction = XFG.Factions:GetFactionByName(_AccountInfo.gameAccountInfo.factionName)
				if(_Realm ~= nil and XFG.Network.BNet.Targets:Contains(_Realm, _Faction)) then
					local _Target = XFG.Network.BNet.Targets:GetTarget(_Realm, _Faction)
					local _NewFriend = Friend:new()
					_NewFriend:SetKey(_AccountInfo.gameAccountInfo.gameAccountID)
					_NewFriend:SetID(_AccountInfo.gameAccountInfo.gameAccountID)
					_NewFriend:SetName(_AccountInfo.accountName)
					_NewFriend:SetTag(_AccountInfo.battleTag)
					_NewFriend:SetUnitName(_AccountInfo.gameAccountInfo.characterName)
					_NewFriend:SetTarget(_Target)
	
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
						XFG:Debug(LogCategory, "Friend [%s] is bridge to BNet target [%s:%s]", _NewFriend:GetName(), _Realm:GetName(), _Faction:GetName())
					end
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
		self._FriendsCount = self._FriendsCount + 1
	end
	self._Friends[inFriend:GetKey()] = inFriend
	return self:Contains(inFriend:GetKey())
end

function FriendCollection:Reset()
	wipe(self._Friends)
	self._FriendsCount = 0
	self._Initialized = false
end

function FriendCollection:Iterator()
	return next, self._Friends, nil
end

function FriendCollection:HasFriends()
    return self._FriendsCount > 0
end