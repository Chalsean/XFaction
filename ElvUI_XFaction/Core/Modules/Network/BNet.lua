local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'BNet'
local LogCategory = 'NBNet'
local MaxPacketSize = 100

BNet = {}

function BNet:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
    self._Queue = {}
    self._QueueCount = 0
    self._CanBNet = true   

    return _Object
end

function BNet:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function BNet:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        -- Technically this should be with the other handlers but wanted to keep the BNet logic together
        XFG:RegisterEvent('BN_CHAT_MSG_ADDON', self.ReceivePacket)
        XFG:Info(LogCategory, "Registered for BN_CHAT_MSG_ADDON events")
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function BNet:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _CanBNet (" .. type(self._CanBNet) .. "): ".. tostring(self._CanBNet))
    XFG:Debug(LogCategory, "  _QueueCount (" .. type(self._QueueCount) .. "): ".. tostring(self._QueueCount))
    if(self._LocalChannel ~= nil) then
        self._LocalChannel:Print()
    end
end

function BNet:GetKey()
    return self._Key
end

function BNet:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function BNet:CanBNet(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._CanBNet = inBoolean
    end
    return self._CanBNet
end

function BNet:Iterator()
    return next, self._Queue, nil
end

function BNet:SendMessage(inMessage)
    if(self:CanBNet() == false) then return end
    -- Before we do work, lets make sure there are targets and we can message those targets
    for _, _Target in inMessage:TargetIterator() do
        local _Bridges = {}
        for _, _Friend in XFG.Network.BNet.Friends:Iterator() do
            if(_Target:Equals(_Friend:GetTarget())) then
                table.insert(_Bridges, _Friend)
            end
        end
        
        if(table.getn(_Bridges) > 0) then
            local _Random = math.random(1, table.getn(_Bridges))
            local _Bridger = _Bridges[_Random]
            local _Packets = {}
            local _PacketCount = 0            

            -- Now that we know we can send a BNet, time to split the message into packets
            local _SerializedData = XFG:SerializeUnitData(inMessage:GetData())
            local _MessageSize = strlen(_SerializedData)
            if(_MessageSize <= MaxPacketSize) then
                table.insert(_Packets, inMessage)
                _PacketCount = 0
            else                
                local _SegmentStart = 1
                local _SegmentEnd = MaxPacketSize

                while(_SegmentStart <= _MessageSize) do

                    _PacketCount = _PacketCount + 1

                    local _NewMessage = Message:new()
                    _NewMessage:Copy(inMessage)
                    _NewMessage:SetPacketNumber(_PacketCount)

                    local _DataSegment = strsub(_SerializedData, _SegmentStart, _SegmentEnd)
                    _NewMessage:SetData(_DataSegment)
                    table.insert(_Packets, _NewMessage)
                    
                    _SegmentStart = _SegmentEnd + 1
                    _SegmentEnd = _SegmentStart + MaxPacketSize
                end
            end

            for _, _Packet in pairs (_Packets) do
                _Packet:SetTotalPackets(_PacketCount)
                local _EncodedPacket = XFG:EncodePacket(_Packet)
                XFG:Debug(LogCategory, "Whispering BNet bridge [%s:%d] package [%d:%d] with tag [%s] of length [%d]", _Bridger:GetUnitName(), _Bridger:GetID(), _Packet:GetPacketNumber(), _Packet:GetTotalPackets(), XFG.Network.Message.Tag.BNET, strlen(tostring(_EncodedPacket)))
                -- The whole point of packets is that this call will only let so many characters get sent
                -- It won't fail or throw an exception, it just silently does nothing
                BNSendGameData(_Bridger:GetID(), XFG.Network.Message.Tag.BNET, _EncodedPacket)
            end
            inMessage:RemoveTarget(_Target)
        end
    end
end

function BNet:ReceivePacket(inMessageTag, inEncodedMessage, inDistribution, inSender)

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

    XFG:Debug(LogCategory, "Received message [%s] from [%s] on [%s]", inMessageTag, inSender, inDistribution)
    local _Message = XFG:DecodePacket(inEncodedMessage)

    -- Have you seen this message before?
    if(XFG.Network.Mailbox:Contains(_Message:GetKey())) then
        return
    end

    _Message:ShallowPrint()

    -- Data was sent in one packet, okay to process
    if(_Message:GetTotalPackets() == 1) then
        local _, _MessageData = XFG:Deserialize(_Message:GetData())
        local _UnitData = XFG:ExtractTarball(_MessageData)
        _Message:SetData(XFG:ExtractTarball(_UnitData))
        XFG.Network.Receiver:ProcessMessage(_Message)
    else
        XFG.Network.BNet.Comm:Enqueue(_Message)
        if(XFG.Network.BNet.Comm:HasAllPackets(_Message:GetKey())) then
            XFG:Debug(LogCategory, "Received all packets for message [%s]", _Message:GetKey())
            local _FullMessage = XFG.Network.BNet.Comm:Dequeue(_Message:GetKey())
            XFG.Network.Receiver:ProcessMessage(_FullMessage)
        end
    end    
end

function BNet:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Queue[inKey] ~= nil
end

function BNet:Enqueue(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be a Message object")
    if(self:Contains(inMessage:GetKey()) == false) then
        self._Queue[inMessage:GetKey()] = {}
        self._QueueCount = self._QueueCount + 1
    end
    self._Queue[inMessage:GetKey()][inMessage:GetPacketNumber()] = inMessage
end

function BNet:HasAllPackets(inMessageKey)
    assert(type(inMessageKey) == 'string')
    if(self._Queue[inMessageKey] == nil) then return false end
    for _, _Packet in pairs (self._Queue[inMessageKey]) do
        return table.getn(self._Queue[inMessageKey]) == _Packet:GetTotalPackets()
    end
end

function BNet:Dequeue(inMessageKey)
    assert(type(inMessageKey) == 'string')
    local _Message = Message:new()
    -- Stitch the data back together again
    for _, _Packet in ipairs (self._Queue[inMessageKey]) do
        if(_Message:IsInitialized() == false) then
            _Message:Copy(_Packet)
        else
            local _Data = _Message:GetData() .. _Packet:GetData()
            _Message:SetData(_Data)
        end
    end
    local _, _MessageData = XFG:Deserialize(_Message:GetData())
    local _UnitData = XFG:ExtractTarball(_MessageData)
    _Message:SetData(_UnitData)
    return _Message
end 