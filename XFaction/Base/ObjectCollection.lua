local XFG, G = unpack(select(2, ...))
local ObjectName = 'ObjectCollection'

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
    if(XFG.DebugFlag) then
        XFG:DoubleLine(self:GetObjectName())
        XFG:Debug(self:GetObjectName(), '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
        XFG:Debug(self:GetObjectName(), '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
        XFG:Debug(self:GetObjectName(), '  _ObjectCount (' .. type(self._ObjectCount) .. '): ' .. tostring(self._ObjectCount))
        for _, _Object in self:Iterator() do
            _Object:Print()
        end
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
end

function ObjectCollection:RemoveObject(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	if(self:Contains(inKey)) then
		self._Objects[inKey] = nil
		self._ObjectCount = self._ObjectCount - 1
	end
end
