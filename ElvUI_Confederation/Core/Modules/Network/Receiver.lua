local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Receiver'
local LogCategory = 'NReceiver'

Receiver = {}

function Receiver:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Key = nil
        self._Initialized = false
    end

    return Object
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
        CON:Info(LogCategory, "Registering to receive [%s] messages", CON.Network.Message.Tag)
        CON:RegisterComm(CON.Network.Message.Tag, function(inMessageType, inMessage, inDistribution, inSender) 
                                                       CON.Network.Receiver:ReceiveMessage(inMessageType, inMessage, inDistribution, inSender)
                                                  end)
        CON:RegisterEvent('BN_CHAT_MSG_ADDON', self.CallbackBNetMessage)
        CON:Info(LogCategory, "Registered for BN_CHAT_MSG_ADDON events")
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Receiver:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Receiver:GetKey()
    return self._Key
end

function Receiver:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Receiver:ReceiveMessage(inMessageType, inEncodedMessage, inDistribution, inSender)
	
	--CON:Debug(LogCategory, "Message received [%s][%s][%s]", inMessageType, inDistribution, inSender)
    local _Message = CON:DecodeMessage(inEncodedMessage)
    
    -- Ignore if it's your own message
	if(_Message:GetFrom() == CON.Player.Unit:GetKey()) then
		return
	end

    -- Ignore if it was not intended for you
    if(_Message:GetTo() ~= nil and _Message:GetTo() ~= CON.Player.Unit:GetKey()) then
        return
    end

    if(_Message:GetSubject() == CON.Network.Message.Subject.DATA) then
        self:ProcessDataMessage(_Message)
    end
end

function Receiver:ProcessDataMessage(inMessage)

    local _UnitData = inMessage:GetData()

	-- It's about you, sender needs current information
	if(_UnitData:GetKey() == CON.Player.Unit:GetKey()) then
        CON:Debug(LogCategory, "Message is about player, sender needs current info")
        inMessage:SetTo(inMessage:GetFrom())
        inMessage:SetFrom(CON.Player.Unit:GetKey())
        inMessage:SetType(CON.Network.Type.WHISPER)
        inMessage:SetData(CON.Player.Unit)        
        CON.Network.Sender:SendMessage(inMessage)
		return
	end

	-- -- Process if coming from the Unit themselves
	if(_UnitData:GetKey() == inMessage:GetFrom()) then
		if(CON.Confederate:AddUnit(_UnitData)) then
			CON:Info(LogCategory, format("Updated unit [%s] information based on message received", _UnitData:GetUnitName()))
		end
		return
	end

	-- Process if you've never heard of this unit before
	if(CON.Confederate:ContainsUnit(_UnitData:GetKey()) == false) then
		if(CON.Confederate:AddUnit(_UnitData)) then
			CON:Info(LogCategory, format("Updated unit [%s] information based on message received", _UnitData:GetUnitName()))
		end
		return
	end

	-- Ignore if Unit is known to be running addon and it's not coming from Unit themselves
    local _CachedUnitData = CON.Confederate:GetUnit(_UnitData:GetKey())
	if(_UnitData.Online == true and _CachedUnitData:IsRunningAddon() == true) then
		return
	end

	-- Ignore if same realm/guild and unit is not running addon
	if(_UnitData:GetRealmName() == _CachedUnitData:GetRealmName() and 
       _UnitData:GetGuildName() == _CachedUnitData:GetGuildName() and
       _CachedUnitData:IsRunningAddon() == false) then
		return
	end

	-- -- If passed all above checks, process message
	if(CON.Confederate:AddUnit(_UnitData)) then
		CON:Info(LogCategory, "Updated unit [%s] information based on message received", _UnitData:GetUnitName())
	end
end

function Receiver:CallbackBNetMessage(inTag, inEncodedMessage, inType, inSenderID)
    if(inTag == CON.Network.Message.Tag) then
        CON:Debug(LogCategory, "Received BNet communication [%s][%s][%d]", inTag, inType, inSenderID)
    end
end