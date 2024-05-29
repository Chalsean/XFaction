local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Mailbox'
local ServerTime = GetServerTime

Mailbox = XFC.Factory:newChildConstructor()

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
    if(self.packets[inMessageKey][inPacketNumber] == nil) then
        self.packets[inMessageKey][inPacketNumber] = inData
        self.packets[inMessageKey].Count = self.packets[inMessageKey].Count + 1
    end
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
    for _, packet in pairs(self.packets[inKey]) do
        message = message .. packet
    end
    self:RemovePacket(inKey)
	return message
end
--#endregion

--#region Receive
function Mailbox:IsAddonTag(inTag)
	local addonTag = false
    for _, tag in pairs (XF.Enum.Tag) do
        if(inTag == tag) then
            addonTag = true
            break
        end
    end
	return addonTag
end

function Mailbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    XF:Trace(ObjectName, 'Received %s packet from %s for tag %s', inDistribution, inSender, inMessageTag)

    --#region Ignore message
    -- If not a message from this addon, ignore
    if(not self:IsAddonTag(inMessageTag)) then
        return
    end

    if(inMessageTag == XF.Enum.Tag.LOCAL) then
        XFO.Metrics:Get(XF.Enum.Metric.ChannelReceive):Increment()
        XFO.Metrics:Get(XF.Enum.Metric.Messages):Increment()
    else
        XFO.Metrics:Get(XF.Enum.Metric.BNetReceive):Increment()
        XFO.Metrics:Get(XF.Enum.Metric.Messages):Increment()
    end

    -- Ensure this message has not already been processed
    local packetNumber = tonumber(string.sub(inEncodedMessage, 1, 1))
    local totalPackets = tonumber(string.sub(inEncodedMessage, 2, 2))
    local messageKey = string.sub(inEncodedMessage, 3, 3 + XF.Settings.System.UIDLength - 1)
    local messageData = string.sub(inEncodedMessage, 3 + XF.Settings.System.UIDLength, -1)

    -- Ignore if it's your own message or you've seen it before
    if(XF.Mailbox.BNet:Contains(messageKey) or XF.Mailbox.Chat:Contains(messageKey)) then
        XF:Trace(ObjectName, 'Ignoring duplicate message [%s]', messageKey)
        return
    end
    --#endregion

    self:AddPacket(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then
        XF:Debug(ObjectName, 'Received all packets for message [%s]', messageKey)
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
    if(not XF.Cache.NewVersionNotify and XF.Version:IsNewer(inMessage:GetVersion())) then
        print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
        XF.Cache.NewVersionNotify = true
    end

    -- Deserialize unit data
    if(inMessage:HasUnitData()) then
        local unitData = XF:DeserializeUnitData(inMessage:GetData())
        inMessage:SetData(unitData)
        if(not unitData:HasVersion()) then
            unitData:Version(inMessage:GetVersion())
        end
    end

    self:Add(inMessage:Key())
    inMessage:Print()

    --#region Forwarding
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessageTag == XF.Enum.Tag.LOCAL) then

        if(XFO.Friends:ContainsByGUID(inMessage:GetFrom())) then
            local friend = XFO.Friends:GetByGUID(inMessage:GetFrom())
            if(not friend:IsLinked()) then
                XF.Mailbox.BNet:Ping(friend)
            end
        end

        if(inMessage:HasTargets()) then
            -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
            -- local nodeCount = XF.Nodes:GetTargetCount(XF.Player.Target)
            -- if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
            --     local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
            --     if(math.random(1, 100) <= percentage) then
            --         XF:Debug(ObjectName, 'Randomly selected, forwarding message')
            --         inMessage:SetType(XF.Enum.Network.BNET)
            --         XF.Mailbox.BNet:Send(inMessage)
            --     else
            --         XF:Debug(ObjectName, 'Not randomly selected, will not forward mesesage')
            --     end
            -- else
            --     XF:Debug(ObjectName, 'Node count under threshold, forwarding message')
                inMessage:SetType(XF.Enum.Network.BNET)
                XF.Mailbox.BNet:Send(inMessage)
            -- end
        end

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XF.Enum.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:SetType(XF.Enum.Network.BROADCAST)
        else
            inMessage:SetType(XF.Enum.Network.LOCAL)
        end
        XF.Mailbox.Chat:Send(inMessage)
    end
    --#endregion

    --#region Process message
    -- Process GCHAT message
    if(inMessage:GetSubject() == XF.Enum.Message.GCHAT) then
        if(XF.Player.Unit:CanGuildListen() and not XF.Player.Guild:Equals(inMessage:GetGuild())) then
            XF.Frames.Chat:DisplayGuildChat(inMessage)
        end
        return
    end

    -- Process ACHIEVEMENT message
    if(inMessage:GetSubject() == XF.Enum.Message.ACHIEVEMENT) then
        -- Local guild achievements should already be displayed by WoW client
        if(not XF.Player.Guild:Equals(inMessage:GetGuild())) then
            XF.Frames.Chat:DisplayAchievement(inMessage)
        end
        return
    end

    -- Process LINK message
    if(inMessage:GetSubject() == XF.Enum.Message.LINK) then
        XFO.Links:ProcessMessage(inMessage)
        return
    end

    -- Process LOGOUT message
    if(inMessage:GetSubject() == XF.Enum.Message.LOGOUT) then
        XFO.Confederate:ProcessMessage(inMessage)        
        return
    end

    -- Process ORDER message
    if(inMessage:GetSubject() == XF.Enum.Message.ORDER) then
        local order = nil
        try(function ()
            order = XFO.Orders:Pop()
            order:Decode(inMessage:GetData())
            if(not XFO.Orders:Contains(order:Key())) then
                XFO.Orders:Add(order)
                order:Display()
            else
                XFO.Orders:Push(order)
            end
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
            XFO.Orders:Push(order)
        end)
        return
    end

    -- Process DATA/LOGIN message
    if(inMessage:HasUnitData()) then
        local unitData = inMessage:GetData()
        if(inMessage:GetSubject() == XF.Enum.Message.LOGIN and 
          (not XFO.Confederate:Contains(unitData:Key()) or XFO.Confederate:Get(unitData:Key()):IsOffline())) then
            XF.Frames.System:DisplayLoginMessage(inMessage)
        end
        XFO.Confederate:Add(unitData)
        XF:Info(ObjectName, 'Updated unit [%s] information based on message received', unitData:UnitName())
        XF.DataText.Guild:RefreshBroker()
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