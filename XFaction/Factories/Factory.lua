local XFG, G = unpack(select(2, ...))
local ObjectName = 'Factory'

local ServerTime = GetServerTime

Factory = Object:newChildConstructor()

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
        self._CheckedIn = {}
        self._CheckedOut = {}
        self:IsInitialized(true)
    end
end

function Factory:Print()
    if(XFG.Debug) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _CheckedInCount (" .. type(self._CheckedInCount) .. "): ".. tostring(self._CheckedInCount))
        XFG:Debug(ObjectName, "  _CheckedOutCount (" ..type(self._CheckedOutCount) .. "): ".. tostring(self._CheckedOutCount))
        for _Key, _Object in self:CheckedInIterator() do
            _Object:Print()
        end
        for _Key, _Object in self:CheckedOutIterator() do
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

function Factory:Remove(inKey)
    if(self:IsAvailable(inKey)) then
        self._CheckedIn[inKey] = nil
        self._CheckedInCount = self._CheckedInCount - 1
    end
end

function Factory:CheckOut()
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

    local _NewObject = self:CreateNew()
    _NewObject:SetFactoryKey(math.GenerateUID())
    _NewObject:SetFactoryTime(_CurrentTime)
    self._CheckedOut[_NewObject:GetFactoryKey()] = _NewObject
    self._CheckedOutCount = self._CheckedOutCount + 1

    return _NewObject
end

function Factory:CheckIn(inObject)
    if(inObject == nil) then return end
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
    if(self:IsLoaned(inObject:GetFactoryKey())) then
        self._CheckedOut[inObject:GetFactoryKey()] = nil
        self._CheckedOutCount = self._CheckedOutCount - 1
        inObject:FactoryReset()
        local _CurrentTime = ServerTime()
        inObject:SetFactoryTime(_CurrentTime)
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