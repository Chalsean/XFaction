local XFG, G = unpack(select(2, ...))
local ObjectName = 'FriendCollection'

local GetFriendCount = BNGetNumFriends
local GetAccountInfo = C_BattleNet.GetFriendAccountInfo

FriendCollection = Factory:newChildConstructor()

function FriendCollection:new()
	local _Object = FriendCollection.parent.new(self)
	_Object.__name = ObjectName
	return _Object
end

function FriendCollection:NewObject()
	return Friend:new()
end

function FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		try(function ()
			for i = 1, GetFriendCount() do
				self:CheckFriend(i)
			end
			self:IsInitialized(true)
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, inErrorMessage)
		end)
	end
end

function FriendCollection:ContainsByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, _Friend in self:Iterator() do
		if(_Friend:GetGameID() == inGameID) then
			return true
		end
	end
	return false
end

function FriendCollection:GetByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, _Friend in self:Iterator() do
		if(_Friend:GetGameID() == inGameID) then
			return _Friend
		end
	end
end

function FriendCollection:GetByRealmUnitName(inRealm, inName)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
	assert(type(inName) == 'string')
	for _, _Friend in self:Iterator() do
		 if(inName == _Friend:GetName()) then
			 local _Target = _Friend:GetTarget()
			 if(inRealm:Equals(_Target:GetRealm())) then
				return _Friend
			 end
		 end
	 end
end

function FriendCollection:Remove(inFriend)
	assert(type(inFriend) == 'table' and inFriend.__name ~= nil and inFriend.__name == 'Friend', 'argument must be Friend object')
	if(self:Contains(inFriend:GetKey())) then
		try(function ()
			if(XFG.Nodes:Contains(inFriend:GetName())) then
				XFG.Nodes:Remove(XFG.Nodes:Get(inFriend:GetName()))
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, inErrorMessage)
		end).
		finally(function ()
			self.parent.Remove(self, inFriend:GetKey())
			self:Push(inFriend)
		end)
	end
end

function FriendCollection:HasFriends()
    return self:GetCount() > 0
end

local function CanLink(inAccountInfo)
	if(inAccountInfo.isFriend and 
	   inAccountInfo.gameAccountInfo.isOnline and 
	   inAccountInfo.gameAccountInfo.clientProgram == 'WoW') then

	   	-- There's no need to store if they are not logged into realm/faction we care about
		local _Realm = XFG.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)

		-- When a player is in Torghast, it will list realm as 0, no character name or faction
		-- Bail out before it causes an exception
		if(_Realm == nil or _Realm:GetName() == 'Torghast') then return false end

		-- We don't want to link to neutral faction toons
		if(inAccountInfo.gameAccountInfo.factionName == 'Neutral') then return false end
		local _Faction = XFG.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)

		for _, _ID in _Realm:IDIterator() do
			local _ConnectedRealm = XFG.Realms:GetByID(_ID)
			if(XFG.Targets:ContainsByRealmFaction(_ConnectedRealm, _Faction) and (not XFG.Player.Faction:Equals(_Faction) or not XFG.Player.Realm:Equals(_ConnectedRealm))) then
				return true, XFG.Targets:GetByRealmFaction(_ConnectedRealm, _Faction)
			end
		end
	end
	return false
end

function FriendCollection:CheckFriend(inKey)
	try(function ()
		local _AccountInfo = GetAccountInfo(inKey)
		if(_AccountInfo == nil) then
			error('Received nil for friend [%d]', inKey)
		end

		_AccountInfo.ID = inKey
		local _CanLink, _Target = CanLink(_AccountInfo)

		-- Did they go offline?
		if(self:Contains(_AccountInfo.bnetAccountID)) then
			if(not _CanLink) then
				local _Friend = XFG.Friends:Get(_AccountInfo.bnetAccountID)
				if(XFG.DebugFlag) then
					XFG:Info(ObjectName, 'Friend went offline or to unsupported guild [%s:%d:%d:%d]', _Friend:GetTag(), _Friend:GetAccountID(), _Friend:GetID(), _Friend:GetGameID())
				end
				self:Remove(_Friend)
				return true
			end

		-- Did they come online on a supported realm/faction?
		elseif(_CanLink) then
			local _NewFriend = nil
			try(function ()
				_NewFriend = self:Pop()
				_NewFriend:SetFromAccountInfo(_AccountInfo)
				self:Add(_NewFriend)
			end).
			catch(function (inErrorMessage)
				self:Push(_NewFriend)
				error(inErrorMessage)
			end)
			if(XFG.DebugFlag) then
				XFG:Info(ObjectName, 'Friend logged into supported guild [%s:%d:%d:%d]', _NewFriend:GetTag(), _NewFriend:GetAccountID(), _NewFriend:GetID(), _NewFriend:GetGameID())
			end
			-- Ping them to see if they're running the addon
			if(XFG.Initialized) then 
				_NewFriend:Ping() 
			end
		end
	end).
	catch(function (inErrorMessage)
	    XFG:Warn(ObjectName, inErrorMessage)
	end)
end

function FriendCollection:CheckFriends()
	try(function ()
		for i = 1, GetFriendCount() do
			self:CheckFriend(i)
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end

function FriendCollection:Backup()
	try(function ()
	    XFG.DB.Backup.Friends = {}
	    for _, _Friend in self:Iterator() do
			if(_Friend:IsRunningAddon()) then
				XFG.DB.Backup.Friends[#XFG.DB.Backup.Friends + 1] = _Friend:GetKey()
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG.DB.Errors[#XFG.DB.Errors + 1] = 'Failed to create friend backup before reload: ' .. inErrorMessage
	end)
end

function FriendCollection:Restore()
	if(XFG.DB.Backup == nil or XFG.DB.Backup.Friends == nil) then return end		
	for _, _Key in pairs (XFG.DB.Backup.Friends) do
		try(function ()	
			if(XFG.Friends:Contains(_Key)) then
				local _Friend = XFG.Friends:Get(_Key)
				_Friend:IsRunningAddon(true)
				XFG:Info(ObjectName, '  Restored %s friend information from backup', _Friend:GetTag())
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, 'Failed to restore friend list: ' .. inErrorMessage)
		end)
	end
end
