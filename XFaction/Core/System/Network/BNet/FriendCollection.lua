local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'FriendCollection'

XFC.FriendCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.FriendCollection:new()
	local object = XFC.FriendCollection.parent.new(self)
	object.__name = ObjectName
	return object
end

function XFC.FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		for i = 1, XFF.BNetFriendCount() do
			try(function()
				local friend = XFC.Friend:new()
				friend:Initialize(i)
				if(friend:CanLink()) then
					self:Add(friend)
				end
			end).
			catch(function(err)
				XF:Warn(self:ObjectName(), err)
			end)
		end

		XFO.Events:Add({
            name = 'Friend', 
            event = 'BN_FRIEND_INFO_CHANGED', 
            callback = XFO.Friends.CallbackFriendChanged, 
            instance = true,
        })

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.FriendCollection:Get(inKey)
	assert(type(inKey) == 'number' or type(inKey) == 'string')
	if(type(inKey) == 'string') then
		for _, friend in self:Iterator() do
			if(friend:GUID() == inKey) then
				return friend
			end
		end
	end
	return self.parent.Get(self, inKey)
end

function XFC.FriendCollection:HasFriends()
    return self:Count() > 0
end

function XFC.FriendCollection:Remove(inKey)
	assert(type(inKey) == 'number')
	if(self:Contains(inKey)) then
		local friend = self:Get(inKey)
		if(XFO.Confederate:Contains(friend:GUID())) then
			XFO.Confederate:Get(friend:GUID()):UnlinkFriend()
		end
		self.parent.Remove(self, inKey)
	end
end

function XFC.FriendCollection:CallbackFriendChanged(inID)
	local self = XFO.Friends
	if(inID == nil or inID == 0) then return end
	XF:Debug(self:ObjectName(), 'Checking friend: %d', inID)

	-- Detect friend going offline
	try(function()
		local friend = XFC.Friend:new()
		friend:Initialize(inID)
		if(self:Contains(friend:Key())) then
			local oldFriend = self:Get(friend:Key())
			if(oldFriend:IsOnline() and not friend:IsOnline()) then
				XF:Debug(self:ObjectName(), 'Detected BNet logout: %s', oldFriend:Name())
				XFO.Confederate:ProcessLogout(oldFriend:GUID())
			end

			if(friend:CanLink()) then
				friend:IsLinked(oldFriend:IsLinked())
				self:Add(friend)
			else
				self:Remove(friend:Key())
			end
		elseif(friend:CanLink()) then
			self:Add(friend)
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.FriendCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

	local friend = self:Get(inMessage:From())
	if(friend == nil) then
		friend = XFC.Friend:new()
		friend:Initialize(inMessage:From())
		friend:IsLinked(true)
		self:Add(friend)
	elseif(not friend:IsLinked()) then
		friend:IsLinked(true)
	end

	if(XFO.Confederate:Contains(friend:GUID())) then
		XFO.Confederate:Get(friend:GUID()):Friend(friend)
	end

	if(inMessage:IsAckMessage()) then
		XF:Debug(self:ObjectName(), 'Received ack message from [%s]', friend:Tag())
	else
		XF:Debug(self:ObjectName(), 'Sending ack message to [%s]', friend:Tag())
		XFO.Mailbox:SendAckMessage(friend)
	end
end
--#endregion