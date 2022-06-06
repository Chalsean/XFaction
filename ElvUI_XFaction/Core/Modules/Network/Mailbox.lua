local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Mailbox'
local LogCategory = 'NMailbox'

Mailbox = {}

function Mailbox:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Messages = {}
    self._MessageCount = 0
    self._Initialized = false

    return _Object
end

function Mailbox:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Mailbox:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function Mailbox:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _MessageCount (" .. type(self._FriendCount) .. "): ".. tostring(self._FriendCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Message in self:Iterator() do
		_Message:Print()
	end
end

function Mailbox:GetKey()
    return self._Key
end

function Mailbox:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Mailbox:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Messages[inKey] ~= nil
end

function Mailbox:GetMessage(inKey)
	assert(type(inKey) == 'string')
    return self._Messages[inKey]
end

function Mailbox:AddMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
	if(self:Contains(inMessage:GetKey()) == false) then
		self._MessageCount = self._MessageCount + 1
	end
	self._Messages[inMessage:GetKey()] = inMessage
	return self:Contains(inMessage:GetKey())
end

function Mailbox:RemoveMessage(inKey)
	assert(type(inKey) == 'string')
	if(self:Contains(inKey)) then
		self._Messages[inKey] = nil
		self._MessageCount = self._MessageCount - 1
	end
	return self:Contains(inKey) == false
end

-- Review: Should back the epoch time an argument
function Mailbox:Purge()
	local _ServerEpochTime = GetServerTime()
	for _, _Message in self:Iterator() do
		if(_Message:GetTimeStamp() + 60 * 6 < _ServerEpochTime) then -- config
			self:RemoveMessage(_Message:GetKey())
		end
	end
end

function Mailbox:Iterator()
	return next, self._Messages, nil
end
