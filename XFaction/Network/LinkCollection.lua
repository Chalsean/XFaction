local XFG, G = unpack(select(2, ...))
local ObjectName = 'LinkCollection'

local ServerTime = GetServerTime

LinkCollection = Factory:newChildConstructor()

function LinkCollection:new()
    local _Object = LinkCollection.parent.new(self)
	_Object.__name = ObjectName
	_Object._EpochTime = 0
	return _Object
end

function LinkCollection:NewObject()
	return Link:new()
end

function LinkCollection:Add(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(not self:Contains(inLink:GetKey())) then
		self.parent.Add(self, inLink)
		inLink:GetFromNode():IncrementLinkCount()
		inLink:GetToNode():IncrementLinkCount()
		if(XFG.DebugFlag) then
			XFG:Info(ObjectName, 'Added link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())
		end
		XFG.DataText.Links:RefreshBroker()	
	end
end

function LinkCollection:Remove(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey())) then
		self.parent.Remove(self, inLink:GetKey())
		inLink:GetFromNode():DecrementLinkCount()
		inLink:GetToNode():DecrementLinkCount()
		if(XFG.DebugFlag) then
			XFG:Info(ObjectName, 'Removed link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())		
		end
		XFG.DataText.Links:RefreshBroker()
		self:Push(inLink)
	end
end

-- A link message is a reset of the links for that node
function LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
	local _LinkStrings = string.Split(inMessage:GetData(), '|')
	local _LinkKeys = {}
	local _SourceKey = nil	
	-- Add new links
    for _, _LinkString in pairs (_LinkStrings) do
		local _LinkKey, _From = self:SetLinkFromString(_LinkString)
		if(_LinkKey ~= nil) then 
			_LinkKeys[_LinkKey] = true 
			_SourceKey = _From
		end
    end
	-- Remove stale links
	for _, _Link in self:Iterator() do
		-- Consider that we may have gotten link information from the other node
		if(not _Link:IsMyLink() and (_Link:GetFromNode():GetName() == _SourceKey or _Link:GetToNode():GetName() == _SourceKey) and _LinkKeys[_Link:GetKey()] == nil) then
			self:Remove(_Link)
			if(XFG.DebugFlag) then
				XFG:Debug(ObjectName, 'Removed link due to node broadcast [%s]', _Link:GetKey())
			end
		end
	end
end

function LinkCollection:SetLinkFromString(inLinkString)
    assert(type(inLinkString) == 'string')

    local _Nodes = string.Split(inLinkString, ';')
    local _FromNode = XFG.Nodes:SetNodeFromString(_Nodes[1])
    local _ToNode = XFG.Nodes:SetNodeFromString(_Nodes[2])

	-- Can remove equality check once everyone updates to 3.9.6
	if(_FromNode:IsMyNode() or _ToNode:IsMyNode() or _FromNode:Equals(_ToNode)) then
		return nil
	end

	local _LinkKey = XFG:GetLinkKey(_FromNode:GetName(), _ToNode:GetName())
	if(self:Contains(_LinkKey)) then
		return self:Get(_LinkKey), _FromNode:GetName()
	end

	local _Link = self:Pop()
	_Link:SetFromNode(_FromNode)
	_Link:SetToNode(_ToNode)
    _Link:Initialize()
	self:Add(_Link)
	_FromNode:IncrementLinkCount()
	_ToNode:IncrementLinkCount()

	return _LinkKey, _FromNode:GetName()
end

function LinkCollection:Broadcast()
	XFG:Debug(ObjectName, 'Broadcasting links')
	self._EpochTime = ServerTime()
	local _LinksString = ''
	local _HaveLinks = false
	for _, _Link in self:Iterator() do
		if(_Link:IsMyLink()) then
			_HaveLinks = true
			_LinksString = _LinksString .. '|' .. _Link:GetString()
		end
	end

	if(not _HaveLinks) then return end

	local _NewMessage = nil
	try(function ()
		_NewMessage = XFG.Mailbox.Chat:Pop()
		_NewMessage:Initialize()
		_NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
		_NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.LINK)
		_NewMessage:SetData(_LinksString)
		XFG.Mailbox.Chat:Send(_NewMessage)  
	end).
	finally(function ()
		XFG.Mailbox.Chat:Push(_NewMessage)
	end)
end

function LinkCollection:Backup()
	try(function ()
		local _LinksString = ''
		for _, _Link in self:Iterator() do
			_LinksString = _LinksString .. '|' .. _Link:GetString()
		end
		XFG.DB.Backup.Links = _LinksString
	end).
	catch(function (inErrorMessage)
		XFG.DB.Errors[#XFG.DB.Errors + 1] = 'Failed to create links backup before reload: ' .. inErrorMessage
	end)
end

function LinkCollection:Restore()
	
	if(XFG.DB.Backup.Links ~= nil and strlen(XFG.DB.Backup.Links) > 0) then
		try(function ()
			local _Links = string.Split(XFG.DB.Backup.Links, '|')
			for _, _Link in pairs (_Links) do
				self:SetLinkFromString(_Link)
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(ObjectName, inErrorMessage)
		end)
	end	
end

function LinkCollection:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _, _Link in self:Iterator() do
		if(not _Link:IsMyLink() and _Link:GetTimeStamp() < inEpochTime) then
			XFG:Debug(ObjectName, 'Removing stale link')
			self:Remove(_Link)
		end
	end
end