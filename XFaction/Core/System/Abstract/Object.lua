local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Object'

XFC.Object = {}

--#region Constructors
function XFC.Object:new()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    self.__name = ObjectName
    self.key = nil
    self.name = nil
    self.id = nil
    self.initialized = false
    
    return object
end

function XFC.Object:newChildConstructor()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    self.key = nil
    self.name = nil
    self.id = nil
    self.initialized = false

    return object
end

function XFC.Object:IsInitialized(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.initialized = inBoolean
    end    
    return self.initialized
end

function XFC.Object:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

-- So can call parent init in child objects
function XFC.Object:ParentInitialize()
    self.key = math.GenerateUID()
end
--#endregion

--#region Properties
function XFC.Object:Key(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number' or inKey == nil, 'argument must be string, number or nil')
    if(inKey ~= nil) then
        self.key = inKey
    end
    return self.key
end

function XFC.Object:Name(inName)
    assert(type(inName) == 'string' or inName == nil, 'argument must be string or nil')
    if(inName ~= nil) then
        self.name = inName
    end
    return self.name
end

function XFC.Object:ID(inID)
    assert(type(inID) == 'string' or type(inID) == 'number' or inID == nil, 'argument must be string, number or nil')
    if(inID ~= nil) then
        self.id = inID
    end
    return self.id
end

function XFC.Object:ObjectName()
    return self.__name
end
--#endregion

--#region Methods
function XFC.Object:Print()
    self:ParentPrint()
end

function XFC.Object:ParentPrint()
    XF:SingleLine(self:ObjectName())
    XF:Debug(self:ObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XF:Debug(self:ObjectName(), '  id (' .. type(self.id) .. '): ' .. tostring(self.id))
    XF:Debug(self:ObjectName(), '  name (' .. type(self.name) .. '): ' .. tostring(self.name))
    XF:Debug(self:ObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
end

function XFC.Object:Serialize()
    return self:Key()
end

function XFC.Object:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:ObjectName() ~= inObject:ObjectName()) then return false end
    if(self:Key() ~= inObject:Key()) then return false end
    return true
end

function XF:ObjectsEquals(inObject1, inObject2)
    if(inObject1 == nil or inObject2 == nil) then return false end
    if(type(inObject1) ~= 'table' or type(inObject2) ~= 'table') then return false end
    if(inObject1.__name ~= inObject2.__name) then return false end
    return inObject1:Equals(inObject2)
end    
--#endregion