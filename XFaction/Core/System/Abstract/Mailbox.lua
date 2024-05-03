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

-- We don't need to store the whole message, just the uid
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
        self.packets[inMessageKey].Count = 0
    end
    if(self.packets[inMessageKey][inPacketNumber] == nil) then
        self.packets[inMessageKey][inPacketNumber] = inData
        self.packets[inMessageKey].Count = self.packets[inMessageKey].Count + 1
    end
end

function XFC.Mailbox:RemovePacket(inKey)
	assert(type(inKey) == 'string')
	if(self:ContainsPacket(inKey)) then
		self.packets[inKey] = nil
	end
end

function XFC.Mailbox:HasAllPackets(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(self.packets[inKey] == nil) then return false end
    return self.packets[inKey].Count == inTotalPackets
end

function XFC.Mailbox:RebuildMessage(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    local message = ''
    -- Stitch the data back together again
    for _, packet in pairs(self.packets[inKey]) do
        message = message .. packet
    end
    self:RemovePacket(inKey)
	return message
end

local function IsAddonTag(inTag)
    for _, tag in pairs (XF.Enum.Tag) do
        if(inTag == tag) then
            return true
        end
    end
	return false
end

function XFC.Mailbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    XF:Trace(self:ObjectName(), 'Received %s packet from %s for tag %s', inDistribution, inSender, inMessageTag)

    --#region Ignore message
    -- If not a message from this addon, ignore
    if(not IsAddonTag(inMessageTag)) then
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
        XF:Trace(self:ObjectName(), 'Ignoring segment of duplicate message [%s]', messageKey)
        return
    end
    --#endregion

    self:AddPacket(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then
        XF:Debug(self:ObjectName(), 'Received all packets [%d] for message [%s]', totalPackets, messageKey)
        local encoded = self:RebuildMessage(messageKey, totalPackets)
        if(encoded ~= nil) then
            local message = self:DecodeMessage(encoded)        
            try(function ()
                message:Key(messageKey)
                self:Process(message, inMessageTag)
            end).
            finally(function ()
                self:Push(message)
            end)
        end
    end
end

local function ForwardMessage(inMessage)
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XF.Enum.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        --local nodeCount = XFO.Nodes:GetTargetCount(XF.Player.Target)
        --if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
        --    local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
        --    if(math.random(1, 100) <= percentage) then
        --        XF:Debug(self:GetObjectName(), 'Randomly selected, forwarding message')
                inMessage:SetType(XF.Enum.Network.BNET)
                XFO.BNet:Send(inMessage)
        --    else
        --        XF:Debug(self:GetObjectName(), 'Not randomly selected, will not forward mesesage')
        --    end
        --else
        --    XF:Debug(self:GetObjectName(), 'Node count under threshold, forwarding message')
        --    inMessage:Type(XF.Enum.Network.BNET)
        --    XFO.BNet:Send(inMessage)
    --end

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XF.Enum.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:Type(XF.Enum.Network.BROADCAST)
        else
            inMessage:Type(XF.Enum.Network.LOCAL)
        end
        XFO.Chat:Send(inMessage)
    end
end

local function ProcessLinkMessage(inMessage)
    local linkStrings = string.Split(inMessage:Data(), '|')
    local links = {}
    local from = XFO.Confederate:Get(inMessage:From())
    if(from ~= nil) then
        -- Add new links
        for _, linkString in pairs (linkStrings) do
            local nodes = string.Split(linkString, ';')
            local node = string.Split(nodes[2], ':')
            local to = XFO.Confederate:Get(node[1], tonumber(node[2]), tonumber(node[3]))
            if(to ~= nil) then
                links[to:Key()] = true
                from:AddLink(to:Key())
                to:AddLink(from:Key())
            end
        end
        -- Remove stale links
        for linked in from:Links() do
            if(links[linked] == nil) then
                from:RemoveLink(linked)
            end
        end
    end
end

function XFC.Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    -- Is a newer version available?
    if(not XF.Cache.NewVersionNotify and inMessage:HasVersion() and XFO.Version:IsNewer(inMessage:Version())) then
        print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
        XF.Cache.NewVersionNotify = true
    end

    self:Add(inMessage:Key())
    inMessage:Print()
    ForwardMessage(inMessage)

    -- Process GCHAT/ACHIEVEMENT message
    if(inMessage:Subject() == XF.Enum.Message.GCHAT or inMessage:Subject() == XF.Enum.Message.ACHIEVEMENT) then
        XFO.ChatFrame:ProcessMessage(inMessage)

    -- Process ORDER message
    elseif(inMessage:Subject() == XF.Enum.Message.ORDER) then
        XFO.Orders:ProcessMessage(inMessage)

    -- Process LINK message
    elseif(inMessage:Subject() == XF.Enum.Message.LINK) then
        ProcessLinkMessage(inMessage)

    -- Process LOGOUT/LOGIN/DATA messages
    else
        XFO.Confederate:ProcessMessage(inMessage)
    end
end

function XFC.Mailbox:Purge()
    -- TODO
	-- for key, receivedTime in self:Iterator() do
	-- 	if(receivedTime < XFF.TimeGetCurrent() - XF.Settings.Network.Mailbox.Stale) then
	-- 		self:Remove(key)
	-- 	end
	-- end
end
--#endregion