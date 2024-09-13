local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Factory'

XFC.Factory = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Factory:new()
    local object = XFC.Factory.parent.new(self)
    object.__name = ObjectName
    object.checkedIn = nil
    object.checkedInCount = 0
    object.checkedOut = nil
    object.checkedOutCount = 0
    return object
end

function XFC.Factory:newChildConstructor()
    local object = XFC.Factory.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.checkedIn = nil
    object.checkedInCount = 0
    object.checkedOut = nil
    object.checkedOutCount = 0
    return object
end

function XFC.Factory:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function XFC.Factory:ParentInitialize()
    self:Key(math.GenerateUID())
    self.objects = {}
    self.checkedIn = {}
    self.checkedOut = {}
end
--#endregion

--#region Methods
function XFC.Factory:ParentPrint()
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

function XFC.Factory:CheckedInIterator()
	return next, self.checkedIn, nil
end

function XFC.Factory:CheckedOutIterator()
	return next, self.checkedOut, nil
end

function XFC.Factory:IsLoaned(inKey)
    assert(type(inKey) == 'string')
    return self.checkedOut[inKey] ~= nil
end

function XFC.Factory:IsAvailable(inKey)
    assert(type(inKey) == 'string')
    return self.checkedIn[inKey] ~= nil
end

function XFC.Factory:Pop()
    assert(type(inKey) == 'string' or inKey == nil)
    local currentTime = XFF.TimeCurrent()
    for _, object in self:CheckedInIterator() do
        object:FactoryTime(currentTime)
        self.checkedIn[object:FactoryKey()] = nil
        self.checkedInCount = self.checkedInCount - 1
        self.checkedOut[object:FactoryKey()] = object
        self.checkedOutCount = self.checkedOutCount + 1
        return object
    end

    local newObject = self:NewObject()
    newObject:FactoryKey(math.GenerateUID())
    newObject:FactoryTime(currentTime)
    self.checkedOut[newObject:FactoryKey()] = newObject
    self.checkedOutCount = self.checkedOutCount + 1

    return newObject
end

function XFC.Factory:Push(inObject)
    if(inObject == nil) then return end
    assert(type(inObject) == 'table' and inObject.__name ~= nil)
    if(self:IsLoaned(inObject:FactoryKey())) then
        self.checkedOut[inObject:FactoryKey()] = nil
        self.checkedOutCount = self.checkedOutCount - 1
        inObject:Deconstructor()
        inObject:FactoryTime(XFF.TimeCurrent())
        self.checkedIn[inObject:FactoryKey()] = inObject
        self.checkedInCount = self.checkedInCount + 1         
    end
end

function XFC.Factory:Purge(inPurgeTime)
    assert(type(inPurgeTime) == 'number')
    for _, object in self:CheckedInIterator() do
        if(object:FactoryTime() < inPurgeTime) then
			self:Remove(object:Key())
			self.checkedIn[object:FactoryKey()] = nil
			self.checkedInCount = self.checkedInCount - 1
        end
    end
    for _, object in self:CheckedOutIterator() do
        if(object:FactoryTime() < inPurgeTime) then
			self:Remove(object:Key())
            self.checkedOut[object:FactoryKey()] = nil
			self.checkedOutCount = self.checkedOutCount - 1
        end
    end
end

function XFC.Factory:Replace(inObject)
    assert(type(inObject) == 'table' and inObject.__name ~= nil)
    local old = self.objects[inObject:Key()]
    self.objects[inObject:Key()] = inObject
    if(old ~= nil) then
        self:Push(old)
    else
        self.objectCount = self.objectCount + 1
    end
end
--#endregion