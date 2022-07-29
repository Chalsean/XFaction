local XFG, G = unpack(select(2, ...))
local ObjectName = 'Factory'
local LogCategory = 'FFactory'

Factory = {}

function Factory:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    
    self._Key = nil
    self._CheckedIn = nil
    self._CheckedInCount = 0
    self._CheckedOut = nil
    self._CheckedOutCount = 0
    self._Initialized = false

    return _Object
end

function Factory:newChildConstructor()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    
    self._Key = nil
    self._CheckedIn = nil
    self._CheckedInCount = 0
    self._CheckedOut = nil
    self._CheckedOutCount = 0
    self._Initialized = false

    return _Object
end

function Factory:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Factory:Initialize()
    if(not self:IsInitialized()) then
        self:SetKey(math.GenerateUID())
        self._CheckedIn = {}
        self._CheckedOut = {}
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Factory:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _CheckedInCount (" .. type(self._CheckedInCount) .. "): ".. tostring(self._CheckedInCount))
    XFG:Debug(LogCategory, "  _CheckedOutCount (" ..type(self._CheckedOutCount) .. "): ".. tostring(self._CheckedOutCount))
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    for _Key, _Object in self:CheckedInIterator() do
        _Object:Print()
    end
    for _Key, _Object in self:CheckedOutIterator() do
        _Object:Print()
    end
end

function Factory:GetKey()
    return self._Key
end

function Factory:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Factory:CheckedInIterator()
	return next, self._CheckedIn, nil
end

function Factory:CheckedOutIterator()
	return next, self._CheckedOut, nil
end

function Factory:IsLoaned(inKey)
    assert(type(inKey) == 'string')
    return self._CheckedOut[inKey] ~= nil
end

function Factory:IsAvailable(inKey)
    assert(type(inKey) == 'string')
    return self._CheckedIn[inKey] ~= nil
end

function Factory:Remove(inKey)
    if(self:IsAvailable(inKey)) then
        self._CheckedIn[inKey] = nil
        self._CheckedInCount = self._CheckedInCount - 1
    end
end

function Factory:CheckOut()
    assert(type(inKey) == 'string' or inKey == nil, 'argument must be string or nil value')
    local _CurrentTime = GetServerTime()
    for _, _Object in self:CheckedInIterator() do
        _Object:SetFactoryTime(_CurrentTime)
        self._CheckedIn[_Object:GetFactoryKey()] = nil
        self._CheckedInCount = self._CheckedInCount - 1
        self._CheckedOut[_Object:GetFactoryKey()] = _Object
        self._CheckedOutCount = self._CheckedOutCount + 1
        return _Object
    end

    local _NewObject = self:CreateNew()
    _NewObject:SetFactoryKey(math.GenerateUID())
    _NewObject:SetFactoryTime(_CurrentTime)
    self._CheckedOut[_NewObject:GetFactoryKey()] = _NewObject
    self._CheckedOutCount = self._CheckedOutCount + 1

    return _NewObject
end

function Factory:CheckIn(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
    if(self:IsLoaned(inObject:GetFactoryKey())) then
        self._CheckedOut[inObject:GetFactoryKey()] = nil
        self._CheckedOutCount = self._CheckedOutCount - 1
        inObject:FactoryReset()
        local _CurrentTime = GetServerTime()
        inObject:SetFactoryTime(_CurrentTime)
        self._CheckedIn[inObject:GetFactoryKey()] = inObject
        self._CheckedInCount = self._CheckedInCount + 1         
    end
    return self:IsAvailable(inObject:GetFactoryKey())
end

function Factory:Purge(inPurgeTime)
    assert(type(inPurgeTime) == 'number')
    for _, _Object in self:CheckedInIterator() do
        if(_Object:GetFactoryTime() < inPurgeTime) then
            self:Remove(_Object:GetFactoryKey())
        end
    end
    for _, _Object in self:CheckedOutIterator() do
        if(_Object:GetFactoryTime() < inPurgeTime) then
            self:CheckIn(_Object)
        end
    end
end