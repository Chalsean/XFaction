local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatEvent'
local LogCategory = 'HEChat'

ChatEvent = {}

function ChatEvent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Initialized = false

    return Object
end

function ChatEvent:Initialize()
	if(self:IsInitialized() == false) then
        XFG:RegisterEvent('CHAT_MSG_GUILD', XFG.Handlers.ChatEvent.CallbackGuildMessage)
        XFG:Info(LogCategory, 'Registered for CHAT_MSG_GUILD events')
        ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', XFG.Handlers.ChatEvent.ChatFilter)
        XFG:Info(LogCategory, 'Created CHAT_MSG_GUILD event filter')
        ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD_ACHIEVEMENT', XFG.Handlers.ChatEvent.ChatFilter)
        XFG:Info(LogCategory, 'Created CHAT_MSG_GUILD_ACHIEVEMENT event filter')
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
        _NewMessage:SetFrom(XFG.Player.Unit:GetKey())
        _NewMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
        _NewMessage:SetSubject(XFG.Settings.Network.Message.Subject.GCHAT)
        _NewMessage:SetUnitName(XFG.Player.Unit:GetUnitName())
        _NewMessage:SetGuild(XFG.Player.Guild)
        _NewMessage:SetRealm(XFG.Player.Realm)
        if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
            _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
        end
        _NewMessage:SetData(inText)
        XFG.Outbox:Send(_NewMessage, true)
    end
end

function ChatEvent:ChatFilter(inEvent, inMessage, inSender, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, ...)
    XFG:Error(LogCategory, inMessage)
    XFG:Error(LogCategory, inSender)
    XFG:Error(LogCategory, arg8)
    if(string.sub(inMessage, 1, strlen(XFG.Settings.Frames.Chat.Prepend)) == XFG.Settings.Frames.Chat.Prepend) then
        inMessage = string.gsub(inMessage, XFG.Settings.Frames.Chat.Prepend, '')
    else

    end
    return false, inMessage, inSender, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, ...
end