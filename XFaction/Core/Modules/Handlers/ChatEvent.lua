local XFG, G = unpack(select(2, ...))
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
		--XFG:RegisterEvent('CHAT_MSG_GUILD', self.CallbackGuildMessage)
        --XFG:Info(LogCategory, "Registered for CHAT_MSG_GUILD events")
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
        _NewMessage:SetFrom(XFG.Player.Unit:GetKey())
        _NewMessage:SetType(XFG.Network.Type.BROADCAST)
        _NewMessage:SetSubject(XFG.Network.Message.Subject.GCHAT)
        _NewMessage:SetFlags(inFlags)
        _NewMessage:SetLineID(inLineID)
        _NewMessage:SetData(inText)
        XFG.Network.Outbox:Send(_NewMessage, true)
    end
end

function ChatEvent:CallbackChannelMessage(inText, inSenderName, inLanguageName, _, inTargetName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    if(XFG.Network.Outbox:HasLocalChannel()) then
        local _Channel = XFG.Network.Outbox:GetLocalChannel()
        if(_Channel:GetID() == inChannelID and XFG.Player.Unit:GetGUID() == inSenderGUID) then
            local _NewMessage = GuildMessage:new()
            _NewMessage:Initialize()
            _NewMessage:SetFrom(XFG.Player.Unit:GetKey())
            _NewMessage:SetType(XFG.Network.Type.BROADCAST)
            _NewMessage:SetSubject(XFG.Network.Message.Subject.GCHAT)
            _NewMessage:SetFlags(inFlags)
            _NewMessage:SetLineID(inLineID)
            _NewMessage:SetUnitName(XFG.Player.Unit:GetUnitName())
            if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
                _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
            end
            _NewMessage:SetData(inText)
            XFG.Network.Outbox:Send(_NewMessage, true)
        end
    end
end