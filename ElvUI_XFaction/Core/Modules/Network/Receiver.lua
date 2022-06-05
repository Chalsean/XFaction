local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'Receiver'
local LogCategory = 'NReceiver'
local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

Receiver = {}

function Receiver:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false

    return _Object
end

function Receiver:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Receiver:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        XFG:Info(LogCategory, "Registering to receive [%s] messages", XFG.Network.Message.Tag.LOCAL)
        XFG:RegisterComm(XFG.Network.Message.Tag.LOCAL, function(inMessageType, inMessage, inDistribution, inSender) 
                                                           XFG.Network.Receiver:ReceiveMessage(inMessageType, inMessage, inDistribution, inSender)
                                                        end)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Receiver:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Receiver:GetKey()
    return self._Key
end

function Receiver:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

-- Channel and whisper traffic is received by this function
-- BNet traffic is in the BNet class
function Receiver:ReceiveMessage(inMessageTag, inEncodedMessage, inDistribution, inSender)

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

    local _Message = XFG:DecodeMessage(inEncodedMessage)
    self:ProcessMessage(_Message)
end

function Receiver:ProcessMessage(inMessage)
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
        XFG:Debug(LogCategory, "got here")
        local _UnitData = XFG:DeserializeUnitData(inMessage:GetData())
        inMessage:SetData(_UnitData)
    end
      
    inMessage:ShallowPrint()

    -- If there are still BNet targets remaining and came locally, forward to your own BNet targets
    if(inMessage:HasTargets() and inMessage:GetType() == XFG.Network.Message.Tag.LOCAL) then
        XFG:Debug(LogCategory, "got here 1")
        inMessage:SetType(XFG.Network.Type.BNET)
        XFG.Network.Sender:SendMessage(inMessage)

    -- If there are still BNet targets remaining and came via BNet, broadcast
    elseif(inMessage:HasTargets() and inMessageTag == XFG.Network.Message.Tag.BNET) then
        XFG:Debug(LogCategory, "got here 2")
        inMessage:SetType(XFG.Network.Type.BROADCAST)
        XFG.Network.Sender:SendMessage(inMessage)

    -- If came via BNet and no more targets, message locally only
    elseif(inMessage:HasTargets() == false and inMessageTag == XFG.Network.Message.Tag.BNET) then
        XFG:Debug(LogCategory, "got here 3")
        inMessage:SetType(XFG.Network.Type.LOCAL)
        XFG.Network.Sender:SendMessage(inMessage)
    end

    -- Process guild chat message
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.GCHAT) then
        -- For alpha testing, only Proudmoore so just need to check faction
        local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
        local _Faction = _Guild:GetFaction()
        if(_Faction:Equals(XFG.Player.Unit:GetFaction()) == false) then
            -- Visual sugar to make it appear as if the message came through the channel
            XFG.Frames.Chat:DisplayChat(XFG.Frames.ChatType.CHANNEL, inMessage)
        end
        return
    end

    -- Display system message that unit has logged on/off
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT or
    inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        local _Guild = XFG.Guilds:GetGuildByID(inMessage:GetGuildID())
        if(XFG.Player.Realm:Equals(_Guild:GetRealm()) == false or XFG.Player.Guild:Equals(_Guild) == false) then
            XFG.Frames.System:DisplaySystemMessage(inMessage)
        end
    end

    if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        XFG.Confederate:RemoveUnit(inMessage:GetFrom())
        DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
        return
    end

    -- Process DATA/LOGIN messages
    if(inMessage:GetSubject() == XFG.Network.Message.Subject.DATA or inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        local _UnitData = inMessage:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Confederate:AddUnit(_UnitData)) then
            XFG:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
            DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
        end

        -- If unit has just logged in, reply with latest information
        if(inMessage:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
            -- Whisper back if same faction
            local _UnitFaction = _UnitData:GetFaction()
            if(_UnitFaction:Equals(XFG.Player.Unit:GetFaction())) then
                XFG.Network.Sender:WhisperUnitData(inMessage:GetFrom(), XFG.Player.Unit)

            -- If opposite faction, broadcast to trigger BNet communication
            else
                XFG.Network.Sender:BroadcastUnitData(XFG.Player.Unit)
            end
        end
    end
end