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
    self._RealmID = nil
    self._UnitName = nil
    self._Faction = nil

    return _Object
end

function Friend:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _Tag (" ..type(self._Tag) .. "): ".. tostring(self._Tag))
    XFG:Debug(LogCategory, "  _RealmID (" ..type(self._RealmID) .. "): ".. tostring(self._RealmID))
    XFG:Debug(LogCategory, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
    self._Faction:Print()
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

function Friend:GetRealmID()
    return self._RealmID
end

function Friend:SetRealmID(inRealmID)
    assert(type(inRealmID) == 'number')
    self._RealmID = inRealmID
    return self:GetRealmID()
end

function Friend:GetUnitName()
    return self._UnitName
end

function Friend:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._UnitName = inUnitName
    return self:GetUnitName()
end

function Friend:GetFaction()
    return self._Faction
end

function Friend:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end
