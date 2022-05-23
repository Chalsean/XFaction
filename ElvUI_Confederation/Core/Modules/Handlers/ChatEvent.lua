local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ChatEvent'
local LogCategory = 'HEChat'

ChatEvent = {}

function ChatEvent:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Initialized = false
    end

    return Object
end

function ChatEvent:Initialize()
	if(self:IsInitialized() == false) then
		CON:RegisterEvent('CHAT_MSG_GUILD', self.CallbackGuildMessage)
        CON:Info(LogCategory, "Registered for CHAT_MSG_GUILD events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ChatEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ChatEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

-- The event doesn't tell you what has changed, only that something has changed
function ChatEvent:CallbackGuildMessage(inText, inSenderName, _, _ChannelName, _, _, _, _, _, _, inSenderGUID, inBNetFriendID)
    CON:Debug(LogCategory, "Guild message [%s][%s][%s][%s]", inText, inSenderName, _ChannelName, inSenderGUID)
end