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
        CON:RegisterEvent('CHAT_MSG_CHANNEL', self.CallbackChannelMessage)
        CON:Info(LogCategory, "Registered for CHAT_MSG_CHANNEL events")
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

function ChatEvent:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    CON:Debug(LogCategory, "Guild message [%s][%s]", inText, inSenderName)

    -- If you are the sender, broadcast to other realms/factions
    --if(CON.Player.GUID == inSenderGUID) then
        local _NewMessage = Message:new()
        _NewMessage:Initialize()
        _NewMessage:SetFrom(CON.Player.GuildName)
        _NewMessage:SetFromGUID(inSenderGUID)
        _NewMessage:SetType(CON.Network.Type.BROADCAST)
        _NewMessage:SetSubject(CON.Network.Message.Subject.GUILD_CHAT)
        _NewMessage:SetFlags(inFlags)
        _NewMessage:SetLineID(inLineID)
        _NewMessage:SetFaction(CON.Player.Faction)
        _NewMessage:SetData(inText)
        _NewMessage:Print()
        CON:Debug(LogCategory, inText)
        CON.Network.Sender:SendMessage(_NewMessage)
    --end
end

function ChatEvent:CallbackChannelMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
end