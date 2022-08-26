local XFG, G = unpack(select(2, ...))
local ObjectName = 'Mailbox'

local ServerTime = GetServerTime

Mailbox = Factory:newChildConstructor()

function Mailbox:new()
    local _Object = Mailbox.parent.new(self)
	_Object.__name = ObjectName
	_Object._Objects = nil
    _Object._ObjectCount = 0   
    _Object._Packets = nil
	return _Object
end

function Mailbox:newChildConstructor()
    local _Object = Mailbox.parent.new(self)
    _Object.__name = ObjectName
    _Object.parent = self 
	_Object._Objects = nil
    _Object._ObjectCount = 0   
    _Object._Packets = nil
    return _Object
end

function Mailbox:NewObject()
	return Message:new()
end

function Mailbox:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end

function Mailbox:ParentInitialize()
    self._Packets = {}
    self._Objects = {}
    self._CheckedIn = {}
    self._CheckedOut = {}
    self._Key = math.GenerateUID()
end

function Mailbox:ContainsPacket(inKey)
	assert(type(inKey) == 'string')
	return self._Packets[inKey] ~= nil
end

function Mailbox:Add(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
	if(not self:Contains(inMessage:GetKey())) then
		self._Objects[inMessage:GetKey()] = ServerTime()
	end
end

function Mailbox:AddPacket(inMessageKey, inPacketNumber, inData)
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketNumber) == 'number')
    assert(type(inData) == 'string')
    if(not self:ContainsPacket(inMessageKey)) then
        self._Packets[inMessageKey] = {}
        self._Packets[inMessageKey].Count = 0
    end
    self._Packets[inMessageKey][inPacketNumber] = inData
    self._Packets[inMessageKey].Count = self._Packets[inMessageKey].Count + 1
end

function Mailbox:RemovePacket(inKey)
	assert(type(inKey) == 'string')
	if(self:ContainsPacket(inKey)) then
		self._Packets[inKey] = nil
	end
end

