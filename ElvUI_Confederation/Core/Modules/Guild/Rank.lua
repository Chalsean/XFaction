local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Rank'
local LogCategory = 'O' .. ObjectName

Rank = {}

function Rank:new(_Argument)
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
        self._Name = (_typeof == 'string') and _Argument or 'Trial'
        self._ID = nil
        self._AltName = nil
    end

    return Object
end

function Rank:GetName()
    return self._Name
end

function Rank:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Rank:GetID()
    return self._ID
end

function Rank:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end

function Rank:GetAltName()
    return self._AltName
end

function Rank:SetAltName(_AltName)
    assert(type(_AltName) == 'string')
    self._AltName = _AltName
    return self:GetAltName()
end