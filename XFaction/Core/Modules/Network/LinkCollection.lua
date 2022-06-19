local XFG, G = unpack(select(2, ...))
local ObjectName = 'LinkCollection'
local LogCategory = 'NCLink'

LinkCollection = {}

function LinkCollection:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Links = {}
    self._LinkCount = 0
	self._EpochTime = nil
    self._Initialized = false

    return _Object
end

function LinkCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self._EpochTime = 0
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function LinkCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function LinkCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _LinkCount (" .. type(self._LinkCount) .. "): ".. tostring(self._LinkCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    for _, _Link in self:Iterator() do
        _Link:Print()
    end
end

function LinkCollection:GetKey()
    return self._Key
end

function LinkCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function LinkCollection:Contains(inKey)
	assert(type(inKey) == 'string')
    return self._Links[inKey] ~= nil
end

function LinkCollection:GetLink(inKey)
	assert(type(inKey) == 'string')
    return self._Links[inKey]
end

function LinkCollection:LinkExists(inName1, inName2)
	for _, _Link in self:Iterator() do

	end
	return false
end

function LinkCollection:AddLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey()) == false) then
		self._LinkCount = self._LinkCount + 1
		XFG:Info(LogCategory, 'Added link from [%s] to [%s]', inLink:GetFromName(), inLink:GetToName())
	end
    self._Links[inLink:GetKey()] = inLink	
    return self:Contains(inLink:GetKey())
end

function LinkCollection:RemoveLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey())) then
		self._LinkCount = self._LinkCount - 1
		self._Links[inLink:GetKey()] = nil
		XFG:Info(LogCategory, 'Removed link from [%s] to [%s]', inLink:GetFromName(), inLink:GetToName())
	end
    return self:Contains(inLink:GetKey()) == false
end

function LinkCollection:Iterator()
	return next, self._Links, nil
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
				_FromName = _NewLink:GetFromName()
			end
		else
			XFG:Warn(LogCategory, 'Failed to parse received links message')
			return
		end
    end
	-- Remove any stale links
	for _, _Link in self:Iterator() do
		-- Consider that we may have gotten link information from the other node
		if((_Link:GetFromName() == _FromName or _Link:GetToName() == _FromName) and _Links[_Link:GetKey()] == nil) then
			self:RemoveLink(_Link)
			XFG:Debug(LogCategory, 'Removed link due to node broadcast [%s]', _Link:GetKey())
		end
	end
	-- Add any new links and update timestamps of existing
	for _, _Link in pairs (_Links) do
		if(self:Contains(_Link:GetKey())) then
			self:SetTimeStamp(GetServerTime())
		else
			self:AddLink(_Link)
			XFG:Debug(LogCategory, 'Added link due to node broadcast [%s]', _Link:GetKey())
		end
    end
end

function LinkCollection:GetCount()
	return self._LinkCount
end

function LinkCollection:IsNode(inName)
	assert(type(inName) == 'string')
	for _, _Link in self:Iterator() do
		if(_Link:GetFromName() == inName or _Link:GetToName() == inName) then
			return true
		end
	end
	return false
end

function LinkCollection:RemoveNode(inName)
	assert(type(inName) == 'string')
	for _, _Link in self:Iterator() do
		if(_Link:GetFromName() == inName or _Link:GetToName() == inName) then
			self:RemoveLink(_Link)
		end
	end
end

function LinkCollection:BroadcastLinks()
	if(self._EpochTime + 60 * 5 < GetServerTime()) then
		XFG:Debug(LogCategory, 'Broadcasting links')
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
			_NewMessage:SetType(XFG.Network.Type.BROADCAST)
			_NewMessage:SetSubject(XFG.Network.Message.Subject.LINK)
			_NewMessage:SetData(_LinksString)
			XFG.Network.Outbox:Send(_NewMessage)  
		end
	end
end

function LinkCollection:CreateBackup()
	local _LinksString = ''
    for _, _Link in self:Iterator() do
        _LinksString = _LinksString .. '|' .. _Link:GetString()
    end
	XFG.DB.Backup.Links = _LinksString
end

function LinkCollection:RestoreBackup()
	if(XFG.DB.Backup.Links ~= nil and strlen(XFG.DB.Backup.Links) > 0) then
		local _Links = string.Split(XFG.DB.Backup.Links, '|')
		for _, _Link in pairs (_Links) do
			local _NewLink = Link:new()
			_NewLink:SetObjectFromString(_Link)
			self:AddLink(_NewLink)
		end
	end
end

function LinkCollection:PurgeStaleLinks(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _, _Link in self:Iterator() do
		if(_Link:GetTimeStamp() < inEpochTime) then
			XFG:Debug(LogCategory, 'Removing stale link')
			self:RemoveLink(_Link)
		end
	end
end