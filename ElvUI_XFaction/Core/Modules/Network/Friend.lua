local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Friend'
local LogCategory = 'NFriend'

Friend = {}

function Friend:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._Tag = nil
    self._Target = nil
    self._UnitName = nil

    return _Object
end

function Friend:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _Tag (" ..type(self._Tag) .. "): ".. tostring(self._Tag))
    XFG:Debug(LogCategory, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
    if(self:HasTarget()) then
        self._Target:Print()
    end
end

function Friend:GetKey()
    return self._Key
end

function Friend:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Friend:GetID()
    return self._ID
end

function Friend:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Friend:GetName()
    return self._Name
end

function Friend:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Friend:GetTag()
    return self._Tag
end

function Friend:SetTag(inTag)
    assert(type(inTag) == 'string')
    self._Tag = inTag
    return self:GetTag()
end

function Friend:HasTarget()
    return self._Target ~= nil
end

function Friend:GetTarget()
    return self._Target
end

function Friend:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    self._Target = inTarget
    return self:GetTarget()
end

function Friend:GetUnitName()
    return self._UnitName
end

function Friend:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._UnitName = inUnitName
    return self:GetUnitName()
end