local XFG, G = unpack(select(2, ...))
local ObjectName = 'Outbox'
local LogCategory = 'NOutbox'

Outbox = {}

function Outbox:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
    self._LocalChannel = nil

    return _Object
end

function Outbox:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Outbox:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Outbox:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _LocalChannel (" .. type(self._LocalChannel) .. ")")
    if(self._LocalChannel ~= nil) then
        self._LocalChannel:Print()
    end
end

function Outbox:GetKey()
    return self._Key
end

function Outbox:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
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
    return self:HasLocalChannel() == false
end

function Outbox:Send(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
    if(inMessage:IsInitialized() == false) then
		-- Review: double check this isn't overriding the timestamp of the message
        inMessage:Initialize()
    end

    XFG:Debug(LogCategory, "Sending message")
    inMessage:ShallowPrint()

    -- If you messaged all possible realm/faction combinations, can switch to local broadcast
    if(inMessage:GetType() == XFG.Settings.Network.Type.BROADCAST or inMessage:GetType() == XFG.Settings.Network.Type.BNET) then
        XFG.BNet:Send(inMessage)
        -- If targets remain, pick X number of links to request them to bnet for you
        if(inMessage:HasTargets() and not inMessage:HasNodes()) then
            local _CandidateCount = XFG.Nodes:GetCandidateCount()
            if(_CandidateCount <= XFG.Settings.Network.BNet.Link.CandidateCount) then
                for _, _Node in XFG.Nodes:CandidateIterator() do
                    inMessage:AddNode(_Candidate)
                end
            else
                while(inMessage:GetNodeCount() < XFG.Settings.Network.BNet.Link.CandidateCount) do
                    local _Candidate = XFG.Nodes:GetRandomCandidate()
                    if(not inMessage:ContainsNode(_Candidate:GetKey())) then
                        inMessage:AddNode(_Candidate)
                    end
                end
            end

        -- If all bnet targets are accounted for, switch to local only
        elseif(not inMessage:HasTargets() and inMessage:GetType() == XFG.Settings.Network.Type.BROADCAST) then
            XFG:Debug(LogCategory, "Successfully sent to all BNet targets, switching to local broadcast so others know not to BNet")
            inMessage:RemoveAllNodes()
            inMessage:SetType(XFG.Settings.Network.Type.LOCAL)
        end
    end

    -- If we were only supposed to do BNet, we're done
    if(inMessage:GetType() == XFG.Settings.Network.Type.BNET) then
        return
    end

    local _OutgoingData = XFG:EncodeMessage(inMessage, true)
    self:BroadcastLocally(_OutgoingData) 
end

function Outbox:BroadcastLocally(inData)
    if(self:HasLocalChannel()) then
        -- Most addons use guild or raid chat, because were trying to hit multiple guilds on the same faction side need an actual channel
        local _Channel = self:GetLocalChannel()
        XFG:Debug(LogCategory, "Broadcasting on channel [%s] with tag [%s]", _Channel:GetShortName(), XFG.Settings.Network.Message.Tag.LOCAL)
        XFG:SendCommMessage(XFG.Settings.Network.Message.Tag.LOCAL, inData, "CHANNEL", _Channel:GetID())
    end
end

function Outbox:BroadcastUnitData(inUnitData, inSubject)
    assert(type(inUnitData) == 'table' and inUnitData.__name ~= nil and inUnitData.__name == 'Unit', "argument must be Unit object")
	if(inSubject == nil) then inSubject = XFG.Settings.Network.Message.Subject.DATA end
    -- Update the last sent time, dont need to heartbeat for awhile

    if(inUnitData:IsPlayer()) then
        local _EpochTime = GetServerTime()
        if(XFG.Player.LastBroadcast > _EpochTime - XFG.Settings.Player.MinimumHeartbeat) then 
            XFG:Debug(LogCategory, 'Not sending broadcast, its been too recent')
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