local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Sender'
local LogCategory = 'NSender'

Sender = {}

function Sender:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
    self._LocalChannel = nil
    self._CanBroadcast = false
    self._CanWhisper = true

    return _Object
end

function Sender:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Sender:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Sender:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _CanBroadcast (" .. type(self._CanBroadcast) .. "): ".. tostring(self._CanBroadcast))
    XFG:Debug(LogCategory, "  _CanWhisper (" .. type(self._CanWhisper) .. "): ".. tostring(self._CanWhisper))
    XFG:Debug(LogCategory, "  _LocalChannel (" .. type(self._LocalChannel) .. ")")
    if(self._LocalChannel ~= nil) then
        self._LocalChannel:Print()
    end
end

function Sender:GetKey()
    return self._Key
end

function Sender:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Sender:CanBroadcast(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._CanBroadcast = inBoolean
    end
    return self._CanBroadcast
end

function Sender:CanWhisper(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._CanWhisper = inBoolean
    end
    return self._CanWhisper
end

function Sender:HasLocalChannel()
    return self._LocalChannel ~= nil
end

function Sender:GetLocalChannel()
    return self._LocalChannel
end

function Sender:SetLocalChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name ~= nil and inChannel.__name == 'Channel', "argument must be Channel object")
    self._LocalChannel = inChannel
    return self:HasLocalChannel()
end

function Sender:SendMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(inMessage:IsInitialized() == false) then
		-- Review: double check this isn't overriding the timestamp of the message
        inMessage:Initialize()
    end

    XFG:Debug(LogCategory, "Sending message")
    inMessage:ShallowPrint()

    -- If you messaged all possible realm/faction combinations, can switch to local broadcast    
    if(inMessage:GetType() == XFG.Network.Type.BROADCAST or inMessage:GetType() == XFG.Network.Type.BNET) then
        XFG.Network.BNet.Comm:SendMessage(inMessage)
        if(inMessage:HasTargets() == false and inMessage:GetType() == XFG.Network.Type.BROADCAST) then
            XFG:Debug(LogCategory, "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:SetType(XFG.Network.Type.LOCAL)
        end
    end

    -- If we were only supposed to do BNet, we're done
    if(inMessage:GetType() == XFG.Network.Type.BNET) then
        return
    end

    local _OutgoingData = XFG:EncodeMessage(inMessage, true)

    if(inMessage:GetType() == XFG.Network.Type.BROADCAST or inMessage:GetType() == XFG.Network.Type.LOCAL) then
        self:BroadcastLocally(_OutgoingData) 
    elseif(inMessage:GetType() == XFG.Network.Type.WHISPER) then
        self:Whisper(inMessage:GetTo(), _OutgoingData)
    end
end

function Sender:BroadcastLocally(inData)
    if(self:CanBroadcast()) then
        local _Channel = self:GetLocalChannel()
        XFG:Debug(LogCategory, "Broadcasting on channel [%s] with tag [%s]", _Channel:GetShortName(), XFG.Network.Message.Tag.LOCAL)
        XFG:SendCommMessage(XFG.Network.Message.Tag.LOCAL, inData, "CHANNEL", _Channel:GetID())
    end
end

function Sender:BroadcastUnitData(inUnitData, inSubject)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
	if(inSubject == nil) then inSubject = XFG.Network.Message.Subject.DATA end
    if(inUnitData:IsPlayer()) then
        inUnitData:SetTimeStamp(GetServerTime())
        XFG.Player.LastBroadcast = inUnitData:GetTimeStamp()
    end
    local _Message = Message:new()
    _Message:Initialize()
    _Message:SetFrom(XFG.Player.Unit:GetKey())
    _Message:SetType(XFG.Network.Type.BROADCAST)
    _Message:SetSubject(inSubject)
    _Message:SetData(inUnitData)
    self:SendMessage(_Message, true)    
end

function Sender:Whisper(inTo, inData)
    if(self:CanWhisper()) then
        XFG:Debug(LogCategory, "Whispering [%s] with tag [%s]", inTo, XFG.Network.Message.Tag)
        XFG:SendCommMessage(XFG.Network.Message.Tag.LOCAL, inData, "WHISPER", inTo)
    end
end

function Sender:WhisperUnitData(inTo, inUnitData)
    assert(type(inTo) == 'string')
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
    local _Message = Message:new()
    _Message:Initialize()
    _Message:SetType(XFG.Network.Type.WHISPER)
    _Message:SetTo(inTo)
    _Message:SetSubject(XFG.Network.Message.Subject.DATA)
    _Message:SetData(inUnitData)
    self:SendMessage(_Message, true)
end