local XFG, G = unpack(select(2, ...))
local ObjectName = 'Mailbox'
local ServerTime = GetServerTime

Mailbox = Factory:newChildConstructor()

--#region Constructors
function Mailbox:new()
    local object = Mailbox.parent.new(self)
	object.__name = ObjectName
	object.objects = nil
    object.objectCount = 0   
    object.packets = nil
	return object
end

function Mailbox:newChildConstructor()
    local object = Mailbox.parent.new(self)
    object.__name = ObjectName
    object.parent = self 
	object.objects = nil
    object.objectCount = 0   
    object.packets = nil
    return object
end

function Mailbox:NewObject()
	return Message:new()
end
--#endregion

--#region Initializers
function Mailbox:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end

function Mailbox:ParentInitialize()
    self.packets = {}
    self.objects = {}
    self.checkedIn = {}
    self.checkedOut = {}
    self.key = math.GenerateUID()
end
--#endregion

--#region Hash
function Mailbox:ContainsPacket(inKey)
	assert(type(inKey) == 'string')
	return self.packets[inKey] ~= nil
end

function Mailbox:Add(inKey)
	assert(type(inKey) == 'string')
	if(not self:Contains(inKey)) then
		self.objects[inKey] = ServerTime()
	end
end

function Mailbox:AddPacket(inMessageKey, inPacketNumber, inData)
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketNumber) == 'number')
    assert(type(inData) == 'string')
    if(not self:ContainsPacket(inMessageKey)) then
        self.packets[inMessageKey] = {}
        self.packets[inMessageKey].Count = 0
    end
    self.packets[inMessageKey][inPacketNumber] = inData
    self.packets[inMessageKey].Count = self.packets[inMessageKey].Count + 1
end

function Mailbox:RemovePacket(inKey)
	assert(type(inKey) == 'string')
	if(self:ContainsPacket(inKey)) then
		self.packets[inKey] = nil
	end
end
--#endregion

--#region Segmentation
function Mailbox:SegmentMessage(inEncodedData, inMessageKey, inPacketSize)
	assert(type(inEncodedData) == 'string')
	local packets = {}
    local totalPackets = ceil(strlen(inEncodedData) / inPacketSize)
    for i = 1, totalPackets do
        local segment = string.sub(inEncodedData, inPacketSize * (i - 1) + 1, inPacketSize * i)
        segment = tostring(i) .. tostring(totalPackets) .. inMessageKey .. segment
        packets[#packets + 1] = segment
    end
	return packets
end

function Mailbox:HasAllPackets(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(self.packets[inKey] == nil) then return false end
    return self.packets[inKey].Count == inTotalPackets
end

function Mailbox:RebuildMessage(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    local message = ''
    -- Stitch the data back together again
    for i = 1, inTotalPackets do
        message = message .. self.packets[inKey][i]
    end
    self:RemovePacket(inKey)
	return message
end
--#endregion

--#region Receive
function Mailbox:IsAddonTag(inTag)
	local addonTag = false
    for _, tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inTag == tag) then
            addonTag = true
            break
        end
    end
	return addonTag
end

function Mailbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    --#region Ignore message
    -- If not a message from this addon, ignore
    if(not self:IsAddonTag(inMessageTag)) then
        return
    end

    XFG:Debug(ObjectName, 'Received %s packet from %s', inDistribution, inSender)

    -- Ensure this message has not already been processed
    local packetNumber = tonumber(string.sub(inEncodedMessage, 1, 1))
    local totalPackets = tonumber(string.sub(inEncodedMessage, 2, 2))
    local messageKey = string.sub(inEncodedMessage, 3, 3 + XFG.Settings.System.UIDLength - 1)
    local messageData = string.sub(inEncodedMessage, 3 + XFG.Settings.System.UIDLength, -1)

    -- Temporary, remove after all upgraded to 4.0
    if(not packetNumber or packetNumber == 0 or not totalPackets or totalPackets == 0) then
        XFG:Debug(ObjectName, 'Message is in pre-4.0 format')
        return
    end

    -- Ignore if it's your own message or you've seen it before
    if(XFG.Mailbox.BNet:Contains(messageKey) or XFG.Mailbox.Chat:Contains(messageKey)) then
        XFG:Debug(ObjectName, 'Ignoring duplicate message [%s]', messageKey)
        return
    end
    --#endregion

    self:AddPacket(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then
        if(XFG.DebugFlag) then
            XFG:Debug(ObjectName, 'Received all packets for message [%s]', messageKey)
        end
        local encodedMessage = self:RebuildMessage(messageKey, totalPackets)
        local fullMessage = self:DecodeMessage(encodedMessage)
        try(function ()
            self:Process(fullMessage, inMessageTag)
        end).
        finally(function ()
            self:Push(fullMessage)
        end)
    end
end

function Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

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

    self:Add(inMessage:GetKey())
    inMessage:Print()

    --#region Forwarding
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XFG.Settings.Network.Message.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        local nodeCount = XFG.Nodes:GetTargetCount(XFG.Player.Target)
        if(nodeCount > XFG.Settings.Network.BNet.Link.PercentStart) then
            local percentage = (XFG.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
            if(math.random(1, 100) <= percentage) then
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
    --#endregion

    --#region Process message
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
        local unitData = inMessage:GetData()
        unitData:IsPlayer(false)
        if(XFG.Confederate:Add(unitData) and XFG.DebugFlag) then
            XFG:Info(ObjectName, 'Updated unit [%s] information based on message received', unitData:GetUnitName())
        end

        -- If unit has just logged in, reply with latest information
        if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN) then
            -- Display system message that unit has logged on
            if(not XFG.Player.Guild:Equals(unitData:GetGuild())) then
                XFG.Frames.System:DisplayLoginMessage(inMessage)
            end
        end
    end
    --#endregion
end
--#endregion

--#region Janitorial
function Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for key, receivedTime in self:Iterator() do
		if(receivedTime < inEpochTime) then
			self:Remove(key)
		end
	end
end
--#endregion