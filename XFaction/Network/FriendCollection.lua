local XFG, G = unpack(select(2, ...))
local ObjectName = 'FriendCollection'
local GetFriendCount = BNGetNumFriends
local GetAccountInfo = C_BattleNet.GetFriendAccountInfo

FriendCollection = Factory:newChildConstructor()

--#region Constructors
function FriendCollection:new()
	local object = FriendCollection.parent.new(self)
	object.__name = ObjectName
	return object
end

function FriendCollection:NewObject()
	return Friend:new()
end
--#endregion

--#region Initializers
function FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		try(function ()
			for i = 1, GetFriendCount() do
				self:CheckFriend(i)
			end
			if(XFG.Cache.UIReload) then
				self:Restore()
			end
			self:IsInitialized(true)
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, inErrorMessage)
		end)
	end
end
--#endregion

--#region Hash
function FriendCollection:HasFriends()
    return self:GetCount() > 0
end

function FriendCollection:ContainsByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, friend in self:Iterator() do
		if(friend:GetGameID() == inGameID) then
			return true
		end
	end
	return false
end

function FriendCollection:Remove(inFriend)
	assert(type(inFriend) == 'table' and inFriend.__name == 'Friend', 'argument must be Friend object')
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
--#endregion

--#region Accessors
function FriendCollection:GetByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, friend in self:Iterator() do
		if(friend:GetGameID() == inGameID) then
			return friend
		end
	end
end

function FriendCollection:GetByRealmUnitName(inRealm, inName)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
	assert(type(inName) == 'string')
	for _, friend in self:Iterator() do
		if(inName == friend:GetName() and inRealm:Equals(friend:GetTarget():GetRealm())) then
			return friend
		end
	 end
end
--#endregion

--#region DataSet
local function CanLink(inAccountInfo)
	if(inAccountInfo.isFriend and 
	   inAccountInfo.gameAccountInfo.isOnline and 
	   inAccountInfo.gameAccountInfo.clientProgram == 'WoW') then

		-- If player is in Torghast, don't link
		local realm = XFG.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
		if(realm == nil or realm:GetID() == 0) then return false end

		-- We don't want to link to neutral faction toons
		if(inAccountInfo.gameAccountInfo.factionName == 'Neutral') then return false end
		local faction = XFG.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)

		local target = XFG.Targets:GetByRealmFaction(realm, faction)
		if(target ~= nil and not target:IsMyTarget()) then return true, target end
	end
	return false
end

function FriendCollection:CheckFriend(inKey)
	try(function ()
		local accountInfo = GetAccountInfo(inKey)
		if(accountInfo == nil) then
			error('Received nil for friend [%d]', inKey)
		end

		accountInfo.ID = inKey
		local canLink, target = CanLink(accountInfo)

		-- Did they go offline?
		if(self:Contains(accountInfo.bnetAccountID)) then
			if(not canLink) then
				local friend = XFG.Friends:Get(accountInfo.bnetAccountID)
				XFG:Info(ObjectName, 'Friend went offline or to unsupported guild [%s:%d:%d:%d]', friend:GetTag(), friend:GetAccountID(), friend:GetID(), friend:GetGameID())
				self:Remove(friend)
				return true
			end

		-- Did they come online on a supported realm/faction?
		elseif(canLink and target ~= nil) then
			local friend = nil
			try(function ()
				friend = self:Pop()
				friend:SetFromAccountInfo(accountInfo)
				friend:SetTarget(target) -- reset target to found connected realm
				self:Add(friend)
			end).
			catch(function (inErrorMessage)
				self:Push(friend)
				error(inErrorMessage)
			end)
			XFG:Info(ObjectName, 'Friend logged into supported guild [%s:%d:%d:%d]', friend:GetTag(), friend:GetAccountID(), friend:GetID(), friend:GetGameID())
			-- Ping them to see if they're running the addon
			if(XFG.Initialized) then 
				friend:Ping() 
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
--#endregion

--#region Janitorial
function FriendCollection:Backup()
	try(function ()
	    for _, friend in self:Iterator() do
			if(friend:IsRunningAddon()) then
				XFG.Cache.Backup.Friends[#XFG.Cache.Backup.Friends + 1] = friend:GetKey()
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG.Cache.Errors[#XFG.Cache.Errors + 1] = 'Failed to create friend backup before reload: ' .. inErrorMessage
	end)
end

function FriendCollection:Restore()
	for _, key in pairs (XFG.Cache.Backup.Friends) do
		try(function ()	
			if(XFG.Friends:Contains(key)) then
				local friend = XFG.Friends:Get(key)
				friend:IsRunningAddon(true)
				XFG:Info(ObjectName, '  Restored %s friend information from backup', friend:GetTag())
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, 'Failed to restore friend list: ' .. inErrorMessage)
		end)
	end
end
--#endregion