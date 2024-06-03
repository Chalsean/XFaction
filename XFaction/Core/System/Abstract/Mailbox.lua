local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Mailbox'

XFC.Mailbox = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.Mailbox:new()
    local object = XFC.Mailbox.parent.new(self)
	object.__name = ObjectName
	object.objects = nil
    object.objectCount = 0   
    object.packets = nil
	return object
end

function XFC.Mailbox:newChildConstructor()
    local object = XFC.Mailbox.parent.new(self)
    object.__name = ObjectName
    object.parent = self 
	object.objects = nil
    object.objectCount = 0   
    object.packets = nil
    return object
end

function XFC.Mailbox:NewObject()
	return XFC.Message:new()
end

function XFC.Mailbox:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end

function XFC.Mailbox:ParentInitialize()
    self.packets = {}
    self.objects = {}
    self.checkedIn = {}
    self.checkedOut = {}
    self.key = math.GenerateUID()
end
--#endregion

--#region Methods
function XFC.Mailbox:ContainsPacket(inKey)
	assert(type(inKey) == 'string')
	return self.packets[inKey] ~= nil
end

function XFC.Mailbox:Add(inKey)
	assert(type(inKey) == 'string')
	if(not self:Contains(inKey)) then
		self.objects[inKey] = XFF.TimeGetCurrent()
	end
end

function XFC.Mailbox:AddPacket(inMessageKey, inPacketNumber, inData)
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketNumber) == 'number')
    assert(type(inData) == 'string')
    if(not self:ContainsPacket(inMessageKey)) then
        self.packets[inMessageKey] = {}
    end
    if(self.packets[inMessageKey][inPacketNumber] == nil) then
        self.packets[inMessageKey][inPacketNumber] = inData
    end
end

function XFC.Mailbox:RemovePacket(inKey)
	assert(type(inKey) == 'string')
	if(self:ContainsPacket(inKey)) then
		self.packets[inKey] = nil
	end
end

function XFC.Mailbox:SegmentMessage(inEncodedData, inMessageKey, inPacketSize)
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

function XFC.Mailbox:HasAllPackets(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(self.packets[inKey] == nil) then return false end
    return #self.packets[inKey] == inTotalPackets
end

function XFC.Mailbox:RebuildMessage(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    local message = ''
    -- Stitch the data back together again
    for _, packet in PairsByKeys(self.packets[inKey]) do
        message = message .. packet
    end
    self:RemovePacket(inKey)
	return message
end

function XFC.Mailbox:IsAddonTag(inTag)
	local addonTag = false
    for _, tag in pairs (XF.Enum.Tag) do
        if(inTag == tag) then
            addonTag = true
            break
        end
    end
	return addonTag
end

function XFC.Mailbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    XF:Trace(self:ObjectName(), 'Received %s packet from %s for tag %s', inDistribution, inSender, inMessageTag)

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
    if(XFO.BNet:Contains(messageKey) or XFO.Chat:Contains(messageKey)) then
        XF:Trace(self:ObjectName(), 'Ignoring duplicate message [%s]', messageKey)
        return
    end
    --#endregion

    self:AddPacket(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then
        XF:Debug(self:ObjectName(), 'Received all packets for message [%s]', messageKey)
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

function XFC.Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    -- Is a newer version available?
    if(not XF.Cache.NewVersionNotify and inMessage:HasVersion() and XF.Version:IsNewer(inMessage:Version())) then
        print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
        XF.Cache.NewVersionNotify = true
    end

    self:Add(inMessage:Key())
    inMessage:Print()

    --#region Forwarding
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessageTag == XF.Enum.Tag.LOCAL) then

        if(XFO.Friends:ContainsByGUID(inMessage:From())) then
            local friend = XFO.Friends:GetByGUID(inMessage:From())
            if(friend:CanLink() and not friend:IsLinked()) then
                XFO.BNet:Ping(friend)
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
                inMessage:Type(XF.Enum.Network.BNET)
                XFO.BNet:Send(inMessage)
            -- end
        end

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XF.Enum.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:Type(XF.Enum.Network.BROADCAST)
        else
            inMessage:Type(XF.Enum.Network.LOCAL)
        end
        XFO.Chat:Send(inMessage)
    end
    --#endregion

    --#region Process message
    -- LOGOUT message
    if(inMessage:IsLogout()) then
        XFO.Confederate:ProcessMessage(inMessage)        
        return
    end

    -- Legacy DATA/LOGIN message
    if(inMessage:IsLegacy() and (inMessage:IsLogin() or inMessage:IsData())) then
        XFO.Confederate:ProcessMessage(inMessage)
        return
    end

    -- Legacy LINK message
    if(inMessage:IsLink()) then
        XFO.Links:ProcessMessage(inMessage)
        return
    end

    -- All non-LOGOUT messages have unit and link data
    if(not inMessage:IsLegacy()) then
        XFO.Confederate:ProcessMessage(inMessage)
        if(inMessage:HasLinks()) then
            XFO.Links:ProcessMessage(inMessage)
        end
    end

    -- ACHIEVEMENT/GCHAT message
    if(inMessage:IsAchievement() or inMessage:IsGuildChat()) then
        XFO.ChatFrame:ProcessMessage(inMessage)
        return
    end    

    -- ORDER message
    if(inMessage:IsOrder()) then
        XFO.Orders:ProcessMessage(inMessage)
        return
    end
    --#endregion
end

function XFC.Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for key, receivedTime in self:Iterator() do
		if(receivedTime < inEpochTime) then
			self:Remove(key)
		end
	end
end
--#endregion