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

        XFO.Timers:Add({
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
function XFC.BNet:Whisper(inMessage, inFriend)
    assert(type(inMessage) == 'table' and inMessage.__name == 'Message')
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')

    local tag = XFO.Tags:GetRandomTag()
    local data = inMessage:Serialize(XF.Enum.Tag.BNET)
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.BNet.PacketSize)
    XFO.Mailbox:Add(inMessage:Key())

    try(function ()
        for index, packet in ipairs (packets) do
            XF:Debug(self:ObjectName(), 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', inFriend:Name(), inFriend:GameID(), index, #packets, tag, strlen(packet))
            -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
            XF.Lib.BCTL:BNSendGameData('NORMAL', tag, packet, _, inFriend:GameID())
            XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
        end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.BNet:CallbackReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    local self = XFO.BNet
    try(function ()
        XFO.PostOffice:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end

function XFC.BNet:PingFriend(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')
    XF:Debug(self:ObjectName(), 'Sending ping to [%s]', inFriend:Tag())
    XF.Lib.BCTL:BNSendGameData('ALERT', XFO.Tags:GetRandomTag(), 'PING', _, inFriend:GameID())
    XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment()
end

function XFC.BNet:CallbackPingFriends()
    local self = XFO.BNet
    try(function()
        for _, friend in XFO.Friends:Iterator() do
            if(not friend:IsLinked() and friend:CanLink()) then
                self:PingFriend(friend)
            end
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion