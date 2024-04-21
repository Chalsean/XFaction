local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DynamicCollection'

XFC.DynamicCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.DynamicCollection:new()
    local object = XFC.DynamicCollection.parent.new(self)
    object.__name = ObjectName
    object.checkedIn = nil
    object.checkedInCount = 0
    object.checkedOut = nil
    object.checkedOutCount = 0
    return object
end

function XFC.DynamicCollection:newChildConstructor()
    local object = XFC.DynamicCollection.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.checkedIn = nil
    object.checkedInCount = 0
    object.checkedOut = nil
    object.checkedOutCount = 0
    return object
end

function XFC.DynamicCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function XFC.DynamicCollection:ParentInitialize()
    self:Key(math.GenerateUID())
    self.objects = {}
    self.checkedIn = {}
    self.checkedOut = {}
end
--#endregion

--#region Properties
function XFC.DynamicCollection:IsLoaned(inKey)
    assert(type(inKey) == 'string')
    return self.checkedOut[inKey] ~= nil
end

function XFC.DynamicCollection:IsAvailable(inKey)
    assert(type(inKey) == 'string')
    return self.checkedIn[inKey] ~= nil
end
--#endregion

--#region Methods
function XFC.DynamicCollection:ParentPrint()
    if(XF.Debug) then
        XF:DoubleLine(self:ObjectName())
        XF:Debug(self:ObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
        XF:Debug(self:ObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
        XF:Debug(self:ObjectName(), '  checkedInCount (' .. type(self.checkedInCount) .. '): ' .. tostring(self.checkedInCount))
        XF:Debug(self:ObjectName(), '  checkedOutCount (' .. type(self.checkedOutCount) .. '): ' .. tostring(self.checkedOutCount))
        for key, object in self:CheckedInIterator() do
            XF:Debug(self:ObjectName(), 'checkedIn')
            object:Print()
        end
        for key, object in self:CheckedOutIterator() do
            XF:Debug(self:ObjectName(), 'checkedOut')
            object:Print()
        end
    end
end

function XFC.DynamicCollection:CheckedInIterator()
	return next, self.checkedIn, nil
end

function XFC.DynamicCollection:CheckedOutIterator()
	return next, self.checkedOut, nil
end

function XFC.DynamicCollection:Pop()
    assert(type(inKey) == 'string' or inKey == nil, 'argument must be string or nil value')
    local currentTime = XFF.TimeGetCurrent()
    for _, object in self:CheckedInIterator() do
        object:DynamicCollectionTime(currentTime)
        self.checkedIn[object:DynamicCollectionKey()] = nil
        self.checkedInCount = self.checkedInCount - 1
        self.checkedOut[object:DynamicCollectionKey()] = object
        self.checkedOutCount = self.checkedOutCount + 1
        return object
    end

    local newObject = self:NewObject()
    newObject:DynamicCollectionKey(math.GenerateUID())
    newObject:DynamicCollectionTime(currentTime)
    self.checkedOut[newObject:DynamicCollectionKey()] = newObject
    self.checkedOutCount = self.checkedOutCount + 1

    return newObject
end

function XFC.DynamicCollection:Push(inObject)
    if(inObject == nil) then return end
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
    if(self:IsLoaned(inObject:DynamicCollectionKey())) then
        self.checkedOut[inObject:DynamicCollectionKey()] = nil
        self.checkedOutCount = self.checkedOutCount - 1
        inObject:Deconstructor()
        inObject:DynamicCollectionTime(XFF.TimeGetCurrent())
        self.checkedIn[inObject:DynamicCollectionKey()] = inObject
        self.checkedInCount = self.checkedInCount + 1         
    end
end

function XFC.DynamicCollection:Purge(inPurgeTime)
    assert(type(inPurgeTime) == 'number')
    for _, object in self:CheckedInIterator() do
        if(object:DynamicCollectionTime() < inPurgeTime) then
			self:Remove(object:Key())
			self.checkedIn[object:DynamicCollectionKey()] = nil
			self.checkedInCount = self.checkedInCount - 1
        end
    end
    for _, object in self:CheckedOutIterator() do
        if(object:DynamicCollectionTime() < inPurgeTime) then
			self:Remove(object:Key())
            self.checkedOut[object:DynamicCollectionKey()] = nil
			self.checkedOutCount = self.checkedOutCount - 1
        end
    end
end
--#endregion