local XFG, G = unpack(select(2, ...))
local ObjectName = 'BNet'
local LogCategory = 'NBNet'
local BCTL = assert(BNetChatThrottleLib, 'XFaction requires BNetChatThrottleLib')

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
        XFG:RegisterEvent('BN_CHAT_MSG_ADDON', XFG.BNet.Receive)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function BNet:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
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
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

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

    -- Now that we know we need to send a BNet whisper, time to split the message into packets
    -- Split once and then message all the targets
    local _MessageData = XFG:EncodeBNetMessage(inMessage, true)
    local _TotalPackets = ceil(strlen(_MessageData) / XFG.Settings.Network.BNet.PacketSize)
    for i = 1, _TotalPackets do
        local _Segment = string.sub(_MessageData, XFG.Settings.Network.BNet.PacketSize * (i - 1) + 1, XFG.Settings.Network.BNet.PacketSize * i)
        _Segment = tostring(i) .. tostring(_TotalPackets) .. inMessage:GetKey() .. _Segment
        table.insert(_Packets, _Segment)
    end

    -- Make sure all packets go to each target
    for _, _Friend in pairs (_Links) do
        try(function ()
            for _Index, _Packet in ipairs (_Packets) do
                XFG:Debug(LogCategory, 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', _Friend:GetName(), _Friend:GetGameID(), _Index, _TotalPackets, XFG.Settings.Network.Message.Tag.BNET, strlen(_Packet))
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                BCTL:BNSendGameData('NORMAL', XFG.Settings.Network.Message.Tag.BNET, _Packet, _, _Friend:GetGameID())
                XFG.Metrics:GetMetric(XFG.Settings.Metric.BNetSend):Increment()
            end
            inMessage:RemoveTarget(_Friend:GetTarget())
        end).
        catch(function (inErrorMessage)
            XFG:Warn(LogCategory, 'Failed to send packet to [%s]: ' .. inErrorMessage, _Friend:GetName())
        end)
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

    try(function ()
        -- Even though these may be part of a message, it still counts as a network transaction
        XFG.Metrics:GetMetric(XFG.Settings.Metric.BNetReceive):Increment()
        XFG.Metrics:GetMetric(XFG.Settings.Metric.Messages):Increment()
        -- People can only whisper you if friend, so if you got a whisper you need to check friends cache
        if(not XFG.Friends:ContainsByGameID(tonumber(inSender))) then
            XFG.Friends:CheckFriends()
        end

        -- If you get it from BNet, they should be in your friend list and obviously they are running addon
        if(XFG.Friends:ContainsByGameID(tonumber(inSender))) then
            local _Friend = XFG.Friends:GetFriendByGameID(tonumber(inSender))
            if(_Friend ~= nil) then
                local _EpochTime = GetServerTime()
                _Friend:SetDateTime(_EpochTime)
                _Friend:IsRunningAddon(true)
                _Friend:CreateLink()
                if(inEncodedMessage == 'PING') then
                    XFG:Debug(LogCategory, 'Received ping from [%s]', _Friend:GetTag())
                elseif(inEncodedMessage == 'RE:PING') then
                    XFG:Debug(LogCategory, '[%s] Responded to ping', _Friend:GetTag())
                end
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(LogCategory, 'Failed to identify BNet sender: ' .. inErrorMessage)
    end)

    try(function ()
        if(inEncodedMessage == 'PING') then
            BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'RE:PING', _, inSender)
            XFG.Metrics:GetMetric(XFG.Settings.Metric.BNetSend):Increment()
            return
        elseif(inEncodedMessage == 'RE:PING') then
            return
        end

        local _PacketNumber = tonumber(string.sub(inEncodedMessage, 1, 1))
        local _TotalPackets = tonumber(string.sub(inEncodedMessage, 2, 2))
        local _MessageKey = string.sub(inEncodedMessage, 3, 38)
        local _MessageData = string.sub(inEncodedMessage, 39, -1)
        XFG:Debug(LogCategory, 'Received packet [%d:%d] of message [%s] from [%d]', _PacketNumber, _TotalPackets, _MessageKey, inSender)
        -- Temporary, remove after all upgraded to 3.3
        if(not _TotalPackets) then
            error('Message is in pre-3.3 format, ignoring')
        end

        XFG.BNet:AddPacket(_MessageKey, _PacketNumber, _MessageData)
        if(XFG.BNet:HasAllPackets(_MessageKey, _TotalPackets)) then
            XFG:Debug(LogCategory, "Received all packets for message [%s]", _MessageKey)
            local _FullMessage = XFG.BNet:RebuildMessage(_MessageKey, _TotalPackets)
            XFG.Inbox:Process(_FullMessage, inMessageTag)
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(LogCategory, 'Failed to process received packet: ' .. inErrorMessage)
    end)
end

function BNet:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Packets[inKey] ~= nil
end

function BNet:AddPacket(inMessageKey, inPacketNumber, inData)
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketNumber) == 'number')
    assert(type(inData) == 'string')
    if(not self:Contains(inMessageKey)) then
        self._Packets[inMessageKey] = {}
        self._Packets[inMessageKey].Count = 0
    end
    self._Packets[inMessageKey][inPacketNumber] = inData
    self._Packets[inMessageKey].Count = self._Packets[inMessageKey].Count + 1
end

function BNet:HasAllPackets(inMessageKey, inTotalPackets)
    assert(type(inMessageKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(self._Packets[inMessageKey] == nil) then return false end
    return self._Packets[inMessageKey].Count == inTotalPackets
end

function BNet:RebuildMessage(inMessageKey, inTotalPackets)
    assert(type(inMessageKey) == 'string')
    local _Message = ''
    -- Stitch the data back together again
    for i = 1, inTotalPackets do
        _Message = _Message .. self._Packets[inMessageKey][i]
    end
    self:RemovePackets(inMessageKey)
    return XFG:DecodeBNetMessage(_Message)
end

function BNet:RemovePackets(inKey)
    assert(type(inKey) == 'string')
    if(self:Contains(inKey)) then
        self._Packets[inKey] = nil
    end
    return self:Contains(inKey) == false
end

function BNet:Purge(inEpochTime)
    assert(type(inEpochTime) == 'number')
	for _ID, _Packets in self:Iterator() do
        for _, _Packet in ipairs (_Packets) do
		    if(_Packet:GetTimeStamp() < inEpochTime) then
			    self:RemovePackets(_ID)
            end
            break
		end
	end
end

function BNet:PingFriend(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name ~= nil and inFriend.__name == 'Friend', 'argument must be a Friend object')
    XFG:Debug(LogCategory, 'Sending ping to [%s]', inFriend:GetTag())
    BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'PING', _, inFriend:GetGameID())
    XFG.Metrics:GetMetric(XFG.Settings.Metric.BNetSend):Increment() 
end