local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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
        XF.Enum.Tag.BNET = XFO.Confederate:Key() .. 'BNET'

        XF.Events:Add({
            name = 'BNetMessage', 
            event = 'BN_CHAT_MSG_ADDON', 
            callback = XF.Mailbox.BNet.BNetReceive, 
            instance = true
        })

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
        for _, friend in XFO.Friends:Iterator() do
            if(friend:IsLinked() and target:Equals(friend:Target())) then
                friends[#friends + 1] = friend
            end
        end

        -- You should only ever have to message one addon user per target
        local friendCount = table.getn(friends)
        if(friendCount > 0) then
            local randomNumber = math.random(1, friendCount)
            links[#links + 1] = friends[randomNumber]
        else
            XF:Debug(ObjectName, 'Unable to identify friends on target [%s:%s]', target:GetRealm():Name(), target:GetFaction():Name())
        end
    end

    if(#links == 0) then
        return
    end

    -- Now that we know we need to send a BNet whisper, time to split the message into packets
    -- Split once and then message all the targets
    local messageData = XF:EncodeBNetMessage(inMessage, true)
    local packets = self:SegmentMessage(messageData, inMessage:Key(), XF.Settings.Network.BNet.PacketSize)
    self:Add(inMessage:Key())

    -- Make sure all packets go to each target
    for _, friend in pairs (links) do
        try(function ()
            for index, packet in ipairs (packets) do
                XF:Debug(ObjectName, 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', friend:Name(), friend:GameID(), index, #packets, XF.Enum.Tag.BNET, strlen(packet))
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                XF.Lib.BCTL:BNSendGameData('NORMAL', XF.Enum.Tag.BNET, packet, _, friend:GameID())
                XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
            end
            inMessage:RemoveTarget(friend:Target())
        end).
        catch(function (inErrorMessage)
            XF:Warn(ObjectName, inErrorMessage)
        end)
    end
end
--#endregion

--#region Receive
function BNet:DecodeMessage(inEncodedMessage)
    return XF:DecodeBNetMessage(inEncodedMessage)
end

function BNet:BNetReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XF.Mailbox.BNet
    try(function ()
        -- If not a message from this addon, ignore
        if(not self:IsAddonTag(inMessageTag)) then
            return
        end

        -- People can only whisper you if friend and running addon, so if you got a whisper and theyre not in cache, something is wrong
        local friend = XFO.Friends:GetByGameID(tonumber(inSender))
        if(friend == nil) then
            -- Refresh cache and check again
            XFO.Friends:CheckFriends()
            friend = XFO.Friends:GetByGameID(tonumber(inSender))
            if(friend == nil) then
                XF:Error(self:ObjectName(), 'Received BNet whisper from someone not in cache [%s:%d]', inMessageTag, inSender)
            end
        end

        XF:Debug(self:ObjectName(), 'Got BNet whisper from [%s]', friend:Tag())
        -- PING and RE:PING mean a link has been established
        if(inEncodedMessage:sub(1, 4) == 'PING') then
            XF:Debug(self:ObjectName(), 'Received ping from [%s]', friend:Tag())
            friend:IsLinked(true)
            self:RespondPing(friend)
        elseif(inEncodedMessage:sub(1,7) == 'RE:PING') then
            XF:Debug(self:ObjectName(), '[%s] Responded to ping', friend:Tag())
            friend:IsLinked(true)
        -- Otherwise its a normal message that needs to be processed
        else
            self:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function BNet:Ping(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')
    if(XF.Initialized) then
        XF:Debug(self:ObjectName(), 'Sending ping to [%s]', inFriend:Tag())
        XF.Lib.BCTL:BNSendGameData('ALERT', XF.Enum.Tag.BNET, 'PING', _, inFriend:GameID())
        XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment() 
    end
end

function BNet:RespondPing(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')
    if(XF.Initialized) then
        XF:Debug(self:ObjectName(), 'Sending ping response to [%s]', inFriend:Tag())
        XF.Lib.BCTL:BNSendGameData('ALERT', XF.Enum.Tag.BNET, 'RE:PING', _, inFriend:GameID())
        XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment() 
    end
end
--#endregion