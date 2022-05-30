local XFG, E, L, V, P, G = unpack(select(2, ...))
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
		XFG:RegisterEvent('CHAT_MSG_GUILD', self.CallbackGuildMessage)
        XFG:Info(LogCategory, "Registered for CHAT_MSG_GUILD events")
        XFG:RegisterEvent('CHAT_MSG_CHANNEL', self.CallbackChannelMessage)
        XFG:Info(LogCategory, "Registered for CHAT_MSG_CHANNEL events")
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
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function ChatEvent:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    -- If you are the sender, broadcast to other realms/factions
    if(XFG.Player.GUID == inSenderGUID) then
        local _NewMessage = GuildMessage:new()
        _NewMessage:Initialize()
        _NewMessage:SetTo(XFG.Player.GuildName .. ":" .. XFG.Player.RealmName)
        _NewMessage:SetFrom(inSenderName)
        _NewMessage:SetFromGUID(inSenderGUID)
        _NewMessage:SetType(XFG.Network.Type.BROADCAST)
        _NewMessage:SetSubject(XFG.Network.Message.Subject.GUILD_CHAT)
        _NewMessage:SetFlags(inFlags)
        _NewMessage:SetLineID(inLineID)
        _NewMessage:SetFaction(XFG.Player.Faction)
        _NewMessage:SetData(inText)
        _NewMessage:Print()
        XFG.Network.Sender:SendMessage(_NewMessage, true)
    end
end

function ChatEvent:CallbackChannelMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    if(XFG.Player.GUID == inSenderGUID) then
        local _NewMessage = GuildMessage:new()
        _NewMessage:Initialize()
        _NewMessage:SetTo(XFG.Player.GuildName .. ":" .. XFG.Player.RealmName)
        _NewMessage:SetFrom(inSenderName)
        _NewMessage:SetFromGUID(inSenderGUID)
        _NewMessage:SetType(XFG.Network.Type.BROADCAST)
        _NewMessage:SetSubject(XFG.Network.Message.Subject.GUILD_CHAT)
        _NewMessage:SetFlags(inFlags)
        _NewMessage:SetLineID(inLineID)
        _NewMessage:SetFaction(XFG.Player.Faction)
        _NewMessage:SetData(inText)
        _NewMessage:Print()
        XFG.Network.Sender:SendMessage(_NewMessage, true)
    end
end