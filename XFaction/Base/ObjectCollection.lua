local XFG, G = unpack(select(2, ...))
local ObjectName = 'ObjectCollection'
local Functions = {
	LogLine = XFG.DoubleLine,
	LogDebug = XFG.Debug,
}

ObjectCollection = Object:newChildConstructor()

function ObjectCollection:new()
    local _Object = ObjectCollection.parent.new(self)
    _Object.__name = ObjectName
    _Object._Objects = nil
    _Object._ObjectCount = 0
    return _Object
end

function ObjectCollection:newChildConstructor()
    local _Object = ObjectCollection.parent.new(self)
    _Object.__name = ObjectName
    _Object.parent = self    
    _Object._Objects = nil
    _Object._ObjectCount = 0
    return _Object
end

function ObjectCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

-- So can call parent init
function ObjectCollection:ParentInitialize()
    self:SetKey(math.GenerateUID())
    self._Objects = {}
end

function ObjectCollection:Print()
    self:ParentPrint()
end

function ObjectCollection:ParentPrint()
    Functions.LogLine(ObjectName)
    Functions.LogDebug(ObjectName, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    Functions.LogDebug(ObjectName, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
    Functions.LogDebug(ObjectName, '  _ObjectCount (' .. type(self._ObjectCount) .. '): ' .. tostring(self._ObjectCount))
    for _, _Object in self:Iterator() do
        _Object:Print()
    end
end

function ObjectCollection:Contains(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	return self._Objects[inKey] ~= nil
end

function ObjectCollection:GetObject(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	return self._Objects[inKey]
end

function ObjectCollection:Iterator()
	return next, self._Objects, nil
end

function ObjectCollection:SortedIterator()
	return PairsByKeys(self._Objects)
end

function ObjectCollection:GetCount()
	return self._ObjectCount
end

function ObjectCollection:AddObject(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
	if(not self:Contains(inObject:GetKey())) then
		self._ObjectCount = self._ObjectCount + 1
	end
	self._Objects[inObject:GetKey()] = inObject
	return self:Contains(inObject:GetKey())
end

function ObjectCollection:RemoveObject(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	if(self:Contains(inKey)) then
		self._Objects[inKey] = nil
		self._ObjectCount = self._ObjectCount - 1
	end
	return not self:Contains(inKey)
end
