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

        XFO.Events:Add({
            name = 'Achievement', 
            event = 'ACHIEVEMENT_EARNED', 
            callback = XFO.Chat.CallbackAchievement, 
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

    local data = inMessage:Encode()
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.Chat.PacketSize)
    local tag = XFO.Tags:GetRandomTag()
    local priority = (inMessage:IsHighPriority() and 'ALERT') or (inMessage:IsMediumPriority() and 'NORMAL') or 'BULK'

    for index, packet in ipairs (packets) do
        XF:Debug(self:ObjectName(), 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d] with priority [%s]', index, #packets, inMessage:Key(), inChannel:Name(), tag, strlen(packet), priority)
        XF.Lib.BCTL:SendAddonMessage(priority, tag, packet, inChannel:IsGuild() and 'GUILD' or 'CHANNEL', inChannel:ID())
        XFO.Metrics:Get(inChannel:IsGuild() and XF.Enum.Metric.GuildSend or XF.Enum.Metric.ChannelSend):Count(1)
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

function XFC.Chat:CallbackAchievement(inID)
    local self = XFO.Chat
    try(function ()
        local _, name, _, _, _, _, _, _, _, _, _, isGuild = XFF.PlayerAchievement(inID)
        if(not isGuild and string.find(name, XF.Lib.Locale['EXPLORE']) == nil) then
            XFO.Mailbox:SendAchievementMessage(inID)
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)    
end

function XFC.Chat:SendLogoutMessage(inKey, inChannel)
    assert(type(inKey) == 'string')
    assert(type(inChannel) == 'table' and inChannel.__name == 'Channel')
    local tag = XFO.Tags:GetRandomTag()
    local packet = '11' .. inKey .. 'LOGOUT' .. XF.Player.GUID
    XF.Lib.BCTL:SendAddonMessage('ALERT', tag, packet, inChannel:IsGuild() and 'GUILD' or 'CHANNEL', inChannel:ID())
end
--#endregion