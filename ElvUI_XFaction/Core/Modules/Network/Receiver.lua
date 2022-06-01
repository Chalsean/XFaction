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

        -- Technically this should be with the other handlers but wanted to keep the receiving logic together
        XFG:RegisterEvent('BN_CHAT_MSG_ADDON', self.ReceiveMessage)
        XFG:Info(LogCategory, "Registered for BN_CHAT_MSG_ADDON events")
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

-- Channel, whisper and BNet traffic is received by this function
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

    -- Ignore if it's your own message
    -- Due to startup timing, use GUID directly rather than from Unit object
	if(_Message:GetFrom() == XFG.Player.GUID) then
        return
	end   

    -- Have you seen this message before?
    if(XFG.Network.Mailbox:Contains(_Message:GetKey())) then
        XFG:Debug(LogCategory, "This message has already been processed %s", _Message:GetKey())
        return
    else
        XFG.Network.Mailbox:AddMessage(_Message)
    end
      
    _Message:Print() 

    -- If sent via BNet, broadcast to your local realm
    if(inMessageTag == XFG.Network.Message.Tag.BNET) then
        _Message:SetType(XFG.Network.Type.LOCAL)
        XFG.Network.Sender:SendMessage(_Message)

    -- If not sent via BNet but is flagged for broadcast, forward to BNet
    elseif(_Message:GetType() == XFG.Network.Type.BROADCAST) then
        _Message:SetType(XFG.Network.Type.BNET)
        XFG.Network.Sender:SendMessage(_Message, true)
    end

    -- Process GUILD_CHAT message
    if(_Message:GetSubject() == XFG.Network.Message.Subject.GUILD_CHAT) then
        -- For alpha testing, only Proudmoore so just need to check faction
        local _Faction = _Message:GetFaction()
        if(_Faction:Equals(XFG.Player.Unit:GetFaction()) == false) then
            -- Visual sugar to make it appear as if the message came through the channel
            XFG.Frames.Chat:DisplayChat(XFG.Frames.ChatType.CHANNEL, _Message)
        end
        return
    end

    -- Process LOGOUT message
    if(_Message:GetSubject() == XFG.Network.Message.Subject.LOGOUT) then
        XFG.Confederate:RemoveUnit(_Message:GetFrom())
        return
    end

    -- Process DATA/LOGIN messages
    if(_Message:GetSubject() == XFG.Network.Message.Subject.DATA or _Message:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
        local _UnitData = _Message:GetData()
        _UnitData:IsPlayer(false)
        if(XFG.Confederate:AddUnit(_UnitData)) then
            XFG:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
            DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
        end

        if(_Message:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
            -- Player has just logged in, whisper back latest info if same faction
            local _UnitFaction = _UnitData:GetFaction()
            if(_UnitFaction:Equals(XFG.Player.Unit:GetFaction())) then
                XFG.Network.Sender:WhisperUnitData(_Message:GetFrom(), XFG.Player.Unit)

            -- If opposite faction, broadcast to trigger BNet communication
            else
                XFG.Network.Sender:BroadcastUnitData(XFG.Player.Unit)
            end
        end
    end
end
