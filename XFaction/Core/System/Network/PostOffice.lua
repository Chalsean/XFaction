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
        self.objectCount = self.objectCount + 1
    end
    if(self.objects[inMessageKey][inPacketNumber] == nil) then
        self.objects[inMessageKey][inPacketNumber] = inData
    end
end

function XFC.PostOffice:SegmentMessage(inEncodedData, inMessageKey, inPacketSize)
	assert(type(inEncodedData) == 'string')
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketSize) == 'number')

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
    if(self.objects[inKey] == nil) then return false end
    return #self.objects[inKey] == inTotalPackets
end

function XFC.PostOffice:RebuildMessage(inKey)
    assert(type(inKey) == 'string')
    local message = ''
    -- Stitch the data back together again
    for _, packet in PairsByKeys(self.objects[inKey]) do
        message = message .. packet
    end
    return message
end

function XFC.PostOffice:IsAddonTag(inTag)
	return string.StartsWith(inTag, XFO.Tags:Prefix())
end

function XFC.PostOffice:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    XF:Trace(self:ObjectName(), 'Received %s packet from %s for tag %s', inDistribution, inSender, inMessageTag)

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

    self:Add(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then
        XF:Debug(self:ObjectName(), 'Received all packets for message [%s]', messageKey)
        local encodedMessage = self:RebuildMessage(messageKey, totalPackets)

        local message = XFO.Mailbox:Pop()
        try(function()
            message:Decode(encodedMessage, inMessageTag)            
            message:Print()
            XFO.Mailbox:Process(message)
            self:Remove(messageKey)
        end).
        catch(function(err)
            XF:Warn(self:ObjectName(), err)
        end).
        finally(function()
            XFO.Mailbox:Push(message)
        end)
    end
end
--#endregion