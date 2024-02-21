local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Factory'
local GetCurrentTime = GetServerTime

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
--#endregion

--#region Initializers
function XFC.Factory:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function XFC.Factory:ParentInitialize()
    self:SetKey(math.GenerateUID())
    self.objects = {}
    self.checkedIn = {}
    self.checkedOut = {}
end
--#endregion

--#region Print
function XFC.Factory:ParentPrint()
    if(XF.Debug) then
        XF:DoubleLine(self:GetObjectName())
        XF:Debug(self:GetObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
        XF:Debug(self:GetObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
        XF:Debug(self:GetObjectName(), '  checkedInCount (' .. type(self.checkedInCount) .. '): ' .. tostring(self.checkedInCount))
        XF:Debug(self:GetObjectName(), '  checkedOutCount (' .. type(self.checkedOutCount) .. '): ' .. tostring(self.checkedOutCount))
        for key, object in self:CheckedInIterator() do
            XF:Debug(self:GetObjectName(), 'checkedIn')
            object:Print()
        end
        for key, object in self:CheckedOutIterator() do
            XF:Debug(self:GetObjectName(), 'checkedOut')
            object:Print()
        end
    end
end
--#endregion

--#region Iterators
function XFC.Factory:CheckedInIterator()
	return next, self.checkedIn, nil
end

function XFC.Factory:CheckedOutIterator()
	return next, self.checkedOut, nil
end
--#endregion

--#region Stack
function XFC.Factory:IsLoaned(inKey)
    assert(type(inKey) == 'string')
    return self.checkedOut[inKey] ~= nil
end

function XFC.Factory:IsAvailable(inKey)
    assert(type(inKey) == 'string')
    return self.checkedIn[inKey] ~= nil
end

function XFC.Factory:Pop()
    assert(type(inKey) == 'string' or inKey == nil, 'argument must be string or nil value')
    local currentTime = GetCurrentTime()
    for _, object in self:CheckedInIterator() do
        object:SetFactoryTime(currentTime)
        self.checkedIn[object:GetFactoryKey()] = nil
        self.checkedInCount = self.checkedInCount - 1
        self.checkedOut[object:GetFactoryKey()] = object
        self.checkedOutCount = self.checkedOutCount + 1
        return object
    end

    local newObject = self:NewObject()
    newObject:SetFactoryKey(math.GenerateUID())
    newObject:SetFactoryTime(currentTime)
    self.checkedOut[newObject:GetFactoryKey()] = newObject
    self.checkedOutCount = self.checkedOutCount + 1

    return newObject
end

function XFC.Factory:Push(inObject)
    if(inObject == nil) then return end
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
    if(self:IsLoaned(inObject:GetFactoryKey())) then
        self.checkedOut[inObject:GetFactoryKey()] = nil
        self.checkedOutCount = self.checkedOutCount - 1
        inObject:Deconstructor()
        inObject:SetFactoryTime(GetCurrentTime())
        self.checkedIn[inObject:GetFactoryKey()] = inObject
        self.checkedInCount = self.checkedInCount + 1         
    end
end
--#endregion

--#region Janitorial
function XFC.Factory:Purge(inPurgeTime)
    assert(type(inPurgeTime) == 'number')
    for _, object in self:CheckedInIterator() do
        if(object:GetFactoryTime() < inPurgeTime) then
			self:Remove(object:GetKey())
			self.checkedIn[object:GetFactoryKey()] = nil
			self.checkedInCount = self.checkedInCount - 1
        end
    end
    for _, object in self:CheckedOutIterator() do
        if(object:GetFactoryTime() < inPurgeTime) then
			self:Remove(object:GetKey())
            self.checkedOut[object:GetFactoryKey()] = nil
			self.checkedOutCount = self.checkedOutCount - 1
        end
    end
end
--#endregion