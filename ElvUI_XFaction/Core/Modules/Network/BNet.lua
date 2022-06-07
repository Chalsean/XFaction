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
    self._Packets = {}
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
        XFG:RegisterEvent('BN_CHAT_MSG_ADDON', self.Receive)
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
    for _, _Packet in self:Iterator() do
        _Packet:Print()
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
    return next, self._Packets, nil
end

function BNet:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(self:CanBNet() == false) then return end
    -- Before we do work, lets make sure there are targets and we can message those targets
    local _Bridges = {}
    for _, _Target in inMessage:TargetIterator() do
        local _Friends = {}
        for _, _Friend in XFG.Network.BNet.Friends:Iterator() do
            if(_Friend:IsRunningAddon() and _Target:Equals(_Friend:GetTarget())) then
                table.insert(_Friends, _Friend)
            end
        end
        
        if(table.getn(_Friends) > 0) then
            local _Random = math.random(1, table.getn(_Friends))
            local _Bridge = _Friends[_Random]
            table.insert(_Bridges, _Bridge)
        end
    end

    if(table.getn(_Bridges) > 0) then
        local _Packets = {}
        local _PacketCount = 0            

        -- Now that we know we need to send a BNet whisper, time to split the message into packets
        -- Split once and then message all the targets
        local _SerializedData
        if(inMessage:HasUnitData()) then
            _SerializedData = XFG:SerializeUnitData(inMessage:GetData())
        else
            _SerializedData = inMessage:GetData()
        end
        local _MessageSize = strlen(_SerializedData)
        if(_MessageSize <= MaxPacketSize) then
            table.insert(_Packets, inMessage)
            _PacketCount = 1
        else                
            local _SegmentStart = 1
            local _SegmentEnd = MaxPacketSize

            while(_SegmentStart <= _MessageSize) do

                _PacketCount = _PacketCount + 1

                local _NewMessage = Message:new()
                if(inMessage.__name == 'GuildMessage') then
                    _NewMessage = GuildMessage:new()
                elseif(inMessage.__name == 'LogoutMessage') then
                    _NewMessage = LogoutMessage:new()
                elseif(inMessage.__name == 'AchievementMessage') then
                    _NewMessage = AchievementMessage:new()
                else
                    _NewMessage = Message:new()
                end	
                _NewMessage:Copy(inMessage)
                _NewMessage:SetPacketNumber(_PacketCount)

                local _DataSegment = strsub(_SerializedData, _SegmentStart, _SegmentEnd)
                _NewMessage:SetData(_DataSegment)
                table.insert(_Packets, _NewMessage)
                
                _SegmentStart = _SegmentEnd + 1
                _SegmentEnd = _SegmentStart + MaxPacketSize
            end
        end

        -- Make sure all packets go to each target
        for _, _Friend in pairs (_Bridges) do
            for _, _Packet in pairs (_Packets) do
                _Packet:SetTotalPackets(_PacketCount)
                local _EncodedPacket = XFG:EncodeMessage(_Packet)
                XFG:Debug(LogCategory, "Whispering BNet bridge [%s:%d] packet [%d:%d] with tag [%s] of length [%d]", _Friend:GetUnitName(), _Friend:GetGameID(), _Packet:GetPacketNumber(), _Packet:GetTotalPackets(), XFG.Network.Message.Tag.BNET, strlen(tostring(_EncodedPacket)))
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                BNSendGameData(_Friend:GetGameID(), XFG.Network.Message.Tag.BNET, _EncodedPacket)
            end
            inMessage:RemoveTarget(_Friend:GetTarget())
        end
    end
end

