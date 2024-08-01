local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Chat'

XFC.Chat = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Chat:new()
    local object = XFC.Chat.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.Chat:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        -- This is the event that fires when someone posts a message
        XF.Events:Add({
            name = 'ChatMsg', 
            event = 'CHAT_MSG_ADDON', 
            callback = XFO.Chat.CallbackReceive, 
            instance = true
        })
        -- This is the event that fires when you post a guild message
        XF.Events:Add({
            name = 'GuildChat', 
            event = 'CHAT_MSG_GUILD', 
            callback = XFO.Chat.CallbackGuildMessage,
            instance = true
        })

        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Send
function XFC.Chat:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    if(not XF.Settings.System.Roster and inMessage:Subject() == XF.Enum.Message.DATA) then return end

    XF:Debug(self:ObjectName(), 'Attempting to send message')
    inMessage:Print()

    --#region BNet messaging for BNET/BROADCAST types
    -- if(inMessage:Type() == XF.Enum.Network.BROADCAST or inMessage:Type() == XF.Enum.Network.BNET) then
    --     XFO.BNet:Send(inMessage)
    --     -- Failed to bnet to all targets, broadcast to leverage others links
    --     if(inMessage:HasTargets() and inMessage:IsMyMessage() and inMessage:Type() == XF.Enum.Network.BNET) then
    --         inMessage:Type(XF.Enum.Network.BROADCAST)
    --     -- Successfully bnet to all targets and only were supposed to bnet, were done
    --     elseif(inMessage:Type() == XF.Enum.Network.BNET) then
    --         return
    --     -- Successfully bnet to all targets and was broadcast, switch to local only
    --     elseif(not inMessage:HasTargets() and inMessage:Type() == XF.Enum.Network.BROADCAST) then
    --         XF:Debug(self:ObjectName(), "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
    --         inMessage:Type(XF.Enum.Network.LOCAL)        
    --     end
    -- end
    --#endregion

    --#region Chat channel messaging for BROADCAST/LOCAL types
    local data = inMessage:Serialize()
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.Chat.PacketSize)
    XFO.Mailbox:Add(inMessage:Key())

    -- If only guild on target, broadcast to GUILD
    local channelName, channelID
    -- Otherwise broadcast to custom channel
    if(XFO.Channels:HasLocalChannel()) then
        channelName = 'CHANNEL'
        channelID = XFO.Channels:LocalChannel():ID()
    else
        channelName = 'GUILD'
        channelID = nil
    end
    for index, packet in ipairs (packets) do
        XF:Debug(self:ObjectName(), 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d]', index, #packets, inMessage:Key(), channelName, XF.Enum.Tag.LOCAL, strlen(packet))
        XF.Lib.BCTL:SendAddonMessage('NORMAL', XFO.Tags:GetRandomTag(), packet, channelName, channelID)
        XF.Metrics:Get(XF.Enum.Metric.ChannelSend):Increment()
    end
    --#endregion
end

function XFC.Chat:EncodeMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
	local serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local compressed = Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
	return Deflate:EncodeForWoWAddonChannel(compressed)
end

function XFC.Chat:DecodeMessage(inEncodedMessage)
    return XF:DecodeChatMessage(inEncodedMessage)
end

function XFC.Chat:CallbackReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XFO.Chat
    try(function ()
        XFO.PostOffice:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.Chat:CallbackGuildMessage(inText, inSenderName, inLanguageName, _, inTarName, inFlags, _, inChannelID, _, _, inLineID, inSenderGUID)
    local self = XFO.Chat
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XF.Player.GUID == inSenderGUID and XF.Player.Unit:CanGuildSpeak()) then
            local message = nil
            try(function ()
                message = XFO.Mailbox:Pop()
                message:Initialize()
                message:From(XF.Player.Unit:GUID())
                message:Subject(XF.Enum.Message.GCHAT)
                message:Name(XF.Player.Unit:Name())
                message:UnitName(XF.Player.Unit:UnitName())
                message:SetGuild(XF.Player.Guild)
                if(XF.Player.Unit:IsAlt() and XF.Player.Unit:HasMainName()) then
                    message:SetMainName(XF.Player.Unit:GetMainName())
                end
                message:Data(inText)
                self:Send(message, true)
            end).
            finally(function ()
                XFO.Mailbox:Push(message)
            end)
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion