local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'BNet'

XFC.BNet = XFC.Mailbox:newChildConstructor()

--#region Constructors
function XFC.BNet:new()
    local object = XFC.BNet.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.BNet:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XF.Enum.Tag.BNET = XFO.Confederate:GetKey() .. 'BNET'
        XFO.Events:Add({name = 'BNetMessage', 
                        event = 'BN_CHAT_MSG_ADDON', 
                        callback = XFO.BNet.BNetReceive, 
                        instance = true})
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Send
function XFC.BNet:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    -- Before we do work, lets make sure there are targets and we can message those targets
    local links = {}
    for _, target in pairs(inMessage:GetTargets()) do
        local friends = {}
        for _, friend in XFO.Friends:Iterator() do
            if(target:Equals(friend:GetTarget()) and
              -- At the time of login you may not have heard back on pings yet, so just broadcast
              (friend:IsRunningAddon() or inMessage:GetSubject() == XF.Enum.Message.LOGIN)) then
                friends[#friends + 1] = friend
            end
        end

        -- You should only ever have to message one addon user per target
        local friendCount = table.getn(friends)
        if(friendCount > 0) then
            local randomNumber = math.random(1, friendCount)
            links[#links + 1] = friends[randomNumber]
        else
            XF:Debug(ObjectName, 'Unable to identify friends on target [%s:%s]', target:GetRealm():GetName(), target:GetFaction():GetName())
        end
    end

    if(#links == 0) then
        return
    end

    -- Now that we know we need to send a BNet whisper, time to split the message into packets
    -- Split once and then message all the targets
    local compressed = inMessage:Compress()
    local messageData = Deflate:EncodeForPrint(compressed)
    local packets = self:SegmentMessage(messageData, inMessage:GetKey(), XF.Settings.Network.BNet.PacketSize)
    self:Add(inMessage:GetKey())

    -- Make sure all packets go to each target
    for _, friend in pairs (links) do
        try(function ()
            for index, packet in ipairs (packets) do
                XF:Debug(ObjectName, 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', friend:GetName(), friend:GetGameID(), index, #packets, XF.Enum.Tag.BNET, strlen(packet))
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                XF.Lib.BCTL:BNSendGameData('NORMAL', XF.Enum.Tag.BNET, packet, _, friend:GetGameID())
                XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
            end
            inMessage:RemoveTarget(friend:GetTarget())
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
        end)
    end
end
--#endregion

--#region Receive
function XFC.BNet:DecodeMessage(inEncodedMessage)
    return XF:DecodeBNetMessage(inEncodedMessage)
end

function XFC.BNet:BNetReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XFO.BNet
    try(function ()
        -- People can only whisper you if friend, so if you got a whisper you need to check friends cache
        if(not XFO.Friends:ContainsByGameID(tonumber(inSender))) then
            XFO.Friends:CheckFriends()
        end

        -- If you get it from BNet, they should be in your friend list and obviously they are running addon
        if(XFO.Friends:ContainsByGameID(tonumber(inSender))) then
            local friend = XFO.Friends:GetByGameID(tonumber(inSender))
            if(friend ~= nil) then
                friend:IsRunningAddon(true)
                friend:CreateLink()
                if(inEncodedMessage:sub(1, 4) == 'PING') then
                    XF:Debug(ObjectName, 'Received ping from [%s]', friend:GetTag())
                elseif(inEncodedMessage:sub(1,7) == 'RE:PING') then
                    XF:Debug(ObjectName, '[%s] Responded to ping', friend:GetTag())
                end
            end
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)

    try(function ()
        if(inEncodedMessage:sub(1, 4) == 'PING') then
            XF.Lib.BCTL:BNSendGameData('ALERT', XF.Enum.Tag.BNET, 'RE:PING', _, inSender)
            XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
        elseif(inEncodedMessage:sub(1,7) ~= 'RE:PING') then
            self:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)    
        end        
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion