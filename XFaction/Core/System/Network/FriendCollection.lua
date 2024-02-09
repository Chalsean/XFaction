local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'FriendCollection'
local GetFriendCount = BNGetNumFriends
local GetAccountInfo = C_BattleNet.GetFriendAccountInfo

XFC.FriendCollection = Factory:newChildConstructor()

--#region Constructors
function XFC.FriendCollection:new()
	local object = XFC.FriendCollection.parent.new(self)
	object.__name = ObjectName
	return object
end

function XFC.FriendCollection:NewObject()
	return XFC.Friend:new()
end
--#endregion

--#region Initializers
function XFC.FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		try(function ()
			for i = 1, GetFriendCount() do
				self:CheckFriend(i)
			end
			if(XF.Cache.UIReload) then
				self:Restore()
			end
			self:IsInitialized(true)
		end).
		catch(function (inErrorMessage)
			XF:Warn(ObjectName, inErrorMessage)
		end)
	end
end
--#endregion

--#region Hash
function XFC.FriendCollection:HasFriends()
    return self:GetCount() > 0
end

function XFC.FriendCollection:ContainsByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, friend in self:Iterator() do
		if(friend:GetGameID() == inGameID) then
			return true
		end
	end
	return false
end

function XFC.FriendCollection:Remove(inFriend)
	assert(type(inFriend) == 'table' and inFriend.__name == 'Friend', 'argument must be Friend object')
	if(self:Contains(inFriend:GetKey())) then
		try(function ()
			if(XF.Nodes:Contains(inFriend:GetName())) then
				XF.Nodes:Remove(XF.Nodes:Get(inFriend:GetName()))
			end
		end).
		catch(function (inErrorMessage)
			XF:Warn(ObjectName, inErrorMessage)
		end).
		finally(function ()
			self.parent.Remove(self, inFriend:GetKey())
			self:Push(inFriend)
		end)
	end
end
--#endregion

--#region Accessors
function XFC.FriendCollection:GetByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, friend in self:Iterator() do
		if(friend:GetGameID() == inGameID) then
			return friend
		end
	end
end

function XFC.FriendCollection:GetByRealmUnitName(inRealm, inName)
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
		local realm = XFO.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
		if(realm == nil or realm:GetID() == 0) then return false end

		-- We don't want to link to neutral faction toons
		if(inAccountInfo.gameAccountInfo.factionName == 'Neutral') then return false end
		local faction = XFO.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)

		XF:Trace(ObjectName, 'Checking friend for linkability [%s] GUID [%s] RealmID [%d] RealmName [%s]', inAccountInfo.battleTag, inAccountInfo.gameAccountInfo.playerGuid, inAccountInfo.gameAccountInfo.realmID, inAccountInfo.gameAccountInfo.realmName)

		local target = XFO.Targets:GetByRealmFaction(realm, faction)
		if(target ~= nil and not target:IsMyTarget()) then return true, target end
	end
	return false
end

function XFC.FriendCollection:CheckFriend(inKey)
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
				local friend = self:Get(accountInfo.bnetAccountID)
				XF:Info(ObjectName, 'Friend went offline or to unsupported guild [%s:%d:%d:%d]', friend:GetTag(), friend:GetAccountID(), friend:GetID(), friend:GetGameID())
				self:Remove(friend)
				return true
			end

		-- Did they come online on a supported realm/faction?
		elseif(canLink and target ~= nil) then
			local friend = self:Pop()
			try(function ()
				friend:SetFromAccountInfo(accountInfo)
				friend:SetTarget(target) -- reset target to found connected realm
				self:Add(friend)
			end).
			catch(function (inErrorMessage)
				self:Push(friend)
				error(inErrorMessage)
			end)
			XF:Info(ObjectName, 'Friend logged into supported guild [%s:%d:%d:%d]', friend:GetTag(), friend:GetAccountID(), friend:GetID(), friend:GetGameID())
			-- Ping them to see if they're running the addon
			if(XF.Initialized) then 
				friend:Ping() 
			end
		end
	end).
	catch(function (inErrorMessage)
	    XF:Warn(ObjectName, inErrorMessage)
	end)
end

function XFC.FriendCollection:CheckFriends()
	try(function ()
		for i = 1, GetFriendCount() do
			self:CheckFriend(i)
		end
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end)
end
--#endregion

--#region Janitorial
function XFC.FriendCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			for _, friend in self:Iterator() do
				if(friend:IsRunningAddon()) then
					XF.Cache.Backup.Friends[#XF.Cache.Backup.Friends + 1] = friend:GetKey()
				end
			end
		end
	end).
	catch(function (inErrorMessage)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create friend backup before reload: ' .. inErrorMessage
	end)
end

function XFC.FriendCollection:Restore()
	if(XF.Cache.Backup.Friends == nil) then XF.Cache.Backup.Friends = {} end
	for _, key in pairs (XF.Cache.Backup.Friends) do
		try(function ()	
			if(self:Contains(key)) then
				local friend = self:Get(key)
				friend:IsRunningAddon(true)
				XF:Info(ObjectName, '  Restored %s friend information from backup', friend:GetTag())
			end
		end).
		catch(function (inErrorMessage)
			XF:Warn(ObjectName, 'Failed to restore friend list: ' .. inErrorMessage)
		end)
	end
	XF.Cache.Backup.Friends = {}
end
--#endregion