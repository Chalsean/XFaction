local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Message'
local LogCategory = 'NMessage'

Message = {}

function Message:new(inObject)
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
        self._To = nil
        self._From = nil
        self._FromGUID = nil
        self._Type = nil
        self._Subject = nil
        self._EpochTime = nil
        self._Flags = nil
        self._LineID = nil
        self._Faction = nil
        self._Data = nil
        self._Initialized = false
    end

    return Object
end

function Message:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Message:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        self:SetFrom(CON.Player.Unit:GetKey())
        self:SetFaction(CON.Player.Faction)
        self:SetTimeStamp(GetServerTime())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Message:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    CON:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    CON:Debug(LogCategory, "  _FromGUID (" ..type(self._FromGUID) .. "): ".. tostring(self._FromGUID))
    CON:Debug(LogCategory, "  _Flags (" ..type(self._Flags) .. "): ".. tostring(self._Flags))
    CON:Debug(LogCategory, "  _LineID (" ..type(self._LineID) .. "): ".. tostring(self._LineID))
    CON:Debug(LogCategory, "  _Faction (" ..type(self._Faction) .. "): ".. tostring(self._Faction))
    CON:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    CON:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    CON:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    CON:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    CON:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function Message:GetKey()
    return self._Key
end

function Message:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Message:GetTo()
    return self._To
end

function Message:SetTo(inTo)
    assert(type(inTo) == 'string')
    self._To = inTo
    return self:GetTo()
end

function Message:GetFrom()
    return self._From
end

function Message:SetFrom(inFrom)
    assert(type(inFrom) == 'string')
    self._From = inFrom
    return self:GetFrom()
end

function Message:GetType()
    return self._Type
end

function Message:SetType(inType)
    assert(type(inType) == 'string')
    self._Type = inType
    return self:GetType()
end

function Message:GetSubject()
    return self._Subject
end

function Message:SetSubject(inSubject)
    assert(type(inSubject) == 'string')
    self._Subject = inSubject
    return self:GetSubject()
end

function Message:GetTimeStamp()
    return self._EpochTime
end

function Message:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self._EpochTime = inEpochTime
    return self:GetTimeStamp()
end

function Message:GetData()
    return self._Data
end

function Message:SetData(inData)
    self._Data = inData
    return self:GetData()
end

function Message:GetFromGUID()
    return self._FromGUID
end

function Message:SetFromGUID(inFromGUID)
    assert(type(inFromGUID) == 'string')
    self._FromGUID = inFromGUID
    return self:GetFromGUID()
end

function Message:GetFlags()
    return self._Flags
end

function Message:SetFlags(inFlags)
    assert(type(inFlags) == 'string')
    self._Flags = inFlags
    return self:GetFlags()
end

function Message:GetLineID()
    return self._LineID
end

function Message:SetLineID(inLineID)
    assert(type(inLineID) == 'number')
    self._LineID = inLineID
    return self:GetLineID()
end

function Message:GetFaction()
    return self._Faction
end

function Message:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end