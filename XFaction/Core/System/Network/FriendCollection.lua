local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'FriendCollection'

XFC.FriendCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.FriendCollection:new()
	local object = XFC.FriendCollection.parent.new(self)
	object.__name = ObjectName
	object.friendByGUID = {}
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
			callback = XFO.Friends.CheckFriend, 
			instance = true
		})
		XFO.Timers:Add({
			name = 'Ping', 
			delta = XF.Settings.Network.BNet.Ping.Timer, 
			callback = XFO.Friends.CallbackPing, 
			repeater = true, 
			instance = true
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.FriendCollection:Add(inFriend)
	assert(type(inFriend) == 'table' and inFriend.__name == 'Friend', 'argument must be Friend object')
	if(inFriend:IsOnline()) then
		self.friendByGUID[inFriend:GUID()] = inFriend
	end
	self.parent.Add(self, inFriend)
end

function XFC.FriendCollection:Contains(inKey)
	assert(type(inKey) == 'number' or type(inKey) == 'string', 'argument must be number or string')
	if(type(inKey) == 'string') then
		return self.friendByGUID[inKey] ~= nil
	end
	return self.parent.Contains(self, inKey)
end

function XFC.FriendCollection:Get(inKey)
	assert(type(inKey) == 'number' or type(inKey) == 'string', 'argument must be number or string')
	if(type(inKey) == 'string') then
		return self.friendByGUID[inKey]
	end
	return self.parent.Get(self, inKey)
end

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
		if(friend:GameID() == inGameID) then
			return true
		end
	end
	return false
end

function XFC.FriendCollection:GetByGameID(inGameID)
	assert(type(inGameID) == 'number')
	for _, friend in self:Iterator() do
		if(friend:GameID() == inGameID) then
			return friend
		end
	end
end

function XFC.FriendCollection:ContainsByGUID(inGUID)
    return self:GetByGUID(inGUID) ~= nil
end

function XFC.FriendCollection:GetByGUID(inGUID)
	assert(type(inGUID) == 'string')
	return self.friendByGUID[inGUID]
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

function XFC.FriendCollection:CheckFriend(inKey)
	local self = XFO.Friends
	if(inKey == nil) then return end
		
	local friend = self:Pop()
	try(function()

		friend:Initialize(inKey)

        -- FriendCollection will only contain those friends who can be linked to
		if(friend:CanLink()) then
            -- Keep current state information if present
		    if(self:Contains(inKey)) then
				self:Push(friend)
			else
				XF:Debug(self:ObjectName(), 'Detected friend is online: %s', friend:Tag())
                friend:Print()
				self:Add(friend)
			end
		-- Either theyre offline, not on a realm we care about or same faction
		else
			self:Push(friend)
			if(self:Contains(inKey)) then
				local old = self:Get(inKey)
				XF:Debug(self:ObjectName(), 'Friend has gone offline: %s', old:Tag())
                old:Print()
				XFO.Confederate:OfflineUnit(old:GUID())
				self:Remove(old:Key())
				self:Push(old)
			end
		end

	end).
	catch(function(err)
		self:Push(friend)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.FriendCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			for _, friend in self:Iterator() do
				if(friend:IsLinked()) then
					XF.Cache.Backup.Friends[#XF.Cache.Backup.Friends + 1] = friend:Key()
				end
			end
		end
	end).
	catch(function (err)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create friend backup before reload: ' .. err
	end)
end

function XFC.FriendCollection:Restore()
	if(XF.Cache.Backup.Friends == nil) then XF.Cache.Backup.Friends = {} end
	for _, key in pairs (XF.Cache.Backup.Friends) do
		try(function ()	
			if(self:Contains(key)) then
				local friend = self:Get(key)
				friend:IsLinked(true)
				XF:Info(self:ObjectName(), '  Restored %s friend information from backup', friend:Tag())
			end
		end).
		catch(function (err)
			XF:Warn(self:ObjectName(), 'Failed to restore friend list: ' .. err)
		end)
	end
	XF.Cache.Backup.Friends = {}
end

function XFC.FriendCollection:CallbackPing()
	local self = XFO.Friends
    try(function()
	    for _, friend in self:Iterator() do
			if(not friend:IsLinked()) then
				XFO.BNet:Ping(friend)
			end
	    end
	end).
	catch(function (err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion