local XFG, G = unpack(select(2, ...))
local ObjectName = 'Object'

Object = {}

--#region Constructors
function Object:new()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    self.__name = ObjectName

    self.factoryKey = nil
    self.factoryTime = nil
    self.key = nil
    self.name = nil
    self.initialized = false
    
    return object
end

function Object:newChildConstructor()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    
    self.factoryKey = nil
    self.factoryTime = nil
    self.key = nil
    self.name = nil
    self.initialized = false

    return object
end
--#endregion

--#region Initializers
function Object:IsInitialized(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.initialized = inBoolean
    end    
    return self.initialized
end

function Object:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:IsInitialized(true)
    end
end

-- So can call parent init in child objects
function Object:ParentInitialize()
    self.key = math.GenerateUID()
end
--#endregion

--#region Print
function Object:Print()
    self:ParentPrint()
end

function Object:ParentPrint()
    XFG:SingleLine(self:GetObjectName())
    if(self.factoryKey ~= nil) then
        XFG:Debug(self:GetObjectName(), '  factoryKey (' .. type(self.factoryKey) .. '): ' .. tostring(self.factoryKey))
    end
    if(self.factoryTime ~= nil) then
        XFG:Debug(self:GetObjectName(), '  factoryTime (' .. type(self.factoryTime) .. '): ' .. tostring(self.factoryTime))
    end
    XFG:Debug(self:GetObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XFG:Debug(self:GetObjectName(), '  name (' .. type(self.name) .. '): ' .. tostring(self.name))
    XFG:Debug(self:GetObjectName(), '  initialized (' .. type(self.initialized) .. '): ' .. tostring(self.initialized))
end
--#endregion

--#region Accessors
function Object:GetFactoryKey()
    return self.factoryKey
end

function Object:SetFactoryKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self.factoryKey = inKey
end

function Object:GetFactoryTime()
    return self.factoryTime
end

function Object:SetFactoryTime(inFactoryTime)
    assert(type(inFactoryTime) == 'number')
    self.factoryTime = inFactoryTime
end

function Object:HasKey()
    return self.key ~= nil
end

function Object:GetKey()
    return self.key
end

function Object:SetKey(inKey)
    assert(type(inKey) == 'string' or type(inKey) == 'number', 'Object key must be string or number')
    self.key = inKey
end

function Object:GetName()
    return self.name
end

function Object:SetName(inName)
    assert(type(inName) == 'string')
    self.name = inName
end

function Object:GetObjectName()
    return self.__name
end
--#endregion

--#region Operators
function Object:Equals(inObject)
    if(inObject == nil) then return false end
    if(type(inObject) ~= 'table' or inObject.__name == nil) then return false end
    if(self:GetObjectName() ~= inObject:GetObjectName()) then return false end
    if(self:GetKey() ~= inObject:GetKey()) then return false end
    return true
end
--#endregion

--#region DataSet
function Object:ParentDeconstructor()
    self.key = nil
    self.name = nil
    self.initialized = false
end
--#endregion