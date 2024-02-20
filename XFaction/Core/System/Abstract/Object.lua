local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Object'

XFC.Object = {}

--#region Constructors
function XFC.Object:new()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    self.__name = ObjectName

    self.factoryKey = nil
    self.factoryTime = nil
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
    
    self.factoryKey = nil
    self.factoryTime = nil
    self.key = nil
    self.name = nil
    self.id = nil
    self.initialized = false

    return object
end
--#endregion

--#region Initializers
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

--#region Print
function XFC.Object:Print()
    self:ParentPrint()
end

function XFC.Object:ParentPrint()
    XF:SingleLine(self:GetObjectName())
    if(self.factoryKey ~= nil) then
        XF:Debug(self:GetObjectName(), '  factoryKey (' .. type(self.factoryKey) .. '): ' .. tostring(self.factoryKey))
    end
    if(self.factoryTime ~= nil) then
        XF:Debug(self:GetObjectName(), '  factoryTime (' .. type(self.factoryTime) .. '): ' .. tostring(self.factoryTime))
    end
    XF:Debug(self:GetObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XF:Debug(self:GetObjectName(), '  id (' .. type(self.id) .. '): ' .. tostring(self.id))
    XF:Debug(self:GetObjectName(), '  name (' .. type(self.name) .. '): ' .. tostring(self.name))
    XF:Debug(self:GetObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
end
--#endregion

--#region Accessors
function XFC.Object:GetFactoryKey()
    return self.factoryKey
end

function XFC.Object:SetFactoryKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self.factoryKey = inKey
end

function XFC.Object:GetFactoryTime()
    return self.factoryTime
end

function XFC.Object:SetFactoryTime(inFactoryTime)
    assert(type(inFactoryTime) == 'number')
    self.factoryTime = inFactoryTime
end

function XFC.Object:HasKey()
    return self.key ~= nil
end

function XFC.Object:GetKey()
    return self.key
end

function XFC.Object:SetKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self.key = inKey
end

function XFC.Object:GetName()
    return self.name
end

function XFC.Object:SetName(inName)
    assert(type(inName) == 'string')
    self.name = inName
end

function XFC.Object:GetID()
    return self.id
end

function XFC.Object:SetID(inID)
    assert(type(inID) == 'string' or type(inID) == 'number', 'Object ID must be string or number')
    self.id = inID
end

function XFC.Object:GetObjectName()
    return self.__name
end
--#endregion

--#region Operators
function XFC.Object:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:GetObjectName() ~= inObject:GetObjectName()) then return false end
    if(self:GetKey() ~= inObject:GetKey()) then return false end
    return true
end
--#endregion

--#region DataSet
function XFC.Object:ParentDeconstructor()
    self.key = nil
    self.name = nil
    self.id = nil
    self.initialized = false
end
--#endregion