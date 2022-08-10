local XFG, G = unpack(select(2, ...))
local ObjectName = 'Media'
local LogCategory = 'MMedia'

Media = {}

function Media:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Type = nil
    self._Name = nil
    self._Path = nil

    return Object
end

function Media:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Type (' .. type(self._Type) .. '): ' .. tostring(self._Type))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _Path (' .. type(self._Path) .. '): ' .. tostring(self._Path))
end

function Media:GetKey()
    return self._Key
end

function Media:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Media:GetType()
    return self._Type
end

function Media:SetType(inType)
    assert(type(inType) == 'string')
    self._Type = inType
    return self:GetType()
end

function Media:GetName()
    return self._Name
end

function Media:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Media:GetPath()
    return self._Path
end

function Media:SetPath(inPath)
    assert(type(inPath) == 'string')
    self._Path = inPath
    return self:GetPath()
end

function Media:GetTexture()
    return format('%s', format(XFG.Icons.Texture, self:GetPath()))
end