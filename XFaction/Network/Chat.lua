local XFG, G = unpack(select(2, ...))
local ObjectName = 'Chat'

Chat = Mailbox:newChildConstructor()

--#region Constructors
function Chat:new()
    local object = Chat.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function Chat:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Enum.Tag.LOCAL = XFG.Confederate:GetKey() .. 'XF'						
        XFG.Events:Add({name = 'ChatMsg', 
                        event = 'CHAT_MSG_ADDON', 
                        callback = XFG.Mailbox.Chat.ChatReceive, 
                        instance = true})
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Send
function Chat:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(not XFG.Settings.System.Roster and inMessage:GetSubject() == XFG.Enum.Message.DATA) then return end

    XFG:Debug(ObjectName, 'Attempting to send message')
    inMessage:Print()

    --#region BNet messaging for BNET/BROADCAST types
    if(inMessage:GetType() == XFG.Enum.Network.BROADCAST or inMessage:GetType() == XFG.Enum.Network.BNET) then
        XFG.Mailbox.BNet:Send(inMessage)
        -- Failed to bnet to all targets, broadcast to leverage others links
        if(inMessage:HasTargets() and inMessage:IsMyMessage() and inMessage:GetType() == XFG.Enum.Network.BNET) then
            inMessage:SetType(XFG.Enum.Network.BROADCAST)
        -- Successfully bnet to all targets and only were supposed to bnet, were done
        elseif(inMessage:GetType() == XFG.Enum.Network.BNET) then
            return
        -- Successfully bnet to all targets and was broadcast, switch to local only
        elseif(not inMessage:HasTargets() and inMessage:GetType() == XFG.Enum.Network.BROADCAST) then
            XFG:Debug(ObjectName, "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:SetType(XFG.Enum.Network.LOCAL)        
        end
    end
    --#endregion

    --#region Chat channel messaging for BROADCAST/LOCAL types
    local messageData = XFG:EncodeChatMessage(inMessage, true)
    local packets = self:SegmentMessage(messageData, inMessage:GetKey(), XFG.Settings.Network.Chat.PacketSize)
    self:Add(inMessage:GetKey())

    -- If only guild on target, broadcast to GUILD
    local channelName, channelID = 'CHANNEL', XFG.Channels:GetLocalChannel():GetID()
    -- Otherwise broadcast to custom channel
    -- if(not XFG.Channels:UseGuild() and XFG.Channels:HasLocalChannel()) then
    --     channelName = 'CHANNEL'
    --     channelID = XFG.Channels:GetLocalChannel():GetID()
    -- end
    for index, packet in ipairs (packets) do
        XFG:Debug(ObjectName, 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d]', index, #packets, inMessage:GetKey(), channelName, XFG.Enum.Tag.LOCAL, strlen(packet))
        XFG.Lib.BCTL:SendAddonMessage('NORMAL', XFG.Enum.Tag.LOCAL, packet, channelName, channelID)
        XFG.Metrics:Get(XFG.Enum.Metric.ChannelSend):Increment()
    end
    --#endregion
end
--#endregion

--#region Receive
function Chat:DecodeMessage(inEncodedMessage)
    return XFG:DecodeChatMessage(inEncodedMessage)
end

function Chat:ChatReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    try(function ()
        XFG.Mailbox.Chat:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion