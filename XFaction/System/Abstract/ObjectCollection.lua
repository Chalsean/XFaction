local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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

function XFC.ObjectCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

-- So can call parent init
function XFC.ObjectCollection:ParentInitialize()
    self:Key(math.GenerateUID())
    self.objects = {}
end
--#endregion

--#region Properties
function XFC.ObjectCollection:IsCached(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
	if(inBoolean ~= nil) then
		self.cached = inBoolean
	end
	return self.cached
end

function XFC.ObjectCollection:Count()
    return self.objectCount
end

function XFC.ObjectCollection:Iterator()
	return next, self.objects, nil
end

function XFC.ObjectCollection:SortedIterator()
	return PairsByKeys(self.objects)
end

function XFC.ObjectCollection:ReverseSortedIterator()
	return PairsByKeys(self.objects, function(a, b) return a > b end)
end

function XFC.ObjectCollection:RandomIterator()

    local shuffled = {}
    for key in pairs(self.objects) do
	    local pos = math.random(1, #shuffled + 1)
	    table.insert(shuffled, pos, key)
    end

    local i = 0
	local iter = function ()   -- iterator function
        i = i + 1
	    if shuffled[i] == nil then
            return nil
	    else
            return shuffled[i], self.objects[shuffled[i]]
	    end
	end
	return iter
end
--#endregion

--#region Methods
function XFC.ObjectCollection:Print()
    self:ParentPrint()
end

function XFC.ObjectCollection:ParentPrint()
    XF:DoubleLine(self:ObjectName())
    XF:Debug(self:ObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XF:Debug(self:ObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
    XF:Debug(self:ObjectName(), '  objectCount (' .. type(self.objectCount) .. '): ' .. tostring(self.objectCount))
    for _, object in self:Iterator() do
        object:Print()
    end
end

function XFC.ObjectCollection:Contains(inKey)
    if(type(inKey) == 'string' or type(inKey) == 'number') then
        return self.objects[inKey] ~= nil
    end
    return false
end

function XFC.ObjectCollection:Get(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number' or inKey == nil)
    if(inKey == nil) then return nil end
	return self.objects[inKey]
end

function XFC.ObjectCollection:Add(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil)
	if(not self:Contains(inObject:Key())) then
		self.objectCount = self.objectCount + 1
	end
	self.objects[inObject:Key()] = inObject
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
        self:Remove(object:Key())
    end
end

function XFC.ObjectCollection:HasObjects()
    return self:Count() > 0
end
--#endregion