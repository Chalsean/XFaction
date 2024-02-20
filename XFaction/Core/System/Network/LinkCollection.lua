local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'LinkCollection'
local GetCurrentTime = GetServerTime

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

--#region Hash
function XFC.LinkCollection:Add(inLink)
    assert(type(inLink) == 'table' and inLink.__name == 'Link', 'argument must be Link object')
	if(not self:Contains(inLink:GetKey())) then
		self.parent.Add(self, inLink)
		inLink:GetFromNode():IncrementLinkCount()
		inLink:GetToNode():IncrementLinkCount()
		if(inLink:IsMyLink()) then
			self:IncrementLinkCount()
		end
		XF:Info(self:GetObjectName(), 'Added link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())
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
		XF:Info(self:GetObjectName(), 'Removed link from [%s] to [%s]', link:GetFromNode():GetName(), link:GetToNode():GetName())
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
		if(link:IsMyLink()) then
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
				link:SetTimeStamp(GetCurrentTime())
				self:Add(link)
			else
				self:Get(link:GetKey()):SetTimeStamp(GetCurrentTime())
				self:Push(link)
			end
		end).
		catch(function(err)
			XF:Warn(self:GetObjectName(), err)
			self:Push(link)
		end)
    end
	-- FIX: Move to Mailbox
	-- A link message is a reset of the links for that node
	-- Remove stale links and update datetimes
	-- for _, link in self:Iterator() do
	-- 	-- Consider that we may have gotten link information from the other node
	-- 	if(link:GetFromNode():GetName() == sourceKey or link:GetToNode():GetName() == sourceKey) then
	-- 		if(not link:IsMyLink() and linkKeys[link:GetKey()] == nil) then
	-- 			self:Remove(link)
	-- 			XF:Debug(self:GetObjectName(), 'Removed link due to node broadcast [%s]', link:GetKey())
	-- 		else
	-- 			-- Update datetime for janitor process
	-- 			link:SetTimeStamp(GetCurrentTime())
	-- 		end
	-- 	end
	-- end
end
--#endregion

--#region Network
function XFC.LinkCollection:Broadcast()
	local self = XFO.Links
	XF:Debug(self:GetObjectName(), 'Broadcasting links')
	if(self:GetMyLinkCount() > 0) then
		local message = nil
		try(function ()
			message = XFO.Chat:Pop()
			message:Initialize()
			message:SetType(XF.Enum.Network.BROADCAST)
			message:SetSubject(XF.Enum.Message.LINK)
			message:SetData(self:Serialize())
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

function XFC.LinkCollection:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	local self = XFO.Links
	for _, link in self:Iterator() do
		if(not link:IsMyLink() and link:GetTimeStamp() < inEpochTime) then
			XF:Debug(self:GetObjectName(), 'Removing stale link')
			self:Remove(link:GetKey())
		end
	end
end
--#endregion