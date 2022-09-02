local XFG, G = unpack(select(2, ...))
local ObjectName = 'BNet'

local ServerTime = GetServerTime

BNet = Mailbox:newChildConstructor()

function BNet:new()
    local _Object = BNet.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function BNet:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('BNetMessage', 'BN_CHAT_MSG_ADDON', XFG.Mailbox.BNet.BNetReceive)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function BNet:DecodeMessage(inEncodedMessage)
    return XFG:DecodeBNetMessage(inEncodedMessage)
end

function BNet:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), 'argument must be Message type object')

    -- Before we do work, lets make sure there are targets and we can message those targets
    local _Links = {}
    for _, _Target in pairs(inMessage:GetTargets()) do
        local _Friends = {}
        for _, _Friend in XFG.Friends:Iterator() do
            if(_Target:Equals(_Friend:GetTarget()) and
              -- At the time of login you may not have heard back on pings yet, so just broadcast
              (_Friend:IsRunningAddon() or inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN)) then
                _Friends[#_Friends + 1] = _Friend
            end
        end

        -- You should only ever have to message one addon user per target
        local _FriendCount = table.getn(_Friends)
        if(_FriendCount > 0) then
            local _RandomNumber = math.random(1, _FriendCount)
            _Links[#_Links + 1] = _Friends[_RandomNumber]
        elseif(XFG.DebugFlag) then
            XFG:Debug(ObjectName, 'Unable to identify friends on target [%s:%s]', _Target:GetRealm():GetName(), _Target:GetFaction():GetName())
        end
    end

    if(#_Links == 0) then
        return
    end

    -- Now that we know we need to send a BNet whisper, time to split the message into packets
    -- Split once and then message all the targets
    local _MessageData = nil
    if(inMessage:HasSerialized() and not inMessage:IsDirty()) then
        _MessageData = inMessage:GetSerialized()
    else
        _MessageData = XFG:EncodeBNetMessage(inMessage, true)
    end
    local _Packets = self:SegmentMessage(_MessageData, inMessage:GetKey(), XFG.Settings.Network.BNet.PacketSize)

    -- Make sure all packets go to each target
    for _, _Friend in pairs (_Links) do
        try(function ()
            for _Index, _Packet in ipairs (_Packets) do
                if(XFG.DebugFlag) then
                    XFG:Debug(ObjectName, 'Whispering BNet link [%s:%d] packet [%d:%d] with tag [%s] of length [%d]', _Friend:GetName(), _Friend:GetGameID(), _Index, _TotalPackets, XFG.Settings.Network.Message.Tag.BNET, strlen(_Packet))
                end
                -- The whole point of packets is that this call will only let so many characters get sent and AceComm does not support BNet
                XFG.Lib.BCTL:BNSendGameData('NORMAL', XFG.Settings.Network.Message.Tag.BNET, _Packet, _, _Friend:GetGameID())
                XFG.Metrics:Get(XFG.Settings.Metric.BNetSend):Increment()
            end
            inMessage:RemoveTarget(_Friend:GetTarget())
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
        end)
    end
end

function BNet:BNetReceive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    -- If not a message from this addon, ignore
    local _AddonTag = false
    for _, _Tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(not _AddonTag) then
        return
    end

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
            local _Friend = XFG.Friends:GetByGameID(tonumber(inSender))
            if(_Friend ~= nil) then
                _Friend:SetDateTime(ServerTime())
                _Friend:IsRunningAddon(true)
                _Friend:CreateLink()
                if(XFG.DebugFlag) then
                    if(inEncodedMessage == 'PING') then
                        XFG:Debug(ObjectName, 'Received ping from [%s]', _Friend:GetTag())
                    elseif(inEncodedMessage == 'RE:PING') then
                        XFG:Debug(ObjectName, '[%s] Responded to ping', _Friend:GetTag())
                    end
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