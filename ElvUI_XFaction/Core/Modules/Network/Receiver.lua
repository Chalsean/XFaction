local EKX, E, L, V, P, G = unpack(select(2, ...))
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
        EKX:Info(LogCategory, "Registering to receive [%s] messages", EKX.Network.Message.Tag)
        EKX:RegisterComm(EKX.Network.Message.Tag.LOCAL, function(inMessageType, inMessage, inDistribution, inSender) 
                                                           EKX.Network.Receiver:ReceiveMessage(inMessageType, inMessage, inDistribution, inSender)
                                                        end)

        -- Technically this should be with the other handlers but wanted to keep the BNet logic together
        EKX:RegisterEvent('BN_CHAT_MSG_ADDON', self.ReceiveMessage)
        EKX:Info(LogCategory, "Registered for BN_CHAT_MSG_ADDON events")
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Receiver:Print()
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
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
    for _, _Tag in pairs (EKX.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(_AddonTag == false) then
        return
    end
	
    local _Message = EKX:DecodeMessage(inEncodedMessage)  
    _Message:Print()  

    -- Have you seen this message before?
    if(EKX.Network.Mailbox:Contains(_Message:GetKey())) then
        EKX:Debug(LogCategory, "This message has already been processed %s", _Message:GetKey())
        return
    else
        EKX.Network.Mailbox:AddMessage(_Message)
    end

    if(_Message:GetSubject() == EKX.Network.Message.Subject.EVENT) then
        EKX:Debug(LogCategory, "got event message")
        return
    end

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than Unit object
	if(_Message:GetFrom() == EKX.Player.GUID) then
        return
	end    

    -- If BNet comm bridge for a whisper, simply forward
    if(inMessageTag == EKX.Network.Message.Tag.BNET and 
       _Message:GetType() == EKX.Network.Type.WHISPER and 
       _Message:GetTo() ~= EKX.Player.Unit:GetKey()) then

        EKX.Network.Sender:Whisper(_Message:GetTo(), inEncodedMessage)
        return
    end

    -- If sent via BNet, broadcast to your local realm
    if(inMessageTag == EKX.Network.Message.Tag.BNET and _Message:GetType() == EKX.Network.Type.BROADCAST) then
        EKX.Network.Sender:SendMessage(_Message)
    end

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than Unit object
	-- if(_Message:GetFrom() == EKX.Player.GUID) then
	-- 	return
	-- end

    -- Process GUILD_CHAT message
    if(_Message:GetSubject() == EKX.Network.Message.Subject.GUILD_CHAT) then
        EKX.Frames.Chat:DisplayChat(EKX.Frames.ChatType.GUILD,
                                    _Message:GetData(),
                                    _Message:GetFrom(), 
                                    _Message:GetFaction(), 
                                    _Message:GetFlags(), 
                                    _Message:GetLineID(),
                                    _Message:GetFromGUID())
        return
    end

    -- Process DATA message
    if(_Message:GetSubject() == EKX.Network.Message.Subject.DATA) then
        local _UnitData = _Message:GetData()
        _UnitData:IsPlayer(false)
        if(EKX.Guild:AddUnit(_UnitData)) then
            EKX:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
            --EKX.DataText.Guild:OnEnable()
        end
    end
end