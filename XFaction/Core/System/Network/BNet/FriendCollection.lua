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
	object.byTargetCount = nil
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
		self.byTargetCount = {}
		for _, target in XFO.Targets:Iterator() do
			self.byTarget[target:Key()] = {}
			self.byTargetCount[target:Key()] = 0
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
        })

		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.FriendCollection:LinkCount()
	return self.byGUIDCount
end

function XFC.FriendCollection:LinkCountByTarget(inTarget)
	assert(type(inTarget) == 'table' and inTarget.__name == 'Target')
	return self.byTargetCount[inTarget:Key()] or 0
end
--#endregion

--#region Methods
function XFC.FriendCollection:Print()
	self:ParentPrint()
	XF:DataDumper(self:ObjectName(), self.byTargetCount)
end

function XFC.FriendCollection:Add(inFriend)
	assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')

	if(self:Contains(inFriend:Key())) then
		local oldFriend = self:Get(inFriend:Key())

		-- Works but lord is it messy
		if(oldFriend:HasTarget() and not inFriend:HasTarget()) then
			self.byTarget[oldFriend:Target():Key()][oldFriend:Key()] = nil
			self.byTargetCount[oldFriend:Target():Key()] = self.byTargetCount[oldFriend:Target():Key()] - 1
		elseif(not oldFriend:HasTarget() and inFriend:HasTarget()) then
			self.byTarget[inFriend:Target():Key()][inFriend:Key()] = inFriend
			self.byTargetCount[inFriend:Target():Key()] = self.byTargetCount[inFriend:Target():Key()] + 1
		end

		if(oldFriend:GUID() ~= nil and inFriend:GUID() == nil) then
			self.byGUID[oldFriend:GUID()] = nil
			self.byGUIDCount = self.byGUIDCount - 1
		elseif(oldFriend:GUID() == nil and inFriend:GUID() ~= nil) then
			self.byGUID[inFriend:GUID()] = inFriend
			self.byGUIDCount = self.byGUIDCount + 1
		end
		
		self.parent.Add(self, inFriend)
		self:Push(oldFriend)
	else
		self.parent.Add(self, inFriend)
		if(inFriend:HasTarget()) then
			self.byTarget[inFriend:Target():Key()][inFriend:Key()] = inFriend
			self.byTargetCount[inFriend:Target():Key()] = self.byTargetCount[inFriend:Target():Key()] + 1
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
	XF:Debug(self:ObjectName(), 'Checking friend: %d', inID)

	-- Detect friend going offline
	local friend = nil
	try(function()
		friend = self:Pop()
		friend:Initialize(inID)
		if(self:Contains(friend:Key())) then
			local oldFriend = self:Get(friend:Key())
			if(oldFriend:IsOnline() and not friend:IsOnline()) then
				XF:Debug(self:ObjectName(), 'Detected BNet logout: %s', oldFriend:Name())			
				if(XFO.Confederate:Contains(oldFriend:GUID())) then
					XFO.Confederate:Logout(oldFriend:GUID())
				-- else
				-- 	local unitName = oldFriend:Name() .. '-' .. oldFriend:Realm():APIName()
				-- 	XFO.SystemFrame:DisplayLogout(unitName)
				end
				self:Replace(friend)
				return
			end
		end
		self:Push(friend)
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
		self:Push(friend)
	end)
end

function XFC.FriendCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

	local friend = self:Get(inMessage:From())
	if(friend == nil) then
		friend = self:Pop()
		friend:Initialize(inMessage:From())
		friend:Target(inMessage:FromUnit():Target())
		friend:IsLinked(true)
		self:Add(friend)
	else
		if(not friend:HasTarget()) then
			self.byTarget[inMessage:FromUnit():Target():Key()][friend:Key()] = friend
			self.byTargetCount[inMessage:FromUnit():Target():Key()] = self.byTargetCount[inMessage:FromUnit():Target():Key()] + 1
			friend:Target(inMessage:FromUnit():Target())
		end

		if(not friend:IsLinked()) then
			friend:IsLinked(true)
		end
	end

	XFO.DTLinks:RefreshBroker()
	
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