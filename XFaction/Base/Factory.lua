local XFG, G = unpack(select(2, ...))
local ObjectName = 'Factory'
local ServerTime = GetServerTime

Factory = ObjectCollection:newChildConstructor()

--#region Constructors
function Factory:new()
    local object = Factory.parent.new(self)
    object.__name = ObjectName
    object.checkedIn = nil
    object.checkedInCount = 0
    object.checkedOut = nil
    object.checkedOutCount = 0
    return object
end

function Factory:newChildConstructor()
    local object = Factory.parent.new(self)
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
function Factory:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

function Factory:ParentInitialize()
    self:SetKey(math.GenerateUID())
    self.objects = {}
    self.checkedIn = {}
    self.checkedOut = {}
end
--#endregion

--#region Print
function Factory:ParentPrint()
    if(XFG.Debug) then
        XFG:DoubleLine(self:GetObjectName())
        XFG:Debug(self:GetObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
        XFG:Debug(self:GetObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
        XFG:Debug(self:GetObjectName(), '  checkedInCount (' .. type(self.checkedInCount) .. '): ' .. tostring(self.checkedInCount))
        XFG:Debug(self:GetObjectName(), '  checkedOutCount (' .. type(self.checkedOutCount) .. '): ' .. tostring(self.checkedOutCount))
        for key, object in self:CheckedInIterator() do
            XFG:Debug(self:GetObjectName(), 'checkedIn')
            object:Print()
        end
        for key, object in self:CheckedOutIterator() do
            XFG:Debug(self:GetObjectName(), 'checkedOut')
            object:Print()
        end
    end
end
--#endregion

--#region Iterators
function Factory:CheckedInIterator()
	return next, self.checkedIn, nil
end

function Factory:CheckedOutIterator()
	return next, self.checkedOut, nil
end
--#endregion

--#region Stack
function Factory:IsLoaned(inKey)
    assert(type(inKey) == 'string')
    return self.checkedOut[inKey] ~= nil
end

function Factory:IsAvailable(inKey)
    assert(type(inKey) == 'string')
    return self.checkedIn[inKey] ~= nil
end

function Factory:Pop()
    assert(type(inKey) == 'string' or inKey == nil, 'argument must be string or nil value')
    local currentTime = ServerTime()
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

function Factory:Push(inObject)
    if(inObject == nil) then return end
    assert(type(inObject) == 'table' and inObject.__name ~= nil, 'argument must be an object')
    if(self:IsLoaned(inObject:GetFactoryKey())) then
        self.checkedOut[inObject:GetFactoryKey()] = nil
        self.checkedOutCount = self.checkedOutCount - 1
        inObject:FactoryReset()
        inObject:SetFactoryTime(ServerTime())
        self.checkedIn[inObject:GetFactoryKey()] = inObject
        self.checkedInCount = self.checkedInCount + 1         
    end
end
--#endregion

--#region Janitorial
function Factory:Purge(inPurgeTime)
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