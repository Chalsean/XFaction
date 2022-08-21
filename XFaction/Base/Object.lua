local XFG, G = unpack(select(2, ...))

Object = {}

function Object:new()
    local _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._FactoryKey = nil
    self._FactoryTime = nil
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
    
    self._FactoryKey = nil
    self._FactoryTime = nil
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
end

-- So can call parent init in child objects
function Object:ParentInitialize()
    self._Key = math.GenerateUID()
end

function Object:Print()
    self:ParentPrint()
end

function Object:ParentPrint()
    if(XFG.DebugFlag) then
        XFG:SingleLine(self:GetObjectName())
        if(self._FactoryKey ~= nil) then
            XFG:Debug(self:GetObjectName(), '  _FactoryKey (' .. type(self._FactoryKey) .. '): ' .. tostring(self._FactoryKey))
        end
        if(self._FactoryTime ~= nil) then
            XFG:Debug(self:GetObjectName(), '  _FactoryTime (' .. type(self._FactoryTime) .. '): ' .. tostring(self._FactoryTime))
        end
        XFG:Debug(self:GetObjectName(), '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
        XFG:Debug(self:GetObjectName(), '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
        XFG:Debug(self:GetObjectName(), '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
    end
end

function Object:GetFactoryKey()
    return self._FactoryKey
end

function Object:SetFactoryKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self._FactoryKey = inKey
end

function Object:GetFactoryTime()
    return self._FactoryTime
end

function Object:SetFactoryTime(inFactoryTime)
    assert(type(inFactoryTime) == 'number')
    self._FactoryTime = inFactoryTime
end

function Object:GetKey()
    return self._Key
end

function Object:SetKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self._Key = inKey
end

function Object:GetName()
    return self._Name
end

function Object:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
end

function Object:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:GetObjectName() ~= inObject:GetObjectName()) then return false end
    if(self:GetKey() ~= inObject:GetKey()) then return false end
    return true
end

function Object:GetObjectName()
    return self.__name
end

function Object:ParentFactoryReset()
    self._Key = nil
    self._Name = nil
    self._Initialized = false
end