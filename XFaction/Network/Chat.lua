local XFG, G = unpack(select(2, ...))
local ObjectName = 'Chat'

Chat = Mailbox:newChildConstructor()

function Chat:new()
    local _Object = Chat.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function Chat:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG:Info(ObjectName, "Registering to receive [%s] messages", XFG.Settings.Network.Message.Tag.LOCAL)
        XFG:RegisterEvent('CHAT_MSG_ADDON', XFG.Mailbox.Chat.ChatReceive)
        XFG:Info(ObjectName, 'Registered for CHAT_MSG_ADDON events')
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Chat:DecodeMessage(inEncodedMessage)
    return XFG:DecodeMessage(inEncodedMessage)
end

function Chat:ChatReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    try(function ()
        XFG.Mailbox.Chat:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end

function Chat:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(not XFG.Settings.System.Roster and inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.DATA) then return end
    inMessage:SetFrom(XFG.Player.GUID)

    XFG:Debug(ObjectName, 'Attempting to send message')
    inMessage:ShallowPrint()

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

    local _MessageData = XFG:EncodeMessage(inMessage, true)
    local _Packets = self:SegmentMessage(_MessageData, inMessage:GetKey())

    -- Broadcast on same realm/faction channel for multiple players
    if(XFG.Channels:HasLocalChannel()) then
        local _Channel = XFG.Channels:GetLocalChannel()
        if(XFG.DebugFlag) then
            XFG:Debug(ObjectName, 'Broadcasting on channel [%s] with tag [%s]', _Channel:GetName(), XFG.Settings.Network.Message.Tag.LOCAL)
        end

        for _Index, _Packet in ipairs (_Packets) do
            if(XFG.DebugFlag) then
                XFG:Debug(ObjectName, 'Sending packet [%d:%d] with tag [%s] of length [%d]', _Index, #_Packets, XFG.Settings.Network.Message.Tag.LOCAL, strlen(_Packet))
            end
            BCTL:SendAddonMessage('NORMAL', XFG.Settings.Network.Message.Tag.LOCAL, _Packet, 'CHANNEL', _Channel:GetID())
            XFG.Metrics:Get(XFG.Settings.Metric.ChannelSend):Increment()
        end
    end
end