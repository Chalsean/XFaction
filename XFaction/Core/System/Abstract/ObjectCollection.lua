local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ObjectCollection'

XFC.ObjectCollection = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.ObjectCollection:new()
    local object = XFC.ObjectCollection.parent.new(self)
    object.__name = ObjectName
    object.objects = nil
    object.objectCount = 0
    object.cached = false
    return object
end

function XFC.ObjectCollection:newChildConstructor()
    local object = XFC.ObjectCollection.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.objects = nil
    object.objectCount = 0
    object.cached = false
    return object
end
--#endregion

--#region Initializers
function XFC.ObjectCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function XFC.ObjectCollection:IsCached(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
	if(inBoolean ~= nil) then
		self.cached = inBoolean
	end
	return self.cached
end

-- So can call parent init
function XFC.ObjectCollection:ParentInitialize()
    self:SetKey(math.GenerateUID())
    self.objects = {}
end
--#endregion

--#region Print
function XFC.ObjectCollection:Print()
    self:ParentPrint()
end

function XFC.ObjectCollection:ParentPrint()
    XF:DoubleLine(self:GetObjectName())
    XF:Debug(self:GetObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XF:Debug(self:GetObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
    XF:Debug(self:GetObjectName(), '  objectCount (' .. type(self.objectCount) .. '): ' .. tostring(self.objectCount))
    for _, object in self:Iterator() do
        object:Print()
    end
end
--#endregion

--#region Iterators
function XFC.ObjectCollection:Iterator()
	return next, self.objects, nil
end

function XFC.ObjectCollection:SortedIterator()
	return PairsByKeys(self.objects)
end

function XFC.ObjectCollection:ReverseSortedIterator()
	return PairsByKeys(self.objects, function(a, b) return a > b end)
end
--#endregion

--#region Hash
function XFC.ObjectCollection:Contains(inKey)
    if(inKey == nil or (type(inKey) ~= 'string' and type(inKey) ~= 'number')) then
        return false
    end
	return self.objects[inKey] ~= nil
end

function XFC.ObjectCollection:Get(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	return self.objects[inKey]
end

function XFC.ObjectCollection:Add(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
	if(not self:Contains(inObject:GetKey())) then
		self.objectCount = self.objectCount + 1
	end
	self.objects[inObject:GetKey()] = inObject
end

function XFC.ObjectCollection:Remove(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	if(self:Contains(inKey)) then
		self.objects[inKey] = nil
		self.objectCount = self.objectCount - 1
	end
end

function XFC.ObjectCollection:RemoveAll()
    for _, object in self:Iterator() do
        self:Remove(object:GetKey())
    end
end
--#endregion

--#region Accessors
function XFC.ObjectCollection:GetCount()
	return self.objectCount
end
--#endregion