local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Chat'

XFC.Chat = XFC.Mailbox:newChildConstructor()

--#region Constructors
function XFC.Chat:new()
    local object = XFC.Chat.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.Chat:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XF.Enum.Tag.LOCAL = XF.Confederate:GetKey() .. 'XF'						
        XFO.Events:Add({name = 'ChatMsg', 
                        event = 'CHAT_MSG_ADDON', 
                        callback = XFO.Chat.ChatReceive, 
                        instance = true})
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Send
function XFC.Chat:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(not XF.Settings.System.Roster and inMessage:GetSubject() == XF.Enum.Message.DATA) then return end

    XF:Debug(self:GetObjectName(), 'Attempting to send message')
    inMessage:Print()

    --#region BNet messaging for BNET/BROADCAST types
    if(inMessage:GetType() == XF.Enum.Network.BROADCAST or inMessage:GetType() == XF.Enum.Network.BNET) then
        XFO.BNet:Send(inMessage)
        -- Failed to bnet to all targets, broadcast to leverage others links
        if(inMessage:HasTargets() and inMessage:IsMyMessage() and inMessage:GetType() == XF.Enum.Network.BNET) then
            inMessage:SetType(XF.Enum.Network.BROADCAST)
        -- Successfully bnet to all targets and only were supposed to bnet, were done
        elseif(inMessage:GetType() == XF.Enum.Network.BNET) then
            return
        -- Successfully bnet to all targets and was broadcast, switch to local only
        elseif(not inMessage:HasTargets() and inMessage:GetType() == XF.Enum.Network.BROADCAST) then
            XF:Debug(self:GetObjectName(), "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:SetType(XF.Enum.Network.LOCAL)        
        end
    end
    --#endregion

    --#region Chat channel messaging for BROADCAST/LOCAL types
    -- Add to mailbox so we can ignore our own messages upon receipt 
    self:Add(inMessage:GetKey())
    
    local channelName, channelID
    -- Broadcast to custom channel if setup
    if(XFO.Channels:HasLocalChannel()) then
        channelName = 'CHANNEL'
        channelID = XFO.Channels:GetLocalChannel():GetID()
    -- Otherwise broadcast to GUILD
    else
        channelName = 'GUILD'
        channelID = nil
    end

    for index, packet in ipairs (inMessage:Segment()) do
        XF:Debug(self:GetObjectName(), 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d]', index, #packets, inMessage:GetKey(), channelName, XF.Enum.Tag.LOCAL, strlen(packet))
        XF.Lib.BCTL:SendAddonMessage('NORMAL', XF.Enum.Tag.LOCAL, packet, channelName, channelID)
        XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Increment()
    end
    --#endregion
end
--#endregion

--#region Receive
function XFC.Chat:DecodeMessage(inData)
    local message = nil
    try(function()
        message = self:Pop()
        message:Initialize()
        message:Decode(inData)
    end).
    catch(function(err)
        self:Push(message)
        throw(err)
    end)
    return message
end

function XFC.Chat:ChatReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XFO.Chat
    try(function ()
        self:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (inErrorMessage)
        XF:Warn(self:GetObjectName(), inErrorMessage)
    end)
end
--#endregion