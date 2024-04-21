local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'FriendCollection'

XFC.FriendCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.FriendCollection:new()
	local object = XFC.FriendCollection.parent.new(self)
	object.__name = ObjectName
	object.friendByID = {}
	object.hasActive = false
	return object
end

function XFC.FriendCollection:NewObject()
	return XFC.Friend:new()
end

function XFC.FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:CheckFriends()
		XFO.Events:Add({
			name = 'Friend', 
			event = 'BN_FRIEND_INFO_CHANGED', 
			callback = XFO.Friends.CheckFriends, 
			instance = true,
			groupDelta = XF.Settings.Network.BNet.FriendTimer
		})		
		XFO.Timers:Add({
			name = 'Ping', 
			delta = XF.Settings.Network.BNet.Ping.Timer, 
			callback = XFO.Friends.Ping, 
			repeater = true, 
			instance = true
		})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties

--#endregion

--#region Methods
function XFC.FriendCollection:HasFriends()
    return self:Count() > 0
end

function XFC.FriendCollection:HasActiveFriends()
	for _, friend in self:Iterator() do
		if(friend:IsActive()) then
			return true
		end
	end
    return false
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

function XFC.ZoneCollection:ContainsByID(inID)
	assert(type(inID) == 'number')
	return self.zoneByID[inID] ~= nil
end

function XFC.ZoneCollection:GetByID(inID)
	assert(type(inID) == 'number')
	return self.zoneByID[inID]
end

function XFC.ZoneCollection:Add(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone', 'argument must be Zone object')
	self.parent.Add(self, inZone)
	for _, ID in inZone:IDIterator() do
		self.zoneByID[ID] = inZone
	end
end
--#endregion

--#region Accessors
function XFC.FriendCollection:GetByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, friend in self:Iterator() do
		if(friend:GameID() == inGameID) then
			return friend
		end
	end
end

function XFC.FriendCollection:GetByRealmUnitName(inRealm, inName)
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
	assert(type(inName) == 'string')
	for _, friend in self:Iterator() do
		if(inName == friend:Name() and inRealm:Equals(friend:Target():Realm())) then
			return friend
		end
	 end
end
--#endregion

--#region Event Handlers
function XFC.FriendCollection:CheckFriend(inKey)

	local accountInfo = XFF.BNetGetFriendInfo(inKey)
	if(accountInfo == nil) then
		error('Received nil for friend [%d]', inKey)
	elseif(not accountInfo.isFriend) then
		return
	end

	accountInfo.ID = inKey
	local friend = nil
	
	try(function()
		friend = self:Pop()
		friend:Deserialize(accountInfo)
	end).
	catch(function(err)
		self:Push(friend)
		error(err)
	end)

	if(self:Contains(friend:Key())) then
		if(self:Get(friend:Key()):IsActive() ~= friend:IsActive()) then

		friend = self:Get(accountInfo.bnetAccountID)
	else
		
	end		

	local canLink, target = CanLink(accountInfo)
	if(canLink and target ~= nil) then
		friend:Target(target)
		if(not friend:IsActive()) then
			XF:Info(self:ObjectName(), 'Friend logged into supported guild [%s:%d:%d:%d]', friend:Tag(), friend:AccountID(), friend:ID(), friend:GameID())
			friend:IsActive(true)
		end
	elseif(friend:IsActive()) then
		XF:Info(self:ObjectName(), 'Friend went offline or to unsupported guild [%s:%d:%d:%d]', friend:Tag(), friend:AccountID(), friend:ID(), friend:GameID())
		friend:IsActive(false)
	end
end

function XFC.FriendCollection:CheckFriends()
	local self = XFO.Friends
	try(function ()
		for i = 1, XFF.BNetGetFriendCount() do
			self:CheckFriend(i)
		end
	end).
	catch(function (err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion

--#region Janitorial
function XFC.FriendCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			for _, friend in self:Iterator() do
				if(friend:IsRunningAddon()) then
					XF.Cache.Backup.Friends[#XF.Cache.Backup.Friends + 1] = friend:Key()
				end
			end
		end
	end).
	catch(function (err)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create friend backup before reload: ' .. err
	end)
end

-- FIX: This assumes a scan has already taken place
function XFC.FriendCollection:Restore()
	if(XF.Cache.Backup.Friends == nil) then XF.Cache.Backup.Friends = {} end
	for _, key in pairs (XF.Cache.Backup.Friends) do
		try(function ()	
			if(self:Contains(key)) then
				local friend = self:Get(key)
				friend:IsRunningAddon(true)
				XF:Info(self:ObjectName(), '  Restored %s friend information from backup', friend:GetTag())
			end
		end).
		catch(function (err)
			XF:Warn(self:ObjectName(), 'Failed to restore friend list: ' .. err)
		end)
	end
	XF.Cache.Backup.Friends = {}
end

-- Periodically ping friends to see who is running addon
function XFC.FriendCollection:Ping()
	local self = XFO.Friends
    try(function()
	    for _, friend in self:Iterator() do
			if(friend:IsActive() and not friend:IsRunningAddon()) then
				friend:Ping()
			end
	    end
	end).
	catch(function (err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion