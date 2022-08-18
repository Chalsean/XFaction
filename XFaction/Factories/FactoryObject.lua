local XFG, G = unpack(select(2, ...))
local ObjectName = 'FactoryObject'

FactoryObject = Object:newChildConstructor()

function FactoryObject:new()
    local _Object = FactoryObject.parent.new(self)
    _Object.__name = ObjectName
    _Object._FactoryKey = nil
    _Object._FactoryTime = nil
    return _Object
end

function FactoryObject:newChildConstructor()
    local _Object = FactoryObject.parent.new(self)
    _Object.__name = ObjectName
    _Object.parent = self    
    _Object._FactoryKey = nil
    _Object._FactoryTime = nil
    return _Object
end

function FactoryObject:GetFactoryKey()
    return self._FactoryKey
end

function FactoryObject:SetFactoryKey(inFactoryKey)
    assert(type(inFactoryKey) == 'string')
    self._FactoryKey = inFactoryKey
end

function FactoryObject:GetFactoryTime()
    return self._FactoryTime
end

function FactoryObject:SetFactoryTime(inFactoryTime)
    assert(type(inFactoryTime) == 'number')
    self._FactoryTime = inFactoryTime
end