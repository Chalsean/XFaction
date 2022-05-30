local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'MessageCollection'
local LogCategory = 'NCMessage'

MessageCollection = {}

function MessageCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
		self._Key = nil
        self._Messages = {}
		self._MessageCount = 0
		self._Initialized = false
    end

    return Object
end

function MessageCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function MessageCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function MessageCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _MessageCount (" .. type(self._FriendCount) .. "): ".. tostring(self._FriendCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Message in pairs (self._Messages) do
		_Message:Print()
	end
end

function MessageCollection:GetKey()
    return self._Key
end

function MessageCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function MessageCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Messages[inKey] ~= nil
end

function MessageCollection:GetMessage(inKey)
	assert(type(inKey) == 'string')
    return self._Messages[inKey]
end

function MessageCollection:AddMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
	if(self:Contains(inMessage:GetKey()) == false) then
		self._MessageCount = self._MessageCount + 1
	end
	self._Messages[inMessage:GetKey()] = inMessage
	return self:Contains(inMessage:GetKey())
end

function MessageCollection:RemoveMessage(inKey)
	assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		table.RemoveKey(self._Messages, inKey)
		self._MessageCount = self._MessageCount - 1
	end
	return self:Contains(inKey) == false
end

function MessageCollection:Purge()
	local _ServerEpochTime = GetServerTime()
	for _, _Message in pairs(self._Messages) do
		if(_Message:GetTimeStamp() < _ServerEpochTime - 60 * 5) then -- config
			self:RemoveMessage(_Message)
		end
	end
end

function MessageCollection:Iterator()
	return next, self._Messages, nil
end