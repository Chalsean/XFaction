local XFG, G = unpack(select(2, ...))

Outbox = Object:newChildConstructor()

function Outbox:new()
    local _Object = Outbox.parent.new(self)
    _Object.__name = 'Outbox'
    _Object._LocalChannel = nil
    return _Object
end

function Outbox:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), "  _LocalChannel (" .. type(self._LocalChannel) .. ")")
    if(self._LocalChannel ~= nil) then
        self._LocalChannel:Print()
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

    XFG:Debug(self:GetObjectName(), 'Attempting to send message')
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
            XFG:Debug(self:GetObjectName(), "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:SetType(XFG.Settings.Network.Type.LOCAL)        
        end
    end

    local _OutgoingData = XFG:EncodeMessage(inMessage, true)
    -- Whisper to same realm/faction player
    if(inMessage:GetType() == XFG.Settings.Network.Type.WHISPER) then 
        XFG:Debug(self:GetObjectName(), 'Whispering [%s] with tag [%s]', inMessage:GetTo(), XFG.Settings.Network.Message.Tag.LOCAL)
        XFG:SendCommMessage(XFG.Settings.Network.Message.Tag.LOCAL, _OutgoingData, 'WHISPER', inMessage:GetTo())
    -- Broadcast on same realm/faction channel for multiple players
    elseif(self:HasLocalChannel()) then
        local _Channel = self:GetLocalChannel()
        XFG:Debug(self:GetObjectName(), 'Broadcasting on channel [%s] with tag [%s]', _Channel:GetName(), XFG.Settings.Network.Message.Tag.LOCAL)
        XFG:SendCommMessage(XFG.Settings.Network.Message.Tag.LOCAL, _OutgoingData, 'CHANNEL', _Channel:GetID())
        XFG.Metrics:GetObject(XFG.Settings.Metric.ChannelSend):Increment()
    end
end

function Outbox:BroadcastUnitData(inUnitData, inSubject)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
	if(inSubject == nil) then inSubject = XFG.Settings.Network.Message.Subject.DATA end
    -- Update the last sent time, dont need to heartbeat for awhile
    if(inUnitData:IsPlayer()) then
        local _EpochTime = GetServerTime()
        if(XFG.Player.LastBroadcast > _EpochTime - XFG.Settings.Player.MinimumHeartbeat) then 
            XFG:Debug(self:GetObjectName(), 'Not sending broadcast, its been too recent')
            return 
        end
        inUnitData:SetTimeStamp(_EpochTime)
        XFG.Player.LastBroadcast = inUnitData:GetTimeStamp()
    end
    local _Message = Message:new()
    _Message:Initialize()
    _Message:SetFrom(XFG.Player.Unit:GetKey())
    _Message:SetType(XFG.Settings.Network.Type.BROADCAST)
    _Message:SetSubject(inSubject)
    _Message:SetData(inUnitData)
    self:Send(_Message)
end

function Outbox:WhisperUnitData(inTo, inUnitData)
    assert(type(inTo) == 'string')
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', 'argument must be Unit object')
    local _Message = Message:new()
    _Message:Initialize()
    _Message:SetTo(inTo)
    _Message:SetFrom(XFG.Player.Unit:GetKey())
    _Message:SetType(XFG.Settings.Network.Type.WHISPER)
    _Message:SetSubject(XFG.Settings.Network.Message.Subject.DATA)
    _Message:SetData(inUnitData)
    self:Send(_Message)
end
