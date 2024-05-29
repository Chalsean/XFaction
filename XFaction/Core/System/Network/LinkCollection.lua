local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'LinkCollection'

XFC.LinkCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.LinkCollection:new()
    local object = XFC.LinkCollection.parent.new(self)
	object.__name = ObjectName
	return object
end

function XFC.LinkCollection:NewObject()
	return XFC.Link:new()
end
--#endregion

--#region Methods
function XFC.LinkCollection:Add(inLink)
    assert(type(inLink) == 'table' and inLink.__name == 'Link')
	if(not self:Contains(inLink:Key())) then
		self.parent.Add(self, inLink)
		XF:Info(self:ObjectName(), 'Added link from [%s] to [%s]', inLink:FromName(), inLink:ToName())
		XF.DataText.Links:RefreshBroker()
	end
end

function XFC.LinkCollection:Remove(inKey)
    assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		local link = self:Get(inKey)
		XF:Info(self:ObjectName(), 'Removing link from [%s] to [%s]', link:FromName(), link:ToName())
		self.parent.Remove(self, inKey)
		self:Push(link)
		XF.DataText.Links:RefreshBroker()
	end
end

function XFC.LinkCollection:RemoveAll(inName, inRealm, inFaction)
	assert(type(inName) == 'string')
	assert(type(inRealm) == 'table' and inRealm.__name == 'Realm')
	assert(type(inFaction) == 'table' and inFaction.__name == 'Faction')

	if(inName ~= nil) then
		local remove = {}
		for _, link in self:Iterator() do
			if(link:HasNode(inName, inRealm, inFaction)) then
				remove[link:Key()] = true
			end
		end

		for key in pairs(remove) do
			self:Remove(key)
		end
	else
		self.parent.RemoveAll(self)
	end
end

function XFC.LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')	
	self:Deserialize(inMessage:GetData())
	XF.DataText.Links:RefreshBroker()
end

function XFC.LinkCollection:Serialize(onlyMine)
	local serial = ''
	for _, link in self:Iterator() do
		if(link:IsMyLink() or not onlyMine) then
			serial = serial .. '|' .. link:Serialize()
		end
	end
	return serial
end

function XFC.LinkCollection:Deserialize(inSerial)
	assert(type(inSerial) == 'string')
	local links = {}
	local fromName
	local fromTarget

    for _, link in pairs (string.Split(inSerial, '|')) do
		local obj = self:Pop()
		try(function()
			obj:Deserialize(link)
			fromName = obj:FromName()
			fromTarget = obj:FromTarget()
			links[obj:Key()] = true
			if(not self:Contains(obj:Key())) then
				self:Add(obj)
			end
		end).
		catch(function(err)
			XF:Warn(self:ObjectName(), err)
			self:Push(obj)
		end)
    end

	for _, link in self:Iterator() do
		if(link:HasNode(fromName, fromTarget:GetRealm(), fromTarget:GetFaction())) then
			if(links[link:Key()] == nil) then
				self:Remove(link:Key())
				self:Push(link)
			end
		end
	end
end

function XFC.LinkCollection:Broadcast()
	XF:Debug(ObjectName, 'Broadcasting links')

	local message = nil
	try(function ()
		message = XF.Mailbox.Chat:Pop()
		message:Initialize()
		message:SetType(XF.Enum.Network.BROADCAST)
		message:SetSubject(XF.Enum.Message.LINK)
		message:SetData(self:Serialize(true))
		XF.Mailbox.Chat:Send(message)  
	end).
	finally(function ()
		XF.Mailbox.Chat:Push(message)
	end)
end

function XFC.LinkCollection:Backup()
	try(function ()
		XF.Cache.Backup.Links = self:Serialize(true)
	end).
	catch(function (inErrorMessage)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create links backup before reload: ' .. inErrorMessage
	end)
end

function XFC.LinkCollection:Restore()
	if(XF.Cache.Backup.Links ~= nil and strlen(XF.Cache.Backup.Links) > 0) then
		try(function ()
			self:Deserialize(XF.Cache.Backup.Links)
		end).
		catch(function (inErrorMessage)
			XF:Warn(ObjectName, inErrorMessage)
		end)
	end
	XF.Cache.Backup.Links = ''
end
--#endregion