local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'PingMessage'
local LogCategory = 'NPMessage'

PingMessage = {}

function PingMessage:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    
    self._Key = nil
    self._To = nil
    self._From = nil
    self._EpochTime = nil
    self._Initialized = false

    return _Object
end

function PingMessage:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function PingMessage:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        self:SetFrom(XFG.Player.Unit:GetKey())
        self:SetTimeStamp(GetServerTime())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function PingMessage:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function PingMessage:GetKey()
    return self._Key
end

function PingMessage:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function PingMessage:GetTo()
    return self._To
end

function PingMessage:SetTo(inTo)
    assert(type(inTo) == 'string')
    self._To = inTo
    return self:GetTo()
end

function PingMessage:GetFrom()
    return self._From
end

function PingMessage:SetFrom(inFrom)
    assert(type(inFrom) == 'string')
    self._From = inFrom
    return self:GetFrom()
end

function PingMessage:GetTimeStamp()
    return self._EpochTime
end

function PingMessage:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self._EpochTime = inEpochTime
    return self:GetTimeStamp()
end