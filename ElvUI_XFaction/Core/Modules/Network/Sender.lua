local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Sender'
local LogCategory = 'NSender'

Sender = {}

function Sender:new(inObject)
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
        self._LocalChannel = nil
        self._CanBroadcast = false
        self._CanWhisper = true
        self._CanBNet = false
        self._BroadcastQueue = {}
    end

    return Object
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
    XFG:Debug(LogCategory, "  _CanBNet (" .. type(self._CanBNet) .. "): ".. tostring(self._CanBNet))
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

function Sender:CanBNet(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._CanBNet = inBoolean
    end
    return self._CanBNet
end

function Sender:HasLocalChannel(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean')
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

function Sender:SendMessage(inMessage, inSendBNet)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(inMessage:IsInitialized() == false) then
        inMessage:Initialize()
    end

    local _OutgoingData = XFG:EncodeMessage(inMessage)    

    -- If you messaged all possible realm/faction combinations, can switch to local broadcast
    if(inSendBNet == true and self:BNet(_OutgoingData)) then
        inMessage:SetType(XFG.Network.Type.LOCAL)
    end

    if(inMessage:GetType() == XFG.Network.Type.BROADCAST or inMessage:GetType() == XFG.Network.Type.LOCAL) then
        -- Anyone listening locally?
        local _Realm = XFG.Realms:GetCurrentRealm()
        if(_Realm:GetNumberRunningAddon() > 1) then
           self:BroadcastLocally(_OutgoingData)            

        -- If only 1 player, switch to whisper
        elseif(_Realm:GetNumberRunningAddon() == 1) then
           local _Unit = _Realm:GetUnitRunningAddon()
           inMessage:SetTo(_Unit:GetKey())
           inMessage:SetType(XFG.Network.Type.WHISPER)
           self:Whisper(inMessage:GetTo(), _OutgoingData)  

        else
            -- Nobody listening, so sad
        end
    elseif(inMessage:GetType() == XFG.Network.Type.WHISPER) then
        self:Whisper(inMessage:GetTo(), _OutgoingData)
    end
end

function Sender:BroadcastLocally(inData)
    if(self:CanBroadcast()) then
        local _Channel = self:GetLocalChannel()
        XFG:Debug(LogCategory, "Broadcasting on channel [%d] with tag [%s]", _Channel:GetID(), XFG.Network.Message.Tag)
        XFG:SendCommMessage(XFG.Network.Message.Tag.LOCAL, inData, "CHANNEL", _Channel:GetID())
    end
end

function Sender:BroadcastUnitData(inUnitData, inSubject)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
    if(inUnitData:IsPlayer()) then
        inUnitData:SetTimeStamp(GetServerTime())
        XFG.Player.LastBroadcast = inUnitData:GetTimeStamp()
    end
    local _Message = Message:new()
    _Message:Initialize()
    _Message:SetType(XFG.Network.Type.BROADCAST)
    _Message:SetSubject(inSubject)
    _Message:SetData(inUnitData)
    _Message:Print()
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
    if(inUnitData:IsPlayer()) then
        inUnitData:SetTimeStamp(GetServerTime())
        XFG.Player.LastBroadcast = inUnitData:GetTimeStamp()
    end
    local _Message = Message:new()
    _Message:Initialize()
    _Message:SetType(XFG.Network.Type.WHISPER)
    _Message:SetTo(inTo)
    _Message:SetSubject(XFG.Network.Message.Subject.DATA)
    _Message:SetData(inUnitData)
    _Message:Print()
    self:SendMessage(_Message, true)
end

function Sender:BNet(inEncodedMessage)
    if(self:CanBNet()) then
        local _BNetCount = 0
        -- For all the realms/guilds associated with the confederate
        for _, _Guild in XFG.Guilds:Iterator() do

            local _Realm = _Guild:GetRealm()
            local _Faction = _Guild:GetFaction()

            -- If the guild is on your realm and same faction, no need to use BNet
            if(XFG.Player.Realm:Equals(_Guild:GetRealm()) == false or XFG.Player.Faction:Equals(_Guild:GetFaction()) == false) then
                XFG:Debug(LogCategory, "Should BNet to [%s][%s]", _Realm:GetName(), _Faction:GetName())
                _BNetCount = _BNetCount + 1
                -- Identify a passthru BNet friend to whisper
                local _Bridger = XFG.Network.BNet.Friends:GetRandomFriend(_Guild:GetRealm(), _Guild:GetFaction())
                if(_Bridger ~= nil) then
                    XFG:Debug(LogCategory, "Whispering BNet bridge [%s] with tag [%s]", _Bridger:GetName(), XFG.Network.Message.Tag.BNET)
                    BNSendGameData(_Bridger:GetID(), XFG.Network.Message.Tag.BNET, inEncodedMessage)
                    _BNetCount = _BNetCount - 1
                    return
                end
            end
        end
        return _BNetCount == 0
    end
    return false
end