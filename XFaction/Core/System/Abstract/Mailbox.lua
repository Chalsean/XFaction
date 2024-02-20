local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Mailbox'
local GetEpochTime = GetServerTime

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
--#endregion

--#region Initializers
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

--#region Hash
function XFC.Mailbox:ContainsPacket(inKey)
	assert(type(inKey) == 'string')
	return self.packets[inKey] ~= nil
end

function XFC.Mailbox:Add(inKey)
	assert(type(inKey) == 'string')
	if(not self:Contains(inKey)) then
		self.objects[inKey] = GetEpochTime()
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
--#endregion

--#region Segmentation
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
--#endregion

--#region Receive
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

    XF:Trace(self:GetObjectName(), 'Received %s packet from %s for tag %s', inDistribution, inSender, inMessageTag)

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
        XF:Trace(self:GetObjectName(), 'Ignoring segment of duplicate message [%s]', messageKey)
        return
    end
    --#endregion

    self:AddPacket(messageKey, packetNumber, messageData)
    if(self:HasAllPackets(messageKey, totalPackets)) then
        XF:Debug(self:GetObjectName(), 'Received all packets for message [%s]', messageKey)
        local encoded = self:RebuildMessage(messageKey, totalPackets)
        local message = self:DecodeMessage(encoded)        
        try(function ()
            message:SetKey(messageKey)
            self:Process(message, inMessageTag)
        end).
        finally(function ()
            self:Push(message)
        end)
    end
end

function XFC.Mailbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    -- Deserialize unit data
    local unit = nil
    try(function()
        unit = XFO.Confederate:Pop()
        unit:Deserialize(inMessage:GetFrom())
        inMessage:SetFrom(unit)
    end).
    catch(function(err)
        XFO.Confederate:Push(unit)
        throw(err)
    end)

    -- Is a newer version available?
    if(not XF.Cache.NewVersionNotify and XFO.Version:IsNewer(inMessage:GetFrom():GetVersion())) then
        print(format(XF.Lib.Locale['NEW_VERSION'], XF.Title))
        XF.Cache.NewVersionNotify = true
    end

    self:Add(inMessage:GetKey())
    inMessage:Print()

    --#region Forwarding
    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XF.Enum.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        local nodeCount = XFO.Nodes:GetTargetCount(XF.Player.Target)
        if(nodeCount > XF.Settings.Network.BNet.Link.PercentStart) then
            local percentage = (XF.Settings.Network.BNet.Link.PercentStart / nodeCount) * 100
            if(math.random(1, 100) <= percentage) then
                XF:Debug(self:GetObjectName(), 'Randomly selected, forwarding message')
                inMessage:SetType(XF.Enum.Network.BNET)
                XFO.BNet:Send(inMessage)
            else
                XF:Debug(self:GetObjectName(), 'Not randomly selected, will not forward mesesage')
            end
        else
            XF:Debug(self:GetObjectName(), 'Node count under threshold, forwarding message')
            inMessage:SetType(XF.Enum.Network.BNET)
            XFO.BNet:Send(inMessage)
        end

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XF.Enum.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:SetType(XF.Enum.Network.BROADCAST)
        else
            inMessage:SetType(XF.Enum.Network.LOCAL)
        end
        XFO.Chat:Send(inMessage)
    end
    --#endregion

    --#region Process message
    -- Process GCHAT message
    if(inMessage:GetSubject() == XF.Enum.Message.GCHAT) then
        -- FIX: Move this check to ChatFrame
        if(XF.Player.Unit:CanGuildListen() and not XF.Player.Guild:Equals(inMessage:GetGuild())) then
            XFO.ChatFrame:DisplayGuildChat(inMessage)
        end

    -- Process ACHIEVEMENT message
    elseif(inMessage:GetSubject() == XF.Enum.Message.ACHIEVEMENT) then
        -- Local guild achievements should already be displayed by WoW client
        -- FIX: Move this check to ChatFrame
        if(not XF.Player.Guild:Equals(inMessage:GetGuild())) then
            XFO.ChatFrame:DisplayAchievement(inMessage)
        end

    -- Process LINK message
    elseif(inMessage:GetSubject() == XF.Enum.Message.LINK) then
        XFO.Links:Deserialize(inMessage:GetData())
        -- Purge stale links from sender
        for _, link in XFO.Links:Iterator() do
            if(link:GetFromNode():GetName() == inMessage:GetFrom():GetName() or link:GetToNode():GetName() == inMessage:GetFrom():GetName()) then
                if(link:GetTimeStamp() < inMessage:GetTimeStamp()) then
                    XFO.Links:Remove(link:GetKey())
                end
            end
        end

    -- Process ORDER message
    elseif(XFO.WoW:IsRetail() and inMessage:GetSubject() == XF.Enum.Message.ORDER) then
        local order = nil
        try(function ()
            order = XFO.Orders:Pop()
            order:Decode(inMessage:GetData())
            if(not XFO.Orders:Contains(order:GetKey())) then
                XFO.Orders:Add(order)
                order:Display()
            else
                XFO.Orders:Push(order)
            end
        end).
        catch(function (inErrorMessage)
            XF:Warn(self:GetObjectName(), inErrorMessage)
            XFO.Orders:Push(order)
        end)
    end

    -- Process LOGOUT message
    if(inMessage:GetSubject() == XF.Enum.Message.LOGOUT) then
        if(XF.Player.Guild:Equals(inMessage:GetGuild())) then
            -- In case we get a message before scan
            if(not XFO.Confederate:Contains(inMessage:GetFrom())) then
                XFO.SystemFrame:DisplayLogoutMessage(inMessage)
            else
                if(XFO.Confederate:Get(inMessage:GetFrom()):IsOnline()) then
                    XFO.SystemFrame:DisplayLogoutMessage(inMessage)
                end
                XFO.Confederate:OfflineUnit(inMessage:GetFrom())
            end
        else
            XFO.SystemFrame:DisplayLogoutMessage(inMessage)
            XFO.Confederate:Remove(inMessage:GetFrom())
        end
    else
        -- Process LOGIN message
        if(inMessage:GetSubject() == XF.Enum.Message.LOGIN and (not XFO.Confederate:Contains(unitData:GetKey()) or XFO.Confederate:Get(unitData:GetKey()):IsOffline())) then
            XFO.SystemFrame:DisplayLoginMessage(inMessage)
        end
        -- All data packets have unit information, so just refresh
        XFO.Confederate:Add(inMessage:GetFrom())
        XF:Info(self:GetObjectName(), 'Updated unit [%s] information based on message received', inMessage:GetFrom():GetUnitName())
    end

    XFO.DTGuild:RefreshBroker()
    --#endregion
end
--#endregion

--#region Janitorial
function XFC.Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for key, receivedTime in self:Iterator() do
		if(receivedTime < inEpochTime) then
			self:Remove(key)
		end
	end
end
--#endregion