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
    self._R = nil
    self._G = nil
    self._B = nil
    self._Hex = nil

    return Object
end

function Class:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _APIName (' .. type(self._APIName) .. '): ' .. tostring(self._APIName))
    XFG:Debug(LogCategory, '  _R (' .. type(self._R) .. '): ' .. tostring(self._R))
    XFG:Debug(LogCategory, '  _G (' .. type(self._G) .. '): ' .. tostring(self._G))
    XFG:Debug(LogCategory, '  _B (' .. type(self._B) .. '): ' .. tostring(self._B))
    XFG:Debug(LogCategory, '  _Hex (' .. type(self._Hex) .. '): ' .. tostring(self._Hex))
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
    return self:GetAPIName()
end

function Class:GetRGB()
    return self._R, self._G, self._B
end

function Class:GetRGBPercent()
    return self._R / 255, self._G / 255, self._B / 255
end

function Class:SetRGB(inR, inG, inB)
    assert(type(inR) == 'number')
    assert(type(inG) == 'number')
    assert(type(inB) == 'number')
    self._R = inR
    self._G = inG
    self._B = inB
    return self:GetRGB()
end

function Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self._Hex = inHex
    return self:GetHex()
end

function Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self._Hex = inHex
    return self:GetHex()
end

function Class:GetHex()
    return self._Hex
end

function Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self._Hex = inHex
    return self:GetHex()
end