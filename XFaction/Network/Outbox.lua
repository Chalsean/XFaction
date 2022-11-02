local XFG, G = unpack(select(2, ...))
local ObjectName = 'Outbox'

local ServerTime = GetServerTime

Outbox = Object:newChildConstructor()

function Outbox:new()
    local _Object = Outbox.parent.new(self)
    _Object.__name = ObjectName
    _Object._LocalChannel = nil
    return _Object
end

function Outbox:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _LocalChannel (" .. type(self._LocalChannel) .. ")")
        if(self._LocalChannel ~= nil) then
            self._LocalChannel:Print()
        end
    end
end

function Outbox:HasLocalChannel()
    return self._LocalChannel ~= nil
end

function Outbox:GetLocalChannel()
    return self._LocalChannel
end

function Outbox:SetLocalChannel(inChannel)
    assert(type(inChannel) == 'table' and inChannel.__name ~= nil and inChannel.__name == 'Channel', "argument must be Channel object")
    self._LocalChannel = inChannel
    return self:HasLocalChannel()
end

function Outbox:VoidLocalChannel()
    self._LocalChannel = nil
    return not self:HasLocalChannel()
end

function Outbox:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(not XFG.Settings.System.Roster and inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.DATA) then return end
    if(not inMessage:IsInitialized()) then
		-- Review: double check this isn't overriding the timestamp of the message
        inMessage:Initialize()
    end

    XFG:Debug(ObjectName, 'Attempting to send message')
    inMessage:ShallowPrint()

    if(inMessage:GetType() == XFG.Settings.Network.Type.BROADCAST or inMessage:GetType() == XFG.Settings.Network.Type.BNET) then
        XFG.BNet:Send(inMessage)
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

    local _OutgoingData = XFG:EncodeMessage(inMessage, true)
    -- Broadcast on same realm/faction channel for multiple players
    if(self:HasLocalChannel()) then
        local _Channel = self:GetLocalChannel()
        if(XFG.DebugFlag) then
            XFG:Debug(ObjectName, 'Broadcasting on channel [%s] with tag [%s]', _Channel:GetName(), XFG.Settings.Network.Message.Tag.LOCAL)
        end
        XFG:SendCommMessage(XFG.Settings.Network.Message.Tag.LOCAL, _OutgoingData, 'CHANNEL', _Channel:GetID())
        XFG.Metrics:Get(XFG.Settings.Metric.ChannelSend):Increment()
    end
end

function Outbox:BroadcastUnitData(inUnitData, inSubject)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
	if(inSubject == nil) then inSubject = XFG.Settings.Network.Message.Subject.DATA end
    -- Update the last sent time, dont need to heartbeat for awhile
    if(inUnitData:IsPlayer()) then
        local _EpochTime = ServerTime()
        if(XFG.Player.LastBroadcast > _EpochTime - XFG.Settings.Player.MinimumHeartbeat) then 
            XFG:Debug(ObjectName, 'Not sending broadcast, its been too recent')
            return 
        end
        inUnitData:SetTimeStamp(_EpochTime)
        XFG.Player.LastBroadcast = inUnitData:GetTimeStamp()
    end
    local _Message = nil
    try(function ()
        _Message = XFG.Mailbox:Pop()
        _Message:Initialize()
        _Message:SetFrom(XFG.Player.Unit:GetKey())
        _Message:SetType(XFG.Settings.Network.Type.BROADCAST)
        _Message:SetSubject(inSubject)
        _Message:SetData(inUnitData)
        self:Send(_Message)
    end).
    finally(function ()
        XFG.Mailbox:Push(_Message)
    end)
end