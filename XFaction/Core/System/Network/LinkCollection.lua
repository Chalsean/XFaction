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

function XFC.LinkCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		XF.Timers:Add({
			name = 'Links', 
			delta = XF.Settings.Network.BNet.Link.Broadcast, 
			callback = XFO.Links.CallbackLegacyBroadcast,
			repeater = true, 
			instance = true
		})	

		self:IsInitialized(true)
	end
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

function XFC.LinkCollection:RemoveAll(inUnit)
	assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil)

	if(inUnit ~= nil) then
		local remove = {}
		for _, link in self:Iterator() do
			if(link:HasNode(inUnit)) then
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

    -- Deprecated, remove after 4.13
    if(inMessage:Version():IsNewer(XF.DeprecatedVersion, true)) then
        if(inMessage:Subject() == XF.Enum.Message.LINK) then
            self:LegacyDeserialize(inMessage:Data())
            XF.DataText.Links:RefreshBroker()
        end
    else
        self:Deserialize(inMessage:Links())
        XF.DataText.Links:RefreshBroker()
    end
end

function XFC.LinkCollection:Serialize()
    local serial = ''
	for _, link in self:Iterator() do
		if(link:IsMyLink()) then
			serial = serial .. '|' .. link:Serialize()
		end
	end
	return serial
end

function XFC.LinkCollection:Deserialize(inFromUnit, inSerial)
    assert(type(inSerial) == 'string')
	local links = {}
    for _, link in pairs (string.Split(inSerial, '|')) do
        local obj = self:Pop()
		try(function()
			obj:Deserialize(inFromUnit, link)
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
		if(link:HasNode(inFromUnit)) then
			if(links[link:Key()] == nil) then
				self:Remove(link:Key())
				self:Push(link)
			end
		end
	end
end

-- Deprecated, remove after 4.13
function XFC.LinkCollection:LegacySerialize()
	local serial = ''
	for _, link in self:Iterator() do
		if(link:IsMyLink()) then
			serial = serial .. '|' .. link:LegacySerialize()
		end
	end
	return serial
end

-- Deprecated, remove after 4.13
function XFC.LinkCollection:LegacyDeserialize(inSerial)
	assert(type(inSerial) == 'string')
	local links = {}
	local fromName
	local fromTarget

    for _, link in pairs (string.Split(inSerial, '|')) do
		local obj = self:Pop()
		try(function()
			obj:LegacyDeserialize(link)
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
		if(link:LegacyHasNode(fromName, fromTarget:Realm(), fromTarget:Faction())) then
			if(links[link:Key()] == nil) then
				self:Remove(link:Key())
				self:Push(link)
			end
		end
	end
end

-- Deprecated, remove after 4.13
function XFC.LinkCollection:CallbackBroadcast()
    local self = XFO.Links
	try(function()
        XFO.Chat:SendLinkMessage(self:LegacySerialize())
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.LinkCollection:Backup()
	try(function ()
		XF.Cache.Backup.Links = self:Serialize()
	end).
	catch(function (err)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create links backup before reload: ' .. err
	end)
end

function XFC.LinkCollection:Restore()
	if(XF.Cache.Backup.Links ~= nil and strlen(XF.Cache.Backup.Links) > 0) then
		try(function ()
			self:Deserialize(XF.Player.Unit, XF.Cache.Backup.Links)
		end).
		catch(function (err)
			XF:Warn(self:ObjectName(), err)
		end)
	end
	XF.Cache.Backup.Links = ''
end

-- Deprecated, remove after 4.13
function XFC.LinkCollection:CallbackLegacyBroadcast()
	try(function ()
		XFO.Chat:SendLinkMessage(XFO.Links:LegacySerialize())
	end).
	catch(function (err)
		XF:Warn(self:ObjectName(), err)
	end).
	finally(function ()
		XF.Timers:Get('Links'):SetLastRan(XFF.TimeGetCurrent())
	end)
end
--#endregion