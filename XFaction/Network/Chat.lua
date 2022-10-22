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
        XFG.Settings.Network.Message.Tag.LOCAL = XFG.Confederate:GetKey() .. 'XF'						
        XFG.Events:Add('ChatMsg', 'CHAT_MSG_ADDON', XFG.Mailbox.Chat.ChatReceive)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Send
function Chat:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(not XFG.Settings.System.Roster and inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.DATA) then return end
    inMessage:SetFrom(XFG.Player.GUID)

    XFG:Debug(ObjectName, 'Attempting to send message')
    inMessage:Print()

    --#region BNet messaging for BNET/BROADCAST types
    if(inMessage:GetType() == XFG.Settings.Network.Type.BROADCAST or inMessage:GetType() == XFG.Settings.Network.Type.BNET) then
        XFG.Mailbox.BNet:Send(inMessage)
        -- Failed to bnet to all targets, broadcast to leverage others links
        if(inMessage:HasTargets() and inMessage:IsMyMessage() and inMessage:GetType() == XFG.Settings.Network.Type.BNET) then
            inMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
        -- Successfully bnet to all targets and only were supposed to bnet, were done
        elseif(inMessage:GetType() == XFG.Settings.Network.Type.BNET) then
            return
        -- Successfully bnet to all targets and was broadcast, switch to local only
        elseif(not inMessage:HasTargets() and inMessage:GetType() == XFG.Settings.Network.Type.BROADCAST) then
            XFG:Debug(ObjectName, "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:SetType(XFG.Settings.Network.Type.LOCAL)        
        end
    end
    --#endregion

    --#region Chat channel messaging for BROADCAST/LOCAL types
    local messageData = XFG:EncodeChatMessage(inMessage, true)
    local packets = self:SegmentMessage(messageData, inMessage:GetKey(), XFG.Settings.Network.Chat.PacketSize)

    -- Broadcast on same realm/faction channel for multiple players
    if(XFG.Channels:HasLocalChannel()) then
        self:Add(inMessage:GetKey())
        local channel = XFG.Channels:GetLocalChannel()
        if(XFG.Verbosity) then
            XFG:Debug(ObjectName, 'Broadcasting on channel [%s] with tag [%s]', channel:GetName(), XFG.Settings.Network.Message.Tag.LOCAL)
        end

        for index, packet in ipairs (packets) do
            if(XFG.Verbosity) then
                XFG:Debug(ObjectName, 'Sending packet [%d:%d] with tag [%s] of length [%d]', index, #packets, XFG.Settings.Network.Message.Tag.LOCAL, strlen(packet))
            end
            XFG.Lib.BCTL:SendAddonMessage('NORMAL', XFG.Settings.Network.Message.Tag.LOCAL, packet, 'CHANNEL', channel:GetID())
            XFG.Metrics:Get(XFG.Settings.Metric.ChannelSend):Increment()
        end        
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