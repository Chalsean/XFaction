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
        XFO.Events:Add({
            name = 'ChatMsg', 
            event = 'CHAT_MSG_ADDON', 
            callback = XFO.Chat.CallbackReceive, 
            instance = true
        })
        -- This is the event that fires when you post a guild message
        XFO.Events:Add({
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

--#region Methods
function XFC.Chat:Broadcast(inMessage, inChannel)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    assert(type(inChannel) == 'table' and inChannel.__name == 'Channel')

    XF:Debug(self:ObjectName(), 'Attempting to send message')
    inMessage:Print()

    local data = inMessage:Serialize()
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.Chat.PacketSize)
    local tag = XFO.Tags:GetRandomTag()

    for index, packet in ipairs (packets) do
        XF:Debug(self:ObjectName(), 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d]', index, #packets, inMessage:Key(), inChannel:Name(), tag, strlen(packet))
        XF.Lib.BCTL:SendAddonMessage('NORMAL', tag, packet, inChannel:Name(), inChannel:ID())
        XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Increment()
    end
end

function XFC.Chat:Whisper(inMessage, inUnit)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')

    XF:Debug(self:ObjectName(), 'Attempting to whisper message')
    inMessage:Print()

    local data = inMessage:Serialize()
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.Chat.PacketSize)
    local tag = XFO.Tags:GetRandomTag()

    for index, packet in ipairs (packets) do
        XF:Debug(self:ObjectName(), 'Sending packet [%d:%d:%s] via whisper to [%s] with tag [%s] of length [%d]', index, #packets, inMessage:Key(), inUnit:UnitName(), tag, strlen(packet))
        XF.Lib.BCTL:SendAddonMessage('NORMAL', tag, packet, 'WHISPER', inUnit:UnitName())
        XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Increment()
    end
end

function XFC.Chat:EncodeMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
	local serialized = SerializeMessage(inMessage, inEncodeUnitData)
	local compressed = XF.Lib.Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
	return XF.Lib.Deflate:EncodeForWoWAddonChannel(compressed)
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

function XFC.Chat:CallbackGuildMessage(inText, _, _, _, _, _, _, _, _, _, _, inSenderGUID)
    local self = XFO.Chat
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XF.Player.GUID == inSenderGUID and XF.Player.Unit:CanGuildSpeak()) then
            XFO.Mailbox:SendGuildChatMessage(inText)
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion