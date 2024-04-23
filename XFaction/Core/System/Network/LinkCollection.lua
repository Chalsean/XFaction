local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'LinkCollection'

XFC.LinkCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.LinkCollection:new()
    local object = XFC.LinkCollection.parent.new(self)
	object.__name = ObjectName
	object.myLinkCount = 0
	return object
end

function XFC.LinkCollection:NewObject()
	return XFC.Link:new()
end
--#endregion

--#region Initializer
function XFC.LinkCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		XFO.Timers:Add({
			name = 'Links', 
			delta = XF.Settings.Network.BNet.Link.Broadcast, 
			callback = XFO.Links.Broadcast, 
			repeater = true, 
			instance = true
		})
		XFO.Timers:Add({
			name = 'StaleLinks', 
			delta = XF.Settings.Network.BNet.Link.Scan, 
			callback = XFO.Links.Janitor, 
			repeater = true, 
			instance = true
		})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Hash
function XFC.LinkCollection:Add(inLink)
    assert(type(inLink) == 'table' and inLink.__name == 'Link', 'argument must be Link object')
	if(not self:Contains(inLink:GetKey())) then
		self.parent.Add(self, inLink)
		inLink:GetFromNode():IncrementLinkCount()
		inLink:GetToNode():IncrementLinkCount()
		if(inLink:IsMyLink()) then
			self:IncrementMyLinkCount()
		end
		XF:Info(self:ObjectName(), 'Added link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())
		XFO.DTLinks:RefreshBroker()
	end
end

function XFC.LinkCollection:Remove(inKey)
    assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		local link = self:Get(inKey)
		self.parent.Remove(self, inKey)
		link:GetFromNode():DecrementLinkCount()
		link:GetToNode():DecrementLinkCount()
		if(link:IsMyLink()) then
			self:DecrementLinkCount()
		end
		XF:Info(self:ObjectName(), 'Removed link from [%s] to [%s]', link:GetFromNode():GetName(), link:GetToNode():GetName())
		self:Push(link)
		XFO.DTLinks:RefreshBroker()
	end
end
--#endregion

--#region Accessors
function XFC.LinkCollection:GetMyLinkCount()
	return self.myLinkCount
end

function XFC.LinkCollection:IncrementMyLinkCount()
	self.myLinkCount = self.myLinkCount + 1
end

function XFC.LinkCollection:DecrementMyLinkCount()
	self.myLinkCount = self.myLinkCount - 1
end
--#endregion

--#region Serialization
function XFC.LinkCollection:Serialize()
	local serialized = ''
	for _, link in self:Iterator() do
		if(link:IsMyLink() and link:IsActive()) then
			serialized = serialized .. '|' .. link:Serialize()
		end
	end
	return serialized
end

function XFC.LinkCollection:Deserialize(inSerialized)
	assert(type(inSerialized) == 'string')
	local links = string.Split(inSerialized, '|')
	
    for _, serialLink in pairs (links) do
		local link = nil
		try(function()
			link = self:Pop()
			link:Deserialize(serialLink)
			if(not self:Contains(link:GetKey())) then
				link:SetTimeStamp(XFF.TimeGetCurrent())
				self:Add(link)
			else
				self:Get(link:GetKey()):SetTimeStamp(XFF.TimeGetCurrent())
				self:Push(link)
			end
		end).
		catch(function(err)
			XF:Warn(self:ObjectName(), err)
			self:Push(link)
		end)
    end
end
--#endregion

--#region Network
function XFC.LinkCollection:Broadcast()
	local self = XFO.Links
	XF:Debug(self:ObjectName(), 'Broadcasting links')
	if(self:GetMyLinkCount() > 0) then
		local message = nil
		try(function ()
			message = XFO.Chat:Pop()
			message:Initialize()
			message:Type(XF.Enum.Network.BROADCAST)
			message:Subject(XF.Enum.Message.LINK)
			message:Data(self:Serialize())
			XFO.Chat:Send(message)  
		end).
		finally(function ()
			XFO.Chat:Push(message)
		end)
	end
end
--#endregion

--#region Janitorial
function XFC.LinkCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			XF.Cache.Backup.Links = self:Serialize()
		end
	end).
	catch(function (err)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create links backup before reload: ' .. err
	end)
end

function XFC.LinkCollection:Restore()
	if(XF.Cache.Backup.Links ~= nil and strlen(XF.Cache.Backup.Links) > 0) then
		try(function ()
			self:Deserialize(XF.Cache.Backup.Links)
		end).
		catch(function (err)
			XF:Warn(self:GetObjectName(), err)
		end)
	end
	XF.Cache.Backup.Links = ''
end

function XFC.LinkCollection:Janitor()
	local self = XFO.Links
	local ttl = XFF.TimeGetCurrent() - XF.Settings.Network.BNet.Link.Stale

	for _, link in self:Iterator() do
		if(not link:IsMyLink() and link:GetTimeStamp() < ttl) then
			XF:Debug(self:GetObjectName(), 'Disabling stale link')
			link:IsActive(false)
		end
	end
end
--#endregion