local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'BNet'

XFC.BNet = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.BNet:new()
    local object = XFC.BNet.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.BNet:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        XFO.Events:Add({
            name = 'BNetMessage', 
            event = 'BN_CHAT_MSG_ADDON', 
            callback = XFO.BNet.CallbackReceive, 
            instance = true
        })        

        XF.Timers:Add({
            name = 'Ping', 
            delta = XF.Settings.Network.BNet.Ping.Timer, 
            callback = XFO.BNet.CallbackPingFriends, 
            repeater = true, 
            instance = true
        })

        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Methods
function XFC.BNet:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')

    -- Before we do work, lets make sure there are targets and we can message those targets
    local links = {}
    for _, target in pairs(inMessage:GetTargets()) do
        local friends = {}
        for _, friend in XF.Friends:Iterator() do
            if(target:Equals(friend:GetTarget()) and
              -- At the time of login you may not have heard back on pings yet, so just broadcast
              (friend:IsRunningAddon() or inMessage:Subject() == XF.Enum.Message.LOGIN)) then
                friends[#friends + 1] = friend
            end
        end

        -- You should only ever have to message one addon user per target
        local friendCount = table.getn(friends)
        if(friendCount > 0) then
            local randomNumber = math.random(1, friendCount)
            links[#links + 1] = friends[randomNumber]
        else
            XF:Debug(self:ObjectName(), 'Unable to identify friends on target [%s:%s]', target:GetRealm():Name(), target:GetFaction():Name())
        end
    end

    if(#links == 0) then
        return
    end

    -- Now that we know we need to send a BNet whisper, time to split the message into packets
    -- Split once and then message all the targets
    local data = inMessage:Serialize(XF.Enum.Tag.BNET)
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.BNet.PacketSize)
    XFO.Mailbox:Add(inMessage:Key())

    -- Make sure all packets go to each target
    for _, friend in pairs (links) do
        try(function ()
            for index, packet in ipairs (packets) do
                XF:Debug(self:ObjectName(), 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', friend:Name(), friend:GetGameID(), index, #packets, XF.Enum.Tag.BNET, strlen(packet))
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                XF.Lib.BCTL:BNSendGameData('NORMAL', XFO.Tags:GetRandomTag(), packet, _, friend:GetGameID())
                XF.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
            end
            inMessage:RemoveTarget(friend:GetTarget())
        end).
        catch(function (err)
            XF:Warn(self:ObjectName(), err)
        end)
    end
end

function XFC.BNet:DecodeMessage(inEncodedMessage)
    return XF:DecodeBNetMessage(inEncodedMessage)
end

function XFC.BNet:CallbackReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XFO.BNet
    -- try(function ()
    --     -- People can only whisper you if friend, so if you got a whisper you need to check friends cache
    --     if(not XF.Friends:ContainsByGameID(tonumber(inSender))) then
    --         XF.Friends:CheckFriends()
    --     end

    --     -- If you get it from BNet, they should be in your friend list and obviously they are running addon
    --     if(XF.Friends:ContainsByGameID(tonumber(inSender))) then
    --         local friend = XF.Friends:GetByGameID(tonumber(inSender))
    --         if(friend ~= nil) then
    --             friend:IsRunningAddon(true)
    --             friend:CreateLink()
    --             if(inEncodedMessage:sub(1, 4) == 'PING') then
    --                 XF:Debug(self:ObjectName(), 'Received ping from [%s]', friend:GetTag())
    --             elseif(inEncodedMessage:sub(1,7) == 'RE:PING') then
    --                 XF:Debug(self:ObjectName(), '[%s] Responded to ping', friend:GetTag())
    --             end
    --         end
    --     end
    -- end).
    -- catch(function (err)
    --     XF:Warn(self:ObjectName(), err)
    -- end)

    try(function ()
        if(inEncodedMessage:sub(1, 4) == 'PING') then
            XF.Lib.BCTL:BNSendGameData('ALERT', XFO.Tags:GetRandomTag(), 'RE:PING', _, inSender)
            XF.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
        elseif(inEncodedMessage:sub(1,7) ~= 'RE:PING') then
            XFO.PostOffice:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)    
        end        
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.BNet:CallbackPingFriends()
    local self = XFO.BNet
    try(function()
        for _, friend in XFO.Friends:Iterator() do
            if(not friend:IsLinked() and friend:CanLink()) then
                XF:Debug(self:ObjectName(), 'Sending ping to [%s]', friend:Tag())
                XF.Lib.BCTL:BNSendGameData('ALERT', XFO.Tags:GetRandomTag(), 'PING', _, friend:GameID())
                XF.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
            end
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion