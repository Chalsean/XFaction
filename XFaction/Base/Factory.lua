local XFG, G = unpack(select(2, ...))
local ObjectName = 'Factory'

local ServerTime = GetServerTime

Factory = ObjectCollection:newChildConstructor()

function Factory:new()
    local _Object = Factory.parent.new(self)
    _Object.__name = ObjectName
    _Object._CheckedIn = nil
    _Object._CheckedInCount = 0
    _Object._CheckedOut = nil
    _Object._CheckedOutCount = 0
    return _Object
end

function Factory:newChildConstructor()
    local _Object = Factory.parent.new(self)
    _Object.__name = ObjectName
    _Object.parent = self
    _Object._CheckedIn = nil
    _Object._CheckedInCount = 0
    _Object._CheckedOut = nil
    _Object._CheckedOutCount = 0
    return _Object
end

function Factory:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function Factory:ParentInitialize()
    self:SetKey(math.GenerateUID())
    self._Objects = {}
    self._CheckedIn = {}
    self._CheckedOut = {}
end

function Factory:Print()
    if(XFG.Debug) then
        XFG:DoubleLine(self:GetObjectName())
        XFG:Debug(self:GetObjectName(), '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
        XFG:Debug(self:GetObjectName(), '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
        XFG:Debug(self:GetObjectName(), "  _CheckedInCount (" .. type(self._CheckedInCount) .. "): ".. tostring(self._CheckedInCount))
        XFG:Debug(self:GetObjectName(), "  _CheckedOutCount (" ..type(self._CheckedOutCount) .. "): ".. tostring(self._CheckedOutCount))
        for _Key, _Object in self:CheckedInIterator() do
            XFG:Debug(self:GetObjectName(), 'CheckedIn')
            _Object:Print()
        end
        for _Key, _Object in self:CheckedOutIterator() do
            XFG:Debug(self:GetObjectName(), 'CheckedOut')
            _Object:Print()
        end
    end
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

function Factory:Pop()
    assert(type(inKey) == 'string' or inKey == nil, 'argument must be string or nil value')
    local _CurrentTime = ServerTime()
    for _, _Object in self:CheckedInIterator() do
        _Object:SetFactoryTime(_CurrentTime)
        self._CheckedIn[_Object:GetFactoryKey()] = nil
        self._CheckedInCount = self._CheckedInCount - 1
        self._CheckedOut[_Object:GetFactoryKey()] = _Object
        self._CheckedOutCount = self._CheckedOutCount + 1
        return _Object
    end

    local _NewObject = self:NewObject()
    _NewObject:SetFactoryKey(math.GenerateUID())
    _NewObject:SetFactoryTime(_CurrentTime)
    self._CheckedOut[_NewObject:GetFactoryKey()] = _NewObject
    self._CheckedOutCount = self._CheckedOutCount + 1

    return _NewObject
end

function Factory:Push(inObject)
    if(inObject == nil) then return end
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
    if(self:IsLoaned(inObject:GetFactoryKey())) then
        self._CheckedOut[inObject:GetFactoryKey()] = nil
        self._CheckedOutCount = self._CheckedOutCount - 1
        inObject:FactoryReset()
        inObject:SetFactoryTime(ServerTime())
        self._CheckedIn[inObject:GetFactoryKey()] = inObject
        self._CheckedInCount = self._CheckedInCount + 1         
    end
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