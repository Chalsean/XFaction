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
    self.packets[inMessageKey][inPacketNumber] = inData
    self.packets[inMessageKey].Count = self.packets[inMessageKey].Count + 1
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
    for i = 1, inTotalPackets do
        message = message .. self.packets[inKey][i]
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
        XF:Debug(self:ObjectName(), 'Received all packets for message [%s]', messageKey)
        local encoded = self:RebuildMessage(messageKey, totalPackets)
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

function XFC.Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    -- Is a newer version available?
    if(not XF.Cache.NewVersionNotify and XFO.Version:IsNewer(inMessage:GetFrom():GetVersion())) then
        print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
        XF.Cache.NewVersionNotify = true
    end

    self:Add(inMessage:Key())
    inMessage:Print()

    --#region Forwarding
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XF.Enum.Tag.LOCAL) then
        -- -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        -- local nodeCount = XFO.Nodes:GetTargetCount(XF.Player.Target)
        -- if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
        --     local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
        --     if(math.random(1, 100) <= percentage) then
        --         XF:Debug(self:GetObjectName(), 'Randomly selected, forwarding message')
        --         inMessage:SetType(XF.Enum.Network.BNET)
        --         XFO.BNet:Send(inMessage)
        --     else
        --         XF:Debug(self:GetObjectName(), 'Not randomly selected, will not forward mesesage')
        --     end
        -- else
        --     XF:Debug(self:GetObjectName(), 'Node count under threshold, forwarding message')
            inMessage:Type(XF.Enum.Network.BNET)
            XFO.BNet:Send(inMessage)
--        end

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
    -- Process GCHAT message
    if(inMessage:Subject() == XF.Enum.Message.GCHAT) then
        -- FIX: Move this check to ChatFrame
        if(XF.Player.Unit:CanGuildListen() and not XF.Player.Guild:Equals(inMessage:Guild())) then
            XFO.ChatFrame:DisplayGuildChat(inMessage)
        end

    -- Process ACHIEVEMENT message
    elseif(inMessage:Subject() == XF.Enum.Message.ACHIEVEMENT) then
        -- Local guild achievements should already be displayed by WoW client
        -- FIX: Move this check to ChatFrame
        if(not XF.Player.Guild:Equals(inMessage:Guild())) then
            XFO.ChatFrame:DisplayAchievement(inMessage)
        end

    -- Process LINK message
    elseif(inMessage:Subject() == XF.Enum.Message.LINK) then
        XFO.Links:Deserialize(inMessage:GetData())

    -- Process ORDER message
    elseif(XFO.WoW:IsRetail() and inMessage:Subject() == XF.Enum.Message.ORDER) then
        local order = nil
        try(function ()
            order = XFO.Orders:Pop()
            order:Deserialize(inMessage:Data())
            order:Customer(inMessage:From())
            order:Display()
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)            
        end).
        finally(function()
            XFO.Orders:Push(order)
        end)
    end

    -- Process LOGOUT message
    if(inMessage:Subject() == XF.Enum.Message.LOGOUT) then
        if(XF.Player.Guild:Equals(inMessage:Guild())) then
            -- In case we get a message before scan
            if(not XFO.Confederate:Contains(inMessage:From():Key())) then
                XFO.SystemFrame:Display(inMessage:Subject(), inMessage:From())
            else
                if(XFO.Confederate:Get(inMessage:From():Key()):IsOnline()) then
                    XFO.SystemFrame:Display(inMessage:Subject(), inMessage:From())
                end
                XFO.Confederate:Offline(inMessage:From())
            end
        else
            XFO.SystemFrame:Display(inMessage:Subject(), inMessage:From())
            XFO.Confederate:Remove(inMessage:From())
        end
    else
        -- Process LOGIN message
        if(inMessage:Subject() == XF.Enum.Message.LOGIN and (not XFO.Confederate:Contains(inMessage:From():Key()) or XFO.Confederate:Get(inMessage:From():Key()):IsOffline())) then
            XFO.SystemFrame:Display(inMessage:Subject(), inMessage:From())
        end
        -- All data packets have unit information, so just refresh
        XFO.Confederate:Add(inMessage:From())
        XF:Info(self:ObjectName(), 'Updated unit [%s] information based on message received', inMessage:From():UnitName())
    end

    XFO.DTGuild:RefreshBroker()
    --#endregion
end

function XFC.Mailbox:Purge()
    -- FIX
	--for key, receivedTime in self:Iterator() do
	--	if(receivedTime < XFF.TimeGetCurrent() - XF.Settings.Network.Mailbox.Stale) then
	--		self:Remove(key)
	--	end
	--end
end
--#endregion