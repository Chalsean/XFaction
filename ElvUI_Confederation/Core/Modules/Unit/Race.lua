local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Race'
local LogCategory = 'U' .. ObjectName

Race = {}

function Race:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or _typeof == 'string' or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = _Argument
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Name = (_typeof == 'string') and _Argument or nil
		self._ID = nil
        self._Faction = nil
    end

    return Object
end

function Race:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, "Race Object")
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _Faction (" .. type(self._Faction) .. "): ".. tostring(self._Faction))
end

function Race:GetName()
    return self._Name
end

function Race:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Race:GetID()
    return self._ID
end

function Race:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end

function Race:GetFaction()
    return self._Faction
end

function Race:SetFaction(_Faction)
    assert(type(_Faction) == 'string' and (_Faction == "Horde" or _Faction == "Alliance" or _Faction == "Neutral"), "argument must be Horde, Alliance or Neutral")
    self._Faction = _Faction
    return self:GetFaction()
end