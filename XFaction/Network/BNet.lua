local XFG, G = unpack(select(2, ...))
local ObjectName = 'BNet'
local ServerTime = GetServerTime

BNet = Mailbox:newChildConstructor()

--#region Constructors
function BNet:new()
    local object = BNet.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function BNet:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Settings.Network.Message.Tag.BNET = XFG.Confederate:GetKey() .. 'BNET'
        XFG.Events:Add('BNetMessage', 'BN_CHAT_MSG_ADDON', XFG.Mailbox.BNet.BNetReceive, true, true)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Send
function BNet:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    -- Before we do work, lets make sure there are targets and we can message those targets
    local links = {}
    for _, target in pairs(inMessage:GetTargets()) do
        local friends = {}
        for _, friend in XFG.Friends:Iterator() do
            if(target:Equals(friend:GetTarget()) and
              -- At the time of login you may not have heard back on pings yet, so just broadcast
              (friend:IsRunningAddon() or inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN)) then
                friends[#friends + 1] = friend
            end
        end

        -- You should only ever have to message one addon user per target
        local friendCount = table.getn(friends)
        if(friendCount > 0) then
            local randomNumber = math.random(1, friendCount)
            links[#links + 1] = friends[randomNumber]
        else
            XFG:Debug(ObjectName, 'Unable to identify friends on target [%s:%s]', target:GetRealm():GetName(), target:GetFaction():GetName())
        end
    end

    if(#links == 0) then
        return
    end

    -- Now that we know we need to send a BNet whisper, time to split the message into packets
    -- Split once and then message all the targets
    local messageData = XFG:EncodeBNetMessage(inMessage, true)
    local packets = self:SegmentMessage(messageData, inMessage:GetKey(), XFG.Settings.Network.BNet.PacketSize)
    self:Add(inMessage:GetKey())

    -- Make sure all packets go to each target
    for _, friend in pairs (links) do
        try(function ()
            for index, packet in ipairs (packets) do
                XFG:Debug(ObjectName, 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', friend:GetName(), friend:GetGameID(), index, #packets, XFG.Settings.Network.Message.Tag.BNET, strlen(packet))
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                XFG.Lib.BCTL:BNSendGameData('NORMAL', XFG.Settings.Network.Message.Tag.BNET, packet, _, friend:GetGameID())
                XFG.Metrics:Get(XFG.Settings.Metric.BNetSend):Increment()
            end
            inMessage:RemoveTarget(friend:GetTarget())
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
end
--#endregion

--#region Receive
function BNet:DecodeMessage(inEncodedMessage)
    return XFG:DecodeBNetMessage(inEncodedMessage)
end

function BNet:BNetReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    try(function ()
        -- Even though these may be part of a message, it still counts as a network transaction
        XFG.Metrics:Get(XFG.Settings.Metric.BNetReceive):Increment()
        XFG.Metrics:Get(XFG.Settings.Metric.Messages):Increment()
        -- People can only whisper you if friend, so if you got a whisper you need to check friends cache
        if(not XFG.Friends:ContainsByGameID(tonumber(inSender))) then
            XFG.Friends:CheckFriends()
        end

        -- If you get it from BNet, they should be in your friend list and obviously they are running addon
        if(XFG.Friends:ContainsByGameID(tonumber(inSender))) then
            local friend = XFG.Friends:GetByGameID(tonumber(inSender))
            if(friend ~= nil) then
                friend:IsRunningAddon(true)
                friend:CreateLink()
                if(inEncodedMessage == 'PING') then
                    XFG:Debug(ObjectName, 'Received ping from [%s]', friend:GetTag())
                elseif(inEncodedMessage == 'RE:PING') then
                    XFG:Debug(ObjectName, '[%s] Responded to ping', friend:GetTag())
                end
            end
        end
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)

    try(function ()
        if(inEncodedMessage == 'PING') then
            XFG.Lib.BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'RE:PING', _, inSender)
            XFG.Metrics:Get(XFG.Settings.Metric.BNetSend):Increment()
            return
        elseif(inEncodedMessage == 'RE:PING') then
            return
        end
        XFG.Mailbox.BNet:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (inErrorMessage)
        XFG:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion