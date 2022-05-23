local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Friend'
local LogCategory = 'NFriend'

Friend = {}

function Friend:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Key = nil
        self._ID = nil
        self._Name = nil
        self._Tag = nil
        self._RealmID = nil
        self._UnitName = nil
    end

    return Object
end

function Friend:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _Tag (" ..type(self._ShortName) .. "): ".. tostring(self._Tag))
    CON:Debug(LogCategory, "  _RealmID (" ..type(self._RealmID) .. "): ".. tostring(self._RealmID))
    CON:Debug(LogCategory, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
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