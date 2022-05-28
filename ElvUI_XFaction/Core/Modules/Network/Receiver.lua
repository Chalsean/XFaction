local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Receiver'
local LogCategory = 'NReceiver'

Receiver = {}

function Receiver:new(inObject)
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
        self._Key = nil
        self._Initialized = false
    end

    return Object
end

function Receiver:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Receiver:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        XFG:Info(LogCategory, "Registering to receive [%s] messages", XFG.Network.Message.Tag.LOCAL)
        XFG:RegisterComm(XFG.Network.Message.Tag.LOCAL, function(inMessageType, inMessage, inDistribution, inSender) 
                                                           XFG.Network.Receiver:ReceiveMessage(inMessageType, inMessage, inDistribution, inSender)
                                                        end)

        -- Technically this should be with the other handlers but wanted to keep the BNet logic together
        XFG:RegisterEvent('BN_CHAT_MSG_ADDON', self.ReceiveMessage)
        XFG:Info(LogCategory, "Registered for BN_CHAT_MSG_ADDON events")
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Receiver:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Receiver:GetKey()
    return self._Key
end

function Receiver:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Receiver:ReceiveMessage(inMessageTag, inEncodedMessage, inDistribution, inSender)

    -- If not a message from this addon, ignore
    local _AddonTag = false
    for _, _Tag in pairs (XFG.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(_AddonTag == false) then
        return
    end

    local _Message = XFG:DecodeMessage(inEncodedMessage)

    -- Have you seen this message before?
    if(XFG.Network.Mailbox:Contains(_Message:GetKey())) then
        XFG:Debug(LogCategory, "This message has already been processed %s", _Message:GetKey())
        return
    else
        XFG.Network.Mailbox:AddMessage(_Message)
    end

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than Unit object
	if(_Message:GetFrom() == XFG.Player.GUID) then
        return
	end   
          
    _Message:Print() 

    -- If BNet comm bridge for a whisper, simply forward
    if(inMessageTag == XFG.Network.Message.Tag.BNET and 
       _Message:GetType() == XFG.Network.Type.WHISPER and 
       _Message:GetTo() ~= XFG.Player.Unit:GetKey()) then

        XFG.Network.Sender:Whisper(_Message:GetTo(), inEncodedMessage)
        return
    end

    -- If sent via BNet, broadcast to your local realm
    if(inMessageTag == XFG.Network.Message.Tag.BNET and _Message:GetType() == XFG.Network.Type.BROADCAST) then
        XFG.Network.Sender:SendMessage(_Message)
    end

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than Unit object
	-- if(_Message:GetFrom() == XFG.Player.GUID) then
	-- 	return
	-- end

    -- Process GUILD_CHAT message
    if(_Message:GetSubject() == XFG.Network.Message.Subject.GUILD_CHAT) then
        XFG.Frames.Chat:DisplayChat(XFG.Frames.ChatType.GUILD,
                                    _Message:GetData(),
                                    _Message:GetFrom(), 
                                    _Message:GetFaction(), 
                                    _Message:GetFlags(), 
                                    _Message:GetLineID(),
                                    _Message:GetFromGUID())
        return
    end

    -- Process LOGOUT message
    if(_Message:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        XFG.Guild:RemoveUnit(_Message:GetFrom())
        return
    end

    -- Process DATA message
    if(_Message:GetSubject() == XFG.Network.Message.Subject.DATA) then
        local _UnitData = _Message:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Guild:AddUnit(_UnitData)) then
            XFG:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
            --XFG.DataText.Guild:OnEnable()
        end
    end
end