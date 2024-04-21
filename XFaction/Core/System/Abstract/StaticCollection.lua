local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'StaticCollection'

XFC.StaticCollection = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.StaticCollection:new()
    local object = XFC.StaticCollection.parent.new(self)
    object.__name = ObjectName
    object.objects = nil
    object.objectCount = 0
    object.cached = false
    return object
end

function XFC.StaticCollection:newChildConstructor()
    local object = XFC.StaticCollection.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.objects = nil
    object.objectCount = 0
    object.cached = false
    return object
end

function XFC.StaticCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

-- So can call parent init
function XFC.StaticCollection:ParentInitialize()
    self:Key(math.GenerateUID())
    self.objects = {}
end
--#endregion

--#region Properties
function XFC.StaticCollection:IsCached(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
	if(inBoolean ~= nil) then
		self.cached = inBoolean
	end
	return self.cached
end

function XFC.StaticCollection:Count()
	return self.objectCount
end
--#endregion

--#region Methods
function XFC.StaticCollection:Print()
    self:ParentPrint()
end

function XFC.StaticCollection:ParentPrint()
    XF:DoubleLine(self:ObjectName())
    XF:Debug(self:ObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XF:Debug(self:ObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
    XF:Debug(self:ObjectName(), '  objectCount (' .. type(self.objectCount) .. '): ' .. tostring(self.objectCount))
    for _, object in self:Iterator() do
        object:Print()
    end
end

function XFC.StaticCollection:Iterator()
	return next, self.objects, nil
end

function XFC.StaticCollection:SortedIterator()
	return PairsByKeys(self.objects)
end

function XFC.StaticCollection:ReverseSortedIterator()
	return PairsByKeys(self.objects, function(a, b) return a > b end)
end

function XFC.StaticCollection:Contains(inKey)
    if(inKey == nil or (type(inKey) ~= 'string' and type(inKey) ~= 'number')) then
        return false
    end
	return self.objects[inKey] ~= nil
end

function XFC.StaticCollection:Get(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Collection key must be string or number')
	return self.objects[inKey]
end

function XFC.StaticCollection:GetByName(inName)
	assert(type(inName) == 'string')
	for _, object in self:Iterator() do
		if(object:Name() == inName) then
			return object
		end
	end
end

function XFC.StaticCollection:Add(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
	if(not self:Contains(inObject:GetKey())) then
		self.objectCount = self.objectCount + 1
	end
	self.objects[inObject:GetKey()] = inObject
end
--#endregion