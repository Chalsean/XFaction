local XFG, G = unpack(select(2, ...))
local ObjectName = 'BNet'
local LogCategory = 'NBNet'
local MaxPacketSize = 150
local BCTL = assert(BNetChatThrottleLib, "XFaction requires BNetChatThrottleLib")

BNet = {}

function BNet:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
    self._Packets = {}

    return _Object
end

function BNet:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
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
        XFG:Info(LogCategory, 'Registered for BN_CHAT_MSG_ADDON events')
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function BNet:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
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

function BNet:Iterator()
    return next, self._Packets, nil
end

function BNet:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    -- Before we do work, lets make sure there are targets and we can message those targets
    local _Links = {}
    for _, _Target in pairs(inMessage:GetTargets()) do
        local _Friends = {}
        for _, _Friend in XFG.Friends:Iterator() do
            if(_Target:Equals(_Friend:GetTarget()) and
              -- At the time of login you may not have heard back on pings yet, so just broadcast
              (_Friend:IsRunningAddon() or inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN)) then
                table.insert(_Friends, _Friend)
            end
        end

        -- You should only ever have to message one addon user per target
        -- Something isnt working here
        local _FriendCount = table.getn(_Friends)
        if(_FriendCount > 0) then
            local _RandomNumber = math.random(1, _FriendCount)
            table.insert(_Links, _Friends[_RandomNumber])
        else
            local _Realm = _Target:GetRealm()
            local _Faction = _Target:GetFaction()
            XFG:Debug(LogCategory, 'Unable to identify friends on target [%s:%s]', _Realm:GetName(), _Faction:GetName())
        end
    end

    if(table.getn(_Links) == 0) then
        return
    end

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

            local _NewMessage = nil
            if(inMessage.__name == 'GuildMessage') then
                _NewMessage = GuildMessage:new()
            elseif(inMessage.__name == 'LogoutMessage') then
                _NewMessage = LogoutMessage:new()
            elseif(inMessage.__name == 'AchievementMessage') then
                _NewMessage = AchievementMessage:new()
            else
                _NewMessage = Message:new()
            end	
            _NewMessage:Initialize()
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
    for _, _Friend in pairs (_Links) do
        for _, _Packet in pairs (_Packets) do
            _Packet:SetTotalPackets(_PacketCount)
            local _EncodedPacket = XFG:EncodeMessage(_Packet)
            XFG:Debug(LogCategory, "Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]", _Friend:GetName(), _Friend:GetGameID(), _Packet:GetPacketNumber(), _Packet:GetTotalPackets(), XFG.Settings.Network.Message.Tag.BNET, strlen(tostring(_EncodedPacket)))
            -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
            BCTL:BNSendGameData('NORMAL', XFG.Settings.Network.Message.Tag.BNET, _EncodedPacket, _, _Friend:GetGameID())
--            BNSendGameData(_Friend:GetGameID(), XFG.Settings.Network.Message.Tag.BNET, _EncodedPacket)
        end
        inMessage:RemoveTarget(_Friend:GetTarget())
    end
end

function BNet:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    -- If not a message from this addon, ignore
    local _AddonTag = false
    for _, _Tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(_AddonTag == false) then
        return
    end

    -- If you get it from BNet, they should be in your friend list and obviously they are running addon
    if(XFG.Friends:ContainsByGameID(tonumber(inSender))) then
        local _Friend = XFG.Friends:GetFriendByGameID(tonumber(inSender))
        if(_Friend ~= nil) then
            local _EpochTime = GetServerTime()
            _Friend:SetDateTime(_EpochTime)
            _Friend:IsRunningAddon(true)
            if(inEncodedMessage == 'PING') then
                XFG:Debug(LogCategory, 'Received ping from [%s]', _Friend:GetTag())
            elseif(inEncodedMessage == 'RE:PING') then
                XFG:Debug(LogCategory, '[%s] Responded to ping', _Friend:GetTag())
            end
        end
    end

    if(inEncodedMessage == 'PING') then
        BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'RE:PING', _, inSender)
        --BNSendGameData(inSender, XFG.Settings.Network.Message.Tag.BNET, 'RE:PING')
        return
    elseif(inEncodedMessage == 'RE:PING') then
        return
    end

    XFG:Debug(LogCategory, "Received message [%s] from [%s] on [%s]", inMessageTag, inSender, inDistribution)
    local _Message = nil
    if(pcall(function () _Message = XFG:DecodeMessage(inEncodedMessage) end)) then
        -- Have you seen this message before?
        if(XFG.Mailbox:Contains(_Message:GetKey())) then
            return
        end

        -- Data was sent in one packet, okay to process
        if(_Message:GetTotalPackets() == 1) then
            XFG.Inbox:Process(_Message, inMessageTag)
        else
            -- Going to have to stitch the data back together again
            XFG.BNet:AddPacket(_Message)
            if(XFG.BNet:HasAllPackets(_Message:GetKey())) then
                XFG:Debug(LogCategory, "Received all packets for message [%s]", _Message:GetKey())
                local _FullMessage = XFG.BNet:RebuildMessage(_Message:GetKey())
                XFG.Inbox:Process(_FullMessage, inMessageTag)
            end
        end  
    else
        XFG:Warn(LogCategory, 'Failed to decode received message [%d:%s:%s]', inSender, inMessageTag, inDistribution)
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

function BNet:Purge(inEpochTime)
    assert(type(inEpochTime) == 'number')
	for _, _Packet in self:Iterator() do
        XFG:DataDumper(LogCategory, _Packet)
		if(_Packet ~= nil and _Packet:GetTimeStamp() < inEpochTime) then
			self:RemoveMessage(_Packet:GetKey())
		end
	end
end

function BNet:PingFriends()
    for _, _Friend in XFG.Friends:Iterator() do
        self:PingFriend(_Friend)
    end
end

function BNet:PingFriend(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name ~= nil and inFriend.__name == 'Friend', 'argument must be a Friend object')
    if(inFriend:IsRunningAddon() == false) then
        XFG:Debug(LogCategory, 'Sending ping to [%s]', inFriend:GetTag())
        BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'PING', _, inFriend:GetGameID())
        --BNSendGameData(inFriend:GetGameID(), XFG.Settings.Network.Message.Tag.BNET, 'PING')
    end
end