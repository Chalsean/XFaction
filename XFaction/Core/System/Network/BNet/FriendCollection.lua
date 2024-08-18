local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'FriendCollection'

XFC.FriendCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.FriendCollection:new()
	local object = XFC.FriendCollection.parent.new(self)
	object.__name = ObjectName
	object.byGUID = nil
	object.byGUIDCount = 0
	object.byTarget = nil
	return object
end

function XFC.FriendCollection:NewObject()
	return XFC.Friend:new()
end

function XFC.FriendCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		self.byGUID = {}
		self.byTarget = {}
		for _, target in XFO.Targets:Iterator() do
			self.byTarget[target:Key()] = {}
		end

		for i = 1, XFF.BNetFriendCount() do
			local friend = nil
			try(function()
				friend = self:Pop()
				friend:Initialize(i)
				self:Add(friend)
			end).
			catch(function(err)
				XF:Warn(self:ObjectName(), err)
				self:Push(friend)
			end)
		end

		XFO.Events:Add({
            name = 'Friend', 
            event = 'BN_FRIEND_INFO_CHANGED', 
            callback = XFO.Friends.CallbackFriendChanged, 
            instance = true,
            --groupDelta = XF.Settings.Network.BNet.FriendTimer
        })

        -- XFO.Timers:Add({
        --     name = 'Ping', 
        --     delta = XF.Settings.Network.BNet.Ping.Timer, 
        --     callback = XFO.Friends.CallbackPing, 
        --     repeater = true, 
        --     instance = true
        -- })

		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.FriendCollection:LinkCount()
	return self.byGUIDCount
end
--#endregion

--#region Methods
function XFC.FriendCollection:Add(inFriend)
	assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')
	if(self:Contains(inFriend:Key())) then
		local oldFriend = self:Get(inFriend:Key())
		self.objects[inFriend:Key()] = inFriend

		if(oldFriend:HasTarget() and not inFriend:HasTarget()) then
			self.byTarget[oldFriend:Target():Key()][oldFriend:Key()] = nil
		end
		if(oldFriend:GUID() ~= nil and inFriend:GUID() == nil) then
			self.byGUID[oldFriend:GUID()] = nil
			self.byGUIDCount = self.byGUIDCount - 1
		end
		
		self:Push(oldFriend)
	else
		self.parent.Add(self, inFriend)
		if(inFriend:HasTarget()) then
			self.byTarget[inFriend:Target():Key()][inFriend:Key()] = inFriend
		end
		if(inFriend:GUID() ~= nil) then
			self.byGUID[inFriend:GUID()] = inFriend
			self.byGUIDCount = self.byGUIDCount + 1
		end
	end
end

function XFC.FriendCollection:Get(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number')
	if(type(inKey) == 'string') then
		return self.byGUID[inKey]
	end
	return self.parent.Get(self, inKey)
end

function XFC.FriendCollection:Contains(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number')
	return self:Get(inKey) ~= nil
end

function XFC.FriendCollection:HasFriends()
    return self:Count() > 0
end

function XFC.FriendCollection:HasLinkedFriends()
	return self:LinkCount() > 0
end

function XFC.FriendCollection:CallbackFriendChanged(inID)
	local self = XFO.Friends
	if(inID == nil or inID == 0) then return end

	local friend = nil
	try(function()
		friend = self:Pop()
		friend:Initialize(inID)
		if(self:Contains(friend:Key())) then
			local oldFriend = self:Get(friend:Key())
			if(oldFriend:CanLink() and not friend:IsOnline()) then
				if(XFO.Confederate:Contains(oldFriend:GUID())) then
					XFO.Confederate:Logout(oldFriend:GUID())
				else
					XFO.SystemFrame:DisplayLogout(oldFriend:Name())
				end
			elseif(oldFriend:IsLinked() and friend:CanLink()) then
				friend:IsLinked(true)
				friend:Target(oldFriend:Target())
			end
		end
		self:Add(friend)
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
		self:Push(friend)
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
				friend:IsLinked(friend:CanLink()) -- They may have logged out during reload, thus why setting it to CanLink
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
            if(not friend:IsLinked() and friend:CanLink() and friend:LastPinged() < XFF.TimeCurrent() - XF.Settings.Network.BNet.Ping.Timer) then
                XFO.Mailbox:SendPingMessage(friend)
            end
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
		friend = self:Pop()
		friend:Initialize(i)
		friend:Target(inMessage:FromUnit():Target())
		friend:Target():BNetRecipient(friend:Key())
		friend:IsLinked(true)
		self:Add(friend)
	else
		friend:Target(inMessage:FromUnit():Target())
		friend:Target():BNetRecipient(friend:Key())
		if(not friend:IsLinked()) then
			friend:IsLinked(true)
		end
	end

	if(inMessage:IsAckMessage()) then
		XF:Debug(self:ObjectName(), 'Received ack message from [%s]', friend:Tag())
	else
		XF:Debug(self:ObjectName(), 'Sending ack message to [%s]', friend:Tag())
		XFO.Mailbox:SendAckMessage(friend)
	end
end

function XFC.FriendCollection:GetRandomRecipient(inTarget)
	assert(type(inTarget) == 'table' and inTarget.__name == 'Target')

	local friends = {}
	for _, friend in pairs(self.byTarget[inTarget:Key()]) do
		table.insert(friends, friend)
	end

	if(#friends == 0) then return nil end
	return friends[math.random(1, #friends)]
end
--#endregion