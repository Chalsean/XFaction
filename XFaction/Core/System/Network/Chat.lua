local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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
        XF.Enum.Tag.LOCAL = XFO.Confederate:GetKey() .. 'XF'						
        XFO.Events:Add({
            name = 'ChatMsg', 
            event = 'CHAT_MSG_ADDON', 
            callback = XFO.Chat.ChatReceive, 
            instance = true
        })
        XFO.Events:Add({
            name = 'GuildChat', 
            event = 'CHAT_MSG_GUILD', 
            callback = XFO.Chat.GuildMessage, 
            instance = true
        })
        XFO.Events:Add({
            name = 'Achievement', 
            event = 'ACHIEVEMENT_EARNED', 
            callback = XFO.Chat.Achievement, 
            instance = true
        })
        XFO.Events:Add({
            name = 'Logout',
            event = 'PLAYER_LOGOUT',
            callback = XFO.Chat.Logout,
            instance = true
        })
        XFO.Timers:Add({
            name = 'ChatMailbox', 
            delta = XF.Settings.Network.Mailbox.Scan, 
            callback = XFO.Chat.Purge,
            repeater = true
        })
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
    if(XFO.Channels:UseGuild() or not XFO.Channels:HasLocalChannel()) then
        channelName = 'GUILD'
        channelID = nil
    else
        channelName = 'CHANNEL'
        channelID = XFO.Channels:GetLocalChannel():GetID()
    end

    local packets = inMessage:Segment()
    for index, packet in ipairs (packets) do
        XF:Debug(self:GetObjectName(), 'Sending packet [%d:%d:%s] on channel [%s] with tag [%s] of length [%d]', index, #packets, inMessage:GetKey(), channelName, XF.Enum.Tag.LOCAL, strlen(packet))
        --XF.Lib.BCTL:SendAddonMessage('NORMAL', XF.Enum.Tag.LOCAL, packet, channelName, channelID)
        XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Increment()
    end

    -- Every message contains full unit data, reset heartbeat timer
    if(inMessage:IsMyMessage()) then
        XFO.Timers:Get('Heartbeat'):Reset()
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
        error(err)
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

--#region Callbacks
function XFC.Chat:GuildMessage(inText, _, _, _, _, _, _, _, _, _, _, inSenderGUID)
    local self = XFO.Chat
    try(function ()
        -- If you are the sender, broadcast to other realms/factions
        if(XF.Player.Unit:GetGUID() == inSenderGUID and XF.Player.Unit:CanGuildSpeak()) then
            local message = nil
            try(function ()
                message = self:Pop()
                message:Initialize()
                message:SetType(XF.Enum.Network.BROADCAST)
                message:SetSubject(XF.Enum.Message.GCHAT)
                message:SetData(inText)
                self:Send(message, true)
            end).
            finally(function ()
                self:Push(message)
            end)
        end
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)
end

function XFC.Chat:Achievement(inID)
    local self = XFO.Chat
    try(function ()
        local _, name, _, _, _, _, _, _, _, _, _, isGuild = XFF.PlayerGetAchievement(inID)
        if(not isGuild and string.find(name, XF.Lib.Locale['EXPLORE']) == nil) then
            local message = nil
            try(function ()
                message = XFO.Chat:Pop()
                message:Initialize()
                message:SetType(XF.Enum.Network.BROADCAST)
                message:SetSubject(XF.Enum.Message.ACHIEVEMENT)
                message:SetData(inID) -- Leave as ID to localize on receiving end
                self:Send(message)
            end).
            finally(function ()
                self:Push(message)
            end)
        end
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)    
end

function XFC.Chat:Logout()
    local self = XFO.Chat
    if(not XF.Cache.UIReload) then
        local message = nil
        try(function ()
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout started'
            message = self:Pop()
            message:Initialize()
            message:SetType(XF.Enum.Network.BROADCAST)
            message:SetSubject(XF.Enum.Message.LOGOUT)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout sending message'
            self:Send(message)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Logout message sent'
        end).
        catch(function (err)
            XF:Error(self:GetObjectName(), err)
            XF.Config.Logout[#XF.Config.Logout + 1] = 'Failed to send logout message: ' .. err
        end).
        finally(function()
            self:Push(message)
        end)
    end
end
--#endregion