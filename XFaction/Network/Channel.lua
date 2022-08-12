local XFG, G = unpack(select(2, ...))
local ObjectName = 'Channel'
local LogCategory = 'NChannel'

Channel = {}

function Channel:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._Password = nil
    
    return _Object
end

function Channel:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _Password (" ..type(self._Password) .. "): ".. tostring(self._Password))
end

function Channel:GetKey()
    return self._Key
end

function Channel:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Channel:GetName()
    return self._Name
end

function Channel:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Channel:GetID()
    return self._ID
end

function Channel:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Channel:GetPassword()
    return self._Password
end

function Channel:SetPassword(inPassword)
    assert(type(inPassword) == 'string')
    self._Password = inPassword
    return self:GetPassword()
end