local XFG, G = unpack(select(2, ...))

LinkCollection = ObjectCollection:newChildConstructor()

function LinkCollection:new()
    local _Object = LinkCollection.parent.new(self)
	_Object.__name = 'LinkCollection'
	_Object._EpochTime = 0
	return _Object
end

function LinkCollection:AddLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(not self:Contains(inLink:GetKey())) then
		self:AddObject(inLink)
		inLink:GetFromNode():IncrementLinkCount()
		inLink:GetToNode():IncrementLinkCount()
		XFG:Info(self:GetObjectName(), 'Added link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())
		XFG.DataText.Links:RefreshBroker()	
	end	
    return self:Contains(inLink:GetKey())	
end

function LinkCollection:RemoveLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey())) then
		self:RemoveObject(inLink:GetKey())
		inLink:GetFromNode():DecrementLinkCount()
		inLink:GetToNode():DecrementLinkCount()
		XFG:Info(self:GetObjectName(), 'Removed link from [%s] to [%s]', inLink:GetFromNode():GetName(), inLink:GetToNode():GetName())		
		XFG.DataText.Links:RefreshBroker()
	end
    return not self:Contains(inLink:GetKey())
end

-- A link message is a reset of the links for that node
function LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
	local _LinkStrings = string.Split(inMessage:GetData(), '|')
	local _Links = {}
	local _FromName = nil
	-- Compile a list of the updated links
    for _, _LinkString in pairs (_LinkStrings) do
		local _NewLink = Link:new()
		if(pcall(function () _NewLink:SetObjectFromString(_LinkString) end)) then
			-- Dont process players own links
			if(_NewLink:IsMyLink() == false) then
				_Links[_NewLink:GetKey()] = _NewLink
				-- All links in the message should be "From" the same person
				_FromName = _NewLink:GetFromNode():GetName()
			end
		else
			XFG:Warn(self:GetObjectName(), 'Failed to parse received links message')
			return
		end
    end
	-- Remove any stale links
	for _, _Link in self:Iterator() do
		-- Consider that we may have gotten link information from the other node
		if(not _Link:IsMyLink() and (_Link:GetFromNode():GetName() == _FromName or _Link:GetToNode():GetName() == _FromName) and _Links[_Link:GetKey()] == nil) then
			self:RemoveLink(_Link)
			XFG:Debug(self:GetObjectName(), 'Removed link due to node broadcast [%s]', _Link:GetKey())
		end
	end
	-- Add any new links and update timestamps of existing
	for _, _Link in pairs (_Links) do
		if(self:Contains(_Link:GetKey())) then
			local _EpochTime = GetServerTime()
			_Link:SetTimeStamp(_EpochTime)
		else
			self:AddLink(_Link)
			XFG:Debug(self:GetObjectName(), 'Added link due to node broadcast [%s]', _Link:GetKey())
		end
    end
end

function LinkCollection:BroadcastLinks()
	XFG:Debug(self:GetObjectName(), 'Broadcasting links')
	self._EpochTime = GetServerTime()
	local _LinksString = ''
	for _, _Link in self:Iterator() do
		if(_Link:IsMyLink()) then
			_LinksString = _LinksString .. '|' .. _Link:GetString()
		end
	end

	if(strlen(_LinksString) > 0) then
		local _NewMessage = Message:new()
		_NewMessage:Initialize()
		_NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
		_NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.LINK)
		_NewMessage:SetData(_LinksString)
		XFG.Outbox:Send(_NewMessage)  
	end
end

function LinkCollection:CreateBackup()
	try(function ()
		local _LinksString = ''
		for _, _Link in self:Iterator() do
			_LinksString = _LinksString .. '|' .. _Link:GetString()
		end
		XFG.DB.Backup.Links = _LinksString
	end).
	catch(function (inErrorMessage)
		table.insert(XFG.DB.Errors, 'Failed to create links backup before reload: ' .. inErrorMessage)
	end)
end

function LinkCollection:RestoreBackup()
	
	if(XFG.DB.Backup.Links ~= nil and strlen(XFG.DB.Backup.Links) > 0) then
		try(function ()
			local _Links = string.Split(XFG.DB.Backup.Links, '|')
			for _, _Link in pairs (_Links) do
				if(_Link ~= nil) then
					local _NewLink = Link:new()
					_NewLink:SetObjectFromString(_Link)
					self:AddLink(_NewLink)
					XFG:Debug(self:GetObjectName(), 'Restored link from backup [%s]', _NewLink:GetKey())
				end
			end
		end).
		catch(function (inErrorMessage)
			XFG:Warn(self:GetObjectName(), 'Failed to restore link information from backup: ' .. inErrorMessage)
		end)
	end	
end

function LinkCollection:PurgeStaleLinks(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _, _Link in self:Iterator() do
		if(not _Link:IsMyLink() and _Link:GetTimeStamp() < inEpochTime) then
			XFG:Debug(self:GetObjectName(), 'Removing stale link')
			self:RemoveLink(_Link)
		end
	end
end