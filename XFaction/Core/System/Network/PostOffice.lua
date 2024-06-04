local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'PostOffice'

XFC.PostOffice = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.PostOffice:new()
    local object = XFC.PostOffice.parent.new(self)
	object.__name = ObjectName
	return object
end
--#endregion

--#region Methods
function XFC.PostOffice:Add(inMessageKey, inPacketNumber, inData)
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketNumber) == 'number')
    assert(type(inData) == 'string')
    if(not self:Contains(inMessageKey)) then
        self.objects[inMessageKey] = {}
    end
    if(self.objects[inMessageKey][inPacketNumber] == nil) then
        self.objects[inMessageKey][inPacketNumber] = inData
    end
end

function XFC.PostOffice:SegmentMessage(inEncodedData, inMessageKey, inPacketSize)
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

function XFC.PostOffice:HasAllPackets(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(not self:Contains(inKey)) then return false end
    return #self.objects[inKey] == inTotalPackets
end

function XFC.PostOffice:RebuildMessage(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    local message = ''
    -- Stitch the data back together again
    for _, packet in PairsByKeys(self:Get(inKey)) do
        message = message .. packet
    end
    self:Remove(inKey)
	return message
end

function XFC.PostOffice:IsAddonTag(inTag)
	local addonTag = false
    for _, tag in pairs (XF.Enum.Tag) do
        if(inTag == tag) then
            addonTag = true
            break
        end
    end
	return addonTag
end

function XFC.PostOffice:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

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
    if(XFO.Mailbox:Contains(messageKey)) then
        XF:Trace(self:ObjectName(), 'Ignoring duplicate message [%s]', messageKey)
        return
    end
    --#endregion

    self:Add(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then

        XF:Debug(self:ObjectName(), 'Received all packets for message [%s]', messageKey)

        XFO.Mailbox:Add(messageKey)
        local encodedMessage = self:RebuildMessage(messageKey, totalPackets)
        local message = XFO.Mailbox:Pop()

        try(function ()
            message:Deserialize(encodedMessage, inMessageTag)
            XFO.Mailbox:Process(message, inMessageTag)
            self:Forward(message, inMessageTag)
        end).
        finally(function ()
            XFO.Mailbox:Push(message)
        end)
    end
end

function XFC.PostOffice:Forward(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

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
        XFO.Chat:SendChannel(inMessage)
    end
end

function XFC.PostOffice:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    XF:Debug(self:ObjectName(), 'Attempting to send message')
    inMessage:Print()
    XFO.Mailbox:Add(inMessage:Key())

    -- BNET/BROADCAST
    if(inMessage:Type() == XF.Enum.Network.BROADCAST or inMessage:Type() == XF.Enum.Network.BNET) then
        XFO.BNet:Send(inMessage)
        -- Failed to bnet to all targets, broadcast to leverage others links
        if(inMessage:HasTargets() and inMessage:IsMyMessage() and inMessage:Type() == XF.Enum.Network.BNET) then
            inMessage:Type(XF.Enum.Network.BROADCAST)
        -- Successfully bnet to all targets and only were supposed to bnet, were done
        elseif(inMessage:Type() == XF.Enum.Network.BNET) then
            return
        -- Successfully bnet to all targets and was broadcast, switch to local only
        elseif(not inMessage:HasTargets() and inMessage:Type() == XF.Enum.Network.BROADCAST) then
            XF:Debug(self:ObjectName(), "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:Type(XF.Enum.Network.LOCAL)        
        end
    end

    -- BROADCAST/LOCAL
    XFO.Chat:SendChannel(inMessage)
end
--#endregion