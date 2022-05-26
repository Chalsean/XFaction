local EKX, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Class'
local LogCategory = 'UClass'

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
        self._Key = nil
        self._ID = nil
        self._Name = nil
    end

    return Object
end

function Class:Print()
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    EKX:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    EKX:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
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