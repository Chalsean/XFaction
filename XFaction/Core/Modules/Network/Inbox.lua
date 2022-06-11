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
        XFG:Info(LogCategory, "Registering to receive [%s] messages", XFG.Network.Message.Tag.LOCAL)
        XFG:RegisterComm(XFG.Network.Message.Tag.LOCAL, function(inMessageType, inMessage, inDistribution, inSender) 
                                                           XFG.Network.Inbox:Receive(inMessageType, inMessage, inDistribution, inSender)
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
    for _, _Tag in pairs (XFG.Network.Message.Tag) do
        if(inMessageTag == _Tag) then
            _AddonTag = true
            break
        end
    end
    if(_AddonTag == false) then
        return
    end

    -- If user has disabled Channel
    if(XFG.Network.Outbox:CanBroadcast() == false) then return end

    local _Message = XFG:DecodeMessage(inEncodedMessage)
    self:Process(_Message, inMessageTag)
end

function Inbox:Process(inMessage, inMessageTag)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than from Unit object
	if(inMessage:GetFrom() == XFG.Player.GUID) then
        return
	end

    -- Have you seen this message before?
    if(XFG.Network.Mailbox:Contains(inMessage:GetKey())) then
        --XFG:Debug(LogCategory, "This message has already been processed %s", inMessage:GetKey())
        return
    else
        XFG.Network.Mailbox:AddMessage(inMessage)
    end

    if(inMessage:HasUnitData()) then
        local _UnitData = XFG:DeserializeUnitData(inMessage:GetData())
        inMessage:SetData(_UnitData)
    end
      
    inMessage:ShallowPrint()

    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessageTag == XFG.Network.Message.Tag.LOCAL) then
        inMessage:SetType(XFG.Network.Type.BNET)
        XFG.Network.Outbox:Send(inMessage)

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessage:HasTargets() and inMessageTag == XFG.Network.Message.Tag.BNET) then
        inMessage:SetType(XFG.Network.Type.BROADCAST)
        XFG.Network.Outbox:Send(inMessage)

    -- If came via BNet and no more targets, message locally only
    elseif(inMessage:HasTargets() == false and inMessageTag == XFG.Network.Message.Tag.BNET) then
        inMessage:SetType(XFG.Network.Type.LOCAL)
        XFG.Network.Outbox:Send(inMessage)
    end

    -- Process guild chat message
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.GCHAT) then
        local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
        if(XFG.Player.Guild:Equals(_Guild) == false) then
            XFG.Frames.Chat:DisplayGuild(inMessage)
        end
        return
    end

    -- Process achievement message
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.ACHIEVEMENT) then
        local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
        if(XFG.Player.Guild:Equals(_Guild) == false) then
            XFG.Frames.Chat:DisplayAchievement(inMessage)
        end
        return
    end

    -- Process link message
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LINK) then
        XFG.Network.BNet.Links:ProcessMessage(inMessage)
        XFG.DataText.Links.Broker:RefreshBroker()
        return
    end

    -- Display system message that unit has logged on/off
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT or inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
        if(XFG.Player.Realm:Equals(_Guild:GetRealm()) == false or XFG.Player.Guild:Equals(_Guild) == false) then
            XFG.Frames.System:Display(inMessage)
        end
    end

    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        XFG.Confederate:RemoveUnit(inMessage:GetFrom())
        XFG.DataText.Guild.Broker:RefreshBroker()
        return
    end

    -- Process DATA/LOGIN messages
    if(inMessage:HasUnitData()) then
        local _UnitData = inMessage:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Confederate:AddUnit(_UnitData)) then
            XFG:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
            XFG.DataText.Guild.Broker:RefreshBroker()
        end

        -- If unit has just logged in, reply with latest information
        if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
            -- Used to whisper back but was running into Blizz API bug, so just broadcast
            XFG.Network.Outbox:BroadcastUnitData(XFG.Player.Unit)
        end
    end
end