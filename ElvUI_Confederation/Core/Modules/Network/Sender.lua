local CON, E, L, V, P, G = unpack(select(2, ...))
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
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    CON:Debug(LogCategory, "  _CanBroadcast (" .. type(self._CanBroadcast) .. "): ".. tostring(self._CanBroadcast))
    CON:Debug(LogCategory, "  _CanWhisper (" .. type(self._CanWhisper) .. "): ".. tostring(self._CanWhisper))
    CON:Debug(LogCategory, "  _CanBNet (" .. type(self._CanBNet) .. "): ".. tostring(self._CanBNet))
    CON:Debug(LogCategory, "  _LocalChannel (" .. type(self._LocalChannel) .. ")")
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

function Sender:SendMessage(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
    if(inMessage:IsInitialized() == false) then
        inMessage:Initialize()
    end

    local _OutgoingData = CON:EncodeMessage(inMessage)

    if(inMessage:GetType() == CON.Network.Type.BROADCAST) then
        -- Anyone listening?
        local _Realm = CON.Realms:GetCurrentRealm()
        if(_Realm:GetNumberRunningAddon() > 1) then
            self:BroadcastLocally(_OutgoingData)

        -- If only 1 player, switch to whisper
        elseif(_Realm:GetNumberRunningAddon() == 1) then
            local _Unit = _Realm:GetUnitRunningAddon()
            inMessage:SetTo(_Unit:GetKey())
            inMessage:SetType(CON.Network.Type.WHISPER)
            self:Whisper(inMessage:GetTo(), _OutgoingData)  

        else
            -- Nobody listening, so sad
        end
    elseif(inMessage:GetType() == CON.Network.Type.WHISPER) then
        self:Whisper(inMessage:GetTo(), _OutgoingData)
    end
end

function Sender:BroadcastLocally(inData)
    if(self:CanBroadcast()) then
        local _Channel = self:GetLocalChannel()
        CON:Debug(LogCategory, "Broadcasting on channel [%d] with tag [%s]", _Channel:GetID(), CON.Network.Message.Tag)
        CON:SendCommMessage(CON.Network.Message.Tag, inData, "CHANNEL", _Channel:GetID())
    end
end

function Sender:Whisper(inTo, inData)
    if(self:CanWhisper()) then
        CON:Debug(LogCategory, "Whispering [%s] with tag [%s]", inTo, CON.Network.Message.Tag)
        CON:SendCommMessage(CON.Network.Message.Tag, inData, "WHISPER", inTo)
    end
end

function Sender:BroadcastUnitData(inUnitData)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
    local _Message = Message:new(); _Message:Initialize()
    _Message:SetType(CON.Network.Type.BROADCAST)
    _Message:SetSubject(CON.Network.Message.Subject.DATA)
    _Message:SetData(inUnitData)
    self:SendMessage(_Message)
end

function Sender:BNet(inData)
    if(self:CanBNet()) then
        for _, _RealmName in pairs (CON.Network.BNet.Realms) do
            -- if(_RealmName ~= CON.Player.RealmName and CON.Realms:) then
            --     local _Bridger = CON.Friends:GetRandomFriend(CON.Realms:GetCurrentRealm())
        end
    end
end