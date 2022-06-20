local XFG, G = unpack(select(2, ...))
local ObjectName = 'Class'
local LogCategory = 'UClass'

Class = {}

function Class:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._APIName = nil
    self._ColorMixin = nil

    return Object
end

function Class:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
end

function Class:GetKey()
    return self._Key
end

function Class:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Class:GetName()
    return self._Name
end

function Class:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Class:GetID()
    return self._ID
end

function Class:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Class:GetAPIName()
    return self._APIName
end

function Class:SetAPIName(inAPIName)
    assert(type(inAPIName) == 'string')
    self._APIName = inAPIName
    self._ColorMixin = C_ClassColor.GetClassColor(self:GetAPIName())
    return self:GetAPIName()
end

function Class:GetColorMixin()
    return self._ColorMixin
end