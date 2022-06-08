local XFG, E, L, V, P, G = unpack(select(2, ...))
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
    self._Initialized = false

    return _Object
end

function LinkCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		for _, _Friend in XFG.Network.BNet.Friends:Iterator() do
			local _Target = _Friend:GetTarget()
			local _NewLink = Link:new()
			_NewLink:SetToUnitName(_Friend:GetUnitName())
			_NewLink:SetToRealm(_Target:GetRealm())
			_NewLink:SetToFaction(_Target:GetFaction())
			_NewLink:Initialize()
			_NewLink:Print()
			self:AddLink(_NewLink)
		end
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

function LinkCollection:AddLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey()) == false) then
		self._LinkCount = self._LinkCount + 1
	end
    self._Links[inLink:GetKey()] = inLink
    return self:Contains(inLink:GetKey())
end

function LinkCollection:RemoveLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name ~= nil and inLink.__name == 'Link', "argument must be Link object")
	if(self:Contains(inLink:GetKey())) then
		self._LinkCount = self._LinkCount - 1
		self._Links[inLink:GetKey()] = nil
	end    
    return self:Contains(inLink:GetKey()) == false
end

function LinkCollection:Iterator()
	return next, self._Links, nil
end

-- A link message is a reset of the links for that node
function LinkCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
	local _Links = string.Split(inMessage:GetData(), '|')
	-- First remove all links that contain sending node
    for _, _Link in pairs (_Links) do
		local _NewLink = Link:new()
		_NewLink:SetObjectFromString(_Link)
		self:RemoveNode(_NewLink:GetFromUnitName())
		break
    end
	-- Then add the new links
	for _, _Link in pairs (_Links) do
		local _NewLink = Link:new()
		_NewLink:SetObjectFromString(_Link)
		self:AddLink(_NewLink)
    end
end

function LinkCollection:GetLinkCount()
	return self._LinkCount
end

function LinkCollection:IsNode(inUnitName)
	assert(type(inUnitName) == 'string')
	for _, _Link in self:Iterator() do
		if(_Link:GetFromUnitName() == inUnitName or _Link:GetToUnitName() == inUnitName) then
			return true
		end
	end
	return false
end

function LinkCollection:RemoveNode(inUnitName)
	assert(type(inUnitName) == 'string')
	for _, _Link in self:Iterator() do
		if(_Link:GetFromUnitName() == inUnitName or _Link:GetToUnitName() == inUnitName) then
			self:RemoveLink(_Link)
		end
	end
end

function LinkCollection:BroadcastLinks()
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