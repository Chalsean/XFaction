local XFG, G = unpack(select(2, ...))
local ObjectName = 'ObjectCollection'

ObjectCollection = Object:newChildConstructor()

--#region Constructors
function ObjectCollection:new()
    local object = ObjectCollection.parent.new(self)
    object.__name = ObjectName
    object.objects = nil
    object.objectCount = 0
    object.cached = false
    return object
end

function ObjectCollection:newChildConstructor()
    local object = ObjectCollection.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.objects = nil
    object.objectCount = 0
    object.cached = false
    return object
end
--#endregion

--#region Initializers
function ObjectCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function ObjectCollection:IsCached(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
	if(inBoolean ~= nil) then
		self.cached = inBoolean
	end
	return self.cached
end

-- So can call parent init
function ObjectCollection:ParentInitialize()
    self:SetKey(math.GenerateUID())
    self.objects = {}
end
--#endregion

--#region Print
function ObjectCollection:Print()
    self:ParentPrint()
end

function ObjectCollection:ParentPrint()
    if(XFG.DebugFlag) then
        XFG:DoubleLine(self:GetObjectName())
        XFG:Debug(self:GetObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
        XFG:Debug(self:GetObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
        XFG:Debug(self:GetObjectName(), '  objectCount (' .. type(self.objectCount) .. '): ' .. tostring(self.objectCount))
        for _, object in self:Iterator() do
            object:Print()
        end
    end
end
--#endregion

--#region Iterators
function ObjectCollection:Iterator()
	return next, self.objects, nil
end

function ObjectCollection:SortedIterator()
	return PairsByKeys(self.objects)
end
--#endregion

--#region Hash
function ObjectCollection:Contains(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	return self.objects[inKey] ~= nil
end

function ObjectCollection:Get(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	return self.objects[inKey]
end

function ObjectCollection:Add(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
	if(not self:Contains(inObject:GetKey())) then
		self.objectCount = self.objectCount + 1
	end
	self.objects[inObject:GetKey()] = inObject
end

function ObjectCollection:Remove(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	if(self:Contains(inKey)) then
		self.objects[inKey] = nil
		self.objectCount = self.objectCount - 1
	end
end
--#endregion

--#region Accessors
function ObjectCollection:GetCount()
	return self.objectCount
end
--#endregion