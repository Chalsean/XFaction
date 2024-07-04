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
		XF:Info(self:ObjectName(), 'Added link from [%s] to [%s]', inLink:From(), inLink:To())
		XF.DataText.Links:RefreshBroker()
	end
end

function XFC.LinkCollection:Remove(inKey)
    assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		local link = self:Get(inKey)
		self.parent.Remove(self, inKey)
		XF:Info(self:ObjectName(), 'Removed link from [%s] to [%s]', inLink:From(), inLink:To())
		self:Push(link)
		XF.DataText.Links:RefreshBroker()
	end
end

function XFC.LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
	if(inMessage:HasLinks()) then
		local links = string.Split(inMessage:Links(), ';')
		for _, to in ipairs(links) do
			local link = nil
			try(function()
				link = self:Pop()
				link:From(inMessage:From())
				link:To(to)
				link:Initialize()
				if(self:Contains(link:Key())) then
					self:Push(link)
				else
					self:Add(link)
				end
			end).
			catch(function(err)
				XF:Warn(self:ObjectName(), err)
				self:Push(link)
			end)
		end
	end
end

function XFC.LinkCollection:Backup()
	try(function ()
		if(self:IsInitialized()) then
			local serial = ''
			for _, link in self:Iterator() do
				serial = serial .. ';' .. link:Serialize()
			end
			XF.Cache.Backup.Links = serial
		end
	end).
	catch(function (err)
		XF.Cache.Errors[#XF.Cache.Errors + 1] = 'Failed to create links backup before reload: ' .. err
	end)
end

function XFC.LinkCollection:Restore()
	if(XF.Cache.Backup.Links ~= nil and strlen(XF.Cache.Backup.Links) > 0) then
		local links = string.Split(XF.Cache.Backup.Links, ';')
		for _, data in pairs (links) do
			local link = nil
			try(function()
				link = self:Pop()
				link:Deserialize(data)
				self:Add(link)
			end).
			catch(function(err)
				XF:Warn(self:ObjectName(), err)
				self:Push(link)
			end)
		end
	end
	XF.Cache.Backup.Links = ''
end

function XFC.LinkCollection:Unlink(inGUID)
	assert(type(inGUID) == 'string')
	for _, link in self:Iterator() do
		if(link:From() == inGUID or link:To() == inGUID) then
			self:Remove(inGUID)
		end
	end
end
--#endregion