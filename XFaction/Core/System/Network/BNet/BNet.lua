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
    local data = inMessage:Encode(true)
    local packets = XFO.PostOffice:SegmentMessage(data, inMessage:Key(), XF.Settings.Network.BNet.PacketSize)
    local priority = (inMessage:IsHighPriority() and 'ALERT') or (inMessage:IsMediumPriority() and 'NORMAL') or 'BULK'

    try(function ()
        for index, packet in ipairs (packets) do
            XF:Debug(self:ObjectName(), 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', inFriend:Name(), inFriend:GameID(), index, #packets, tag, strlen(packet))
            -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
            XF.Lib.BCTL:BNSendGameData(priority, tag, packet, _, inFriend:GameID())
            XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Count(1)
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

function XFC.BNet:SendLogoutMessage(inKey, inFriend)
    assert(type(inKey) == 'string')
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend')
    local tag = XFO.Tags:GetRandomTag()
    local packet = '11' .. inKey .. 'LOGOUT' .. XF.Player.GUID
    XF.Lib.BCTL:BNSendGameData('ALERT', tag, packet, _, inFriend:GameID())
end
--#endregion