function Mailbox:SegmentMessage(inEncodedData, inMessageKey, inPacketSize)
	assert(type(inEncodedData) == 'string')
	local _Packets = {}
    local _TotalPackets = ceil(strlen(inEncodedData) / inPacketSize)
    for i = 1, _TotalPackets do
        local _Segment = string.sub(inEncodedData, inPacketSize * (i - 1) + 1, inPacketSize * i)
        _Segment = tostring(i) .. tostring(_TotalPackets) .. inMessageKey .. _Segment
        _Packets[#_Packets + 1] = _Segment
    end
	return _Packets
end

function Mailbox:HasAllPackets(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(self._Packets[inKey] == nil) then return false end
    return self._Packets[inKey].Count == inTotalPackets
end

function Mailbox:RebuildMessage(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    local _Message = ''
    -- Stitch the data back together again
    for i = 1, inTotalPackets do
        _Message = _Message .. self._Packets[inKey][i]
    end
    self:RemovePacket(inKey)
	return _Message
end

function Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _Key, _ReceivedTime in self:Iterator() do
		if(_ReceivedTime < inEpochTime) then
			self:Remove(_Key)
		end
	end
end

function Mailbox:IsAddonTag(inTag)
	local _AddonTag = false
    for _, _Tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inTag == _Tag) then
            _AddonTag = true
            break
        end
    end
	return _AddonTag
end

function Mailbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    -- Ignore if it's your own message
	if(inSender == XFG.Player.Unit:GetUnitName()) then
        return
	end

    -- If not a message from this addon, ignore
    if(not self:IsAddonTag(inMessageTag)) then
        return
    end

    XFG:Debug(ObjectName, 'Received %s packet from %s', inDistribution, inSender)

    -- Ensure this message has not already been processed
    local _PacketNumber = tonumber(string.sub(inEncodedMessage, 1, 1))
    local _TotalPackets = tonumber(string.sub(inEncodedMessage, 2, 2))
    local _MessageKey = string.sub(inEncodedMessage, 3, 38)
    local _MessageData = string.sub(inEncodedMessage, 39, -1)

    -- Temporary, remove after all upgraded to 3.10
    if(not _PacketNumber or _PacketNumber == 0 or not _TotalPackets or _TotalPackets == 0) then
        XFG:Debug(ObjectName, 'Message is in pre-3.10 format')
        -- local _FullMessage = self:DecodeMessage(inEncodedMessage)
        -- try(function ()
        --     self:Process(_FullMessage, inMessageTag)
        -- end).
        -- finally(function ()
        --     self:Push(_FullMessage)
        -- end)
        return
    end

    -- Ensure we have not already processed the overall message
    if(XFG.Mailbox.BNet:Contains(_MessageKey) or XFG.Mailbox.Chat:Contains(_MessageKey)) then
        return
    end

    self:AddPacket(_MessageKey, _PacketNumber, _MessageData)
    if(self:HasAllPackets(_MessageKey, _TotalPackets)) then
        if(XFG.DebugFlag) then
            XFG:Debug(ObjectName, "Received all packets for message [%s]", _MessageKey)
        end
        local _EncodedMessage = self:RebuildMessage(_MessageKey, _TotalPackets)
        local _FullMessage = self:DecodeMessage(_EncodedMessage)
        try(function ()
            self:Process(_FullMessage, inMessageTag)
        end).
        finally(function ()
            self:Push(_FullMessage)
        end)
    end
end

function Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")

    -- Ignore own messages
    if(inMessage:GetFrom() == XFG.Player.GUID) then
        XFG:Debug(ObjectName, 'Ignoring own message')
        return
    end

    -- Is a newer version available?
    if(not XFG.Cache.NewVersionNotify and XFG.Version:IsNewer(inMessage:GetVersion())) then
        print(format(XFG.Lib.Locale['NEW_VERSION'], XFG.Title))
        XFG.Cache.NewVersionNotify = true
    end

    -- Deserialize unit data
    if(inMessage:HasUnitData()) then
        local _UnitData = XFG:DeserializeUnitData(inMessage:GetData())
        inMessage:SetData(_UnitData)
        if(not _UnitData:HasVersion()) then
            _UnitData:SetVersion(inMessage:GetVersion())
        end
    end

    inMessage:ShallowPrint()

    --========================================
    -- Forward message
    --========================================

    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XFG.Settings.Network.Message.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        local _NodeCount = XFG.Nodes:GetTargetCount(XFG.Player.Target)
        if(_NodeCount > XFG.Settings.Network.BNet.Link.PercentStart) then
            local _Percentage = (XFG.Settings.Network.BNet.Link.PercentStart / _NodeCount) * 100
            if(math.random(1, 100) <= _Percentage) then
                XFG:Debug(ObjectName, 'Randomly selected, forwarding message')
                inMessage:SetType(XFG.Settings.Network.Type.BNET)
                XFG.Mailbox.BNet:Send(inMessage)
            else
                XFG:Debug(ObjectName, 'Not randomly selected, will not forward mesesage')
            end
        else
            XFG:Debug(ObjectName, 'Node count under threshold, forwarding message')
            inMessage:SetType(XFG.Settings.Network.Type.BNET)
            XFG.Mailbox.BNet:Send(inMessage)
        end

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XFG.Settings.Network.Message.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
        else
            inMessage:SetType(XFG.Settings.Network.Type.LOCAL)
        end
        XFG.Mailbox.Chat:Send(inMessage)
    end

    --========================================
    -- Process message
    --========================================

    -- Process GCHAT message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.GCHAT) then
        if(XFG.Player.Unit:CanGuildListen() and not XFG.Player.Guild:Equals(inMessage:GetGuild())) then
            XFG.Frames.Chat:DisplayGuildChat(inMessage)
        end
        return
    end

    -- Process ACHIEVEMENT message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then
        XFG.Frames.Chat:DisplayAchievement(inMessage)
        return
    end

    -- Process LINK message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LINK) then
        XFG.Links:ProcessMessage(inMessage)
        return
    end

    -- Process LOGOUT message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGOUT) then
        -- If own guild, GuildEvent will take care of logout
        if(not XFG.Player.Guild:Equals(inMessage:GetGuild())) then
            XFG.Confederate:Remove(inMessage:GetFrom())
            XFG.Frames.System:DisplayLogoutMessage(inMessage)
        end
        return
    end

    -- Process JOIN message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.JOIN) then
        --XFG.Frames.System:DisplayJoinMessage(inMessage)
        return
    end

    -- Process DATA/LOGIN message
    if(inMessage:HasUnitData()) then
        local _UnitData = inMessage:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Confederate:Add(_UnitData) and XFG.DebugFlag) then
            XFG:Info(ObjectName, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
        end

        -- If unit has just logged in, reply with latest information
        if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN) then
            -- Display system message that unit has logged on
            if(not XFG.Player.Guild:Equals(_UnitData:GetGuild())) then
                XFG.Frames.System:DisplayLoginMessage(inMessage)
            end
        end
    end
end