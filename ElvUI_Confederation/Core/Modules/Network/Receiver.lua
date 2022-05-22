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
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Receiver:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    self._ReamChannel:Print()
end

function Receiver:GetKey()
    return self._Key
end

function Receiver:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Receiver:ReceiveMessage(inMessageType, inMessage, inDistribution, inSender)
	
	CON:Debug(LogCategory, "Message received [%s][%s][%s]", inMessageType, inDistribution, inSender)
    local _Message = CON:DecodeMessage(inMessage)
    _Message:Print()
    local _UnitData = _Message:GetData()
    _UnitData:Print()

	-- if(MessageType == DB.Network.Message.UnitData) then
	-- 	ProcessDataMessage(Message, Sender)
	-- elseif(MessageType == DB.Network.Message.Status) then
	-- 	ProcessStatusMessage(Message, Sender)
	-- else
	-- 	CON:Warning(LogCategory, "Received unknown message type [%s] from [%s] over [%s]", MessageType, Sender, Distribution)
	-- end	
end