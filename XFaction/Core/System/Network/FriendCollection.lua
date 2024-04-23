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
			callback = XFO.Friends.CheckFriends, 
			instance = true,
			groupDelta = XF.Settings.Network.BNet.FriendTimer
		})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties

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

function XFC.FriendCollection:GetByGUID(inGUID)
	assert(type(inGUID) == 'string')
	return self.friendByGUID[inGUID]
end

function XFC.FriendCollection:CheckFriends()
	local self = XFO.Friends
	try(function ()
		for i = 1, XFF.BNetGetFriendCount() do
			local friend = nil
			try(function()

				friend = self:Contains(i) and self:Get(i) or self:Pop()
				local guid = friend:GUID()
				friend:Initialize(i)

				if(friend:IsOffline()) then
					if(guid ~= nil) then
						self.friendByGUID[guid] = nil
					end
					friend:IsLinked(false)
				end

				self:Add(friend)
				if(friend:CanLink() and not friend:IsLinked()) then
					XFO.BNet:Ping(friend)
				end
			end).
			catch(function(err)
				self:Push(friend)
				error(err)
			end)
		end
	end).
	catch(function (err)
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

-- FIX: This assumes a scan has already taken place
function XFC.FriendCollection:Restore()
	if(XF.Cache.Backup.Friends == nil) then XF.Cache.Backup.Friends = {} end
	for _, key in pairs (XF.Cache.Backup.Friends) do
		try(function ()	
			if(self:Contains(key)) then
				local friend = self:Get(key)
				friend:IsLinked(true)
				XF:Info(self:ObjectName(), '  Restored %s friend information from backup', friend:GetTag())
			end
		end).
		catch(function (err)
			XF:Warn(self:ObjectName(), 'Failed to restore friend list: ' .. err)
		end)
	end
	XF.Cache.Backup.Friends = {}
end
--#endregion