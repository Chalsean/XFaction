local XFG, G = unpack(select(2, ...))
-- Odd but scoping globals to local is a performance boost
local LogDebug = XFG.Debug
local LogLine = XFG.SingleLine
local ObjectName = 'Object'

Object = {}

function Object:new()
    local _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Initialized = false
    
    return _Object
end

function Object:newChildConstructor()
    local _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    
    self._Key = nil
    self._Name = nil
    self._Initialized = false

    return _Object
end

function Object:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Object:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

-- So can call parent init in child objects
function Object:ParentInitialize()
    self:SetKey(math.GenerateUID())
end

function Object:Print()
    self:ParentPrint()
end

-- Dynamically building strings is performance hit but this section is only executed if _DebugLog is enabled
function Object:ParentPrint()
    LogLine(ObjectName)
    LogDebug(ObjectName, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    LogDebug(ObjectName, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    LogDebug(ObjectName, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function Object:GetKey()
    return self._Key
end

function Object:SetKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self._Key = inKey
    return self:GetKey()
end

function Object:GetName()
    return self._Name
end

function Object:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Object:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:GetKey() ~= inObject:GetKey()) then return false end
    return true
end

function Object:GetObjectName()
    return self.__name
end
