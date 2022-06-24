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