function BNet:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

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

    -- If you get it from BNet, they should be in your friend list
    if(XFG.Network.BNet.Friends:ContainsByGameID(tonumber(inSender))) then
        local _Friend = XFG.Network.BNet.Friends:GetFriendByGameID(tonumber(inSender))
        _Friend:SetDateTime(GetServerTime())
        _Friend:IsRunningAddon(true)
        if(inEncodedMessage == 'RE:PING') then
            XFG:Debug(LogCategory, "Received ping response [%s:%d]", _Friend:GetTag(), _Friend:GetGameID())
        end
    end

    if(inEncodedMessage == 'PING') then
        XFG:Debug(LogCategory, "Responding to ping from %s", inSender)
        BNSendGameData(tonumber(inSender), XFG.Network.Message.Tag.BNET, 'RE:PING')
        return
    end

    if(inEncodedMessage == 'RE:PING') then
        return
    end

    XFG:Debug(LogCategory, "Received message [%s] from [%s] on [%s]", inMessageTag, inSender, inDistribution)
    local _Message = XFG:DecodeMessage(inEncodedMessage)

    -- Have you seen this message before?
    if(XFG.Network.Mailbox:Contains(_Message:GetKey())) then
        return
    end

    -- Data was sent in one packet, okay to process
    if(_Message:GetTotalPackets() == 1) then
        XFG.Network.Inbox:Process(_Message)
    else
        -- Going to have to stitch the data back together again
        XFG.Network.BNet.Comm:AddPacket(_Message)
        if(XFG.Network.BNet.Comm:HasAllPackets(_Message:GetKey())) then
            XFG:Debug(LogCategory, "Received all packets for message [%s]", _Message:GetKey())
            local _FullMessage = XFG.Network.BNet.Comm:RebuildMessage(_Message:GetKey())
            XFG.Network.Inbox:Process(_FullMessage)
        end
    end    
end

function BNet:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Packets[inKey] ~= nil
end

function BNet:AddPacket(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be a Message type object")
    if(self:Contains(inMessage:GetKey()) == false) then
        self._Packets[inMessage:GetKey()] = {}
    end
    self._Packets[inMessage:GetKey()][inMessage:GetPacketNumber()] = inMessage
end

function BNet:HasAllPackets(inMessageKey)
    assert(type(inMessageKey) == 'string')
    if(self._Packets[inMessageKey] == nil) then return false end
    for _, _Packet in pairs (self._Packets[inMessageKey]) do
        return table.getn(self._Packets[inMessageKey]) == _Packet:GetTotalPackets()
    end
end

function BNet:RebuildMessage(inMessageKey)
    assert(type(inMessageKey) == 'string')
    local _Message
    -- Stitch the data back together again
    for _, _Packet in ipairs (self._Packets[inMessageKey]) do
        if(_Message == nil) then
            _Message = _Packet
        else
            local _Data = _Message:GetData() .. _Packet:GetData()
            _Message:SetData(_Data)
        end
    end
    self._Packets[inMessageKey] = nil
    return _Message
end

-- Designed to identify who is running addon
function BNet:PingFriends()
    for _, _Friend in XFG.Network.BNet.Friends:Iterator() do
        -- If we haven't heard from friend in so long, ping them
        if(_Friend:GetDateTime() + XFG.Network.BNet.PingTimer < GetServerTime()) then
            _Friend:IsRunningAddon(false)
            self:PingFriend(_Friend)
        end
    end
end

-- Designed to identify who is running addon
function BNet:PingFriend(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name ~= nil and inFriend.__name == 'Friend', "argument must be a Friend object")
    XFG:Debug(LogCategory, "Sending ping [%s:%d]", inFriend:GetTag(), inFriend:GetGameID())
    BNSendGameData(inFriend:GetGameID(), XFG.Network.Message.Tag.BNET, 'PING')
end

-- Review: Should back the epoch time an argument
function BNet:Purge()
	local _ServerEpochTime = GetServerTime()
	for _, _Packet in self:Iterator() do
		if(_Packet:GetTimeStamp() + 60 * 6 < _ServerEpochTime) then -- config
			self:RemoveMessage(_Packet:GetKey())
		end
	end
end