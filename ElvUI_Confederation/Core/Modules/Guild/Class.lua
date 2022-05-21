local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Class'
local LogCategory = 'O' .. ObjectName

Class = {}

function Class:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = _Argument
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._ID = nil
        self._Name = nil
    end

    return Object
end

function Class:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, "Class Object")
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
end

function Class:GetName()
    return self._Name
end

function Class:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Class:GetID()
    return self._ID
end

function Class:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end