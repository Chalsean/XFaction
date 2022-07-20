local XFG, G = unpack(select(2, ...))
local ObjectName = 'Inbox'
local LogCategory = 'NInbox'

Inbox = {}

function Inbox:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false

    return _Object
end

function Inbox:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Inbox:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        XFG:Info(LogCategory, "Registering to receive [%s] messages", XFG.Settings.Network.Message.Tag.LOCAL)
        XFG:RegisterComm(XFG.Settings.Network.Message.Tag.LOCAL, 
                         function(inMessageType, inMessage, inDistribution, inSender) 
                            XFG.Inbox:Receive(inMessageType, inMessage, inDistribution, inSender)
                         end)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Inbox:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Inbox:GetKey()
    return self._Key
end

function Inbox:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

-- Channel and whisper traffic is received by this function
-- BNet traffic is in the BNet class
function Inbox:Receive(inMessageTag, inEncodedMessage, inDistribution, inSender)

    XFG:Debug(LogCategory, "Received message [%s] from [%s] on [%s]", inMessageTag, inSender, inDistribution)

    -- If not a message from this addon, ignore
    local _AddonTag = false
    for _, _Tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(_AddonTag == false) then
        return
    end

    local _Message = nil
    if(pcall(function () _Message = XFG:DecodeMessage(inEncodedMessage) end)) then
        self:Process(_Message, inMessageTag)
    else
        XFG:Warn(LogCategory, 'Failed to decode received message [%s:%s:%s]', inSender, inMessageTag, inDistribution)
    end    
end

function Inbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")

    --========================================
    -- Ignore message
    --========================================

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than from Unit object
	if(inMessage:GetFrom() == XFG.Player.GUID) then
        return
	end

    -- Have you seen this message before?
    if(XFG.Mailbox:Contains(inMessage:GetKey())) then
        --XFG:Debug(LogCategory, "This message has already been processed %s", inMessage:GetKey())
        return
    else
        XFG.Mailbox:AddMessage(inMessage)
    end

    -- Deserialize unit data
    if(inMessage:HasUnitData()) then
        local _UnitData
        if(pcall(function () _UnitData = XFG:DeserializeUnitData(inMessage:GetData()) end)) then
            inMessage:SetData(_UnitData)
            if(_UnitData:HasVersion() == false) then
                _UnitData:SetVersion(inMessage:GetVersion())
            end
        else
            XFG:Warn(LogCategory, 'Failed to decode received unit data [%s]', inMessage:GetFrom())
            return
        end
    end

    inMessage:ShallowPrint()

    --========================================
    -- Forward message
    --========================================

    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XFG.Settings.Network.Message.Tag.LOCAL) then
        -- If there are too many active nodes in the confederate faction, lets try to reduce unwanted traffic by playing a percentage game
        if(XFG.Nodes:GetTargetCount(XFG.Player.Target) > XFG.Settings.Network.BNet.Link.PercentStart) then
            if(math.random(1, 100) <= XFG.Settings.Network.BNet.Link.PercentLevel) then
                XFG:Debug(LogCategory, 'Randomly selected, forwarding message')
                inMessage:SetType(XFG.Settings.Network.Type.BNET)
                XFG.Outbox:Send(inMessage)
            else
                XFG:Debug(LogCategory, 'Not randomly selected, will not forward mesesage')
            end
        else
            XFG:Debug(LogCategory, 'Node count under threshold, forwarding message')
            inMessage:SetType(XFG.Settings.Network.Type.BNET)
            XFG.Outbox:Send(inMessage)
        end        

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessageTag == XFG.Settings.Network.Message.Tag.BNET) then
        if(inMessage:HasTargets()) then
            inMessage:SetType(XFG.Settings.Network.Type.BROADCAST)
        else
            inMessage:SetType(XFG.Settings.Network.Type.LOCAL)
        end
        XFG.Outbox:Send(inMessage)
    end

    --========================================
    -- Process message
    --========================================

    -- Process gchat/achievement messages
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.GCHAT or inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.ACHIEVEMENT) then
        if(not XFG.Player.Guild:Equals(inMessage:GetGuild())) then
            pcall(function() XFG.Frames.Chat:Display(inMessage) end)
        end
        return
    end

    -- Process link message
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LINK) then
        XFG.Links:ProcessMessage(inMessage)
        XFG.DataText.Links:RefreshBroker()
        return
    end

    -- Display system message that unit has logged off
    if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGOUT) then
        -- If own guild, GuildEvent will take care of logout
        -- If own faction/realm, ChannelEvent will take care of logout
        if(not XFG.Player.Realm:Equals(inMessage:GetRealm()) or not XFG.Player.Faction:Equals(inMessage:GetGuild():GetFaction())) then
            XFG.Confederate:RemoveUnit(inMessage:GetFrom())
            XFG.Frames.System:DisplayLogoutMessage(inMessage)
        end
        return
    end

    -- Process DATA/LOGIN messages
    if(inMessage:HasUnitData()) then
        local _UnitData = inMessage:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Confederate:AddUnit(_UnitData)) then
            XFG:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
            XFG.DataText.Guild:RefreshBroker()
        end

        -- If unit has just logged in, reply with latest information
        if(inMessage:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN) then
            -- Display system message that unit has logged on
            if(not XFG.Player.Guild:Equals(_UnitData:GetGuild())) then
                XFG.Frames.System:DisplayLoginMessage(inMessage)
            end
        end
    end
end