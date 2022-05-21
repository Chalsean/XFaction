local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Soulbind'
local LogCategory = 'O' .. ObjectName

Soulbind = {}

function Soulbind:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or 
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

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
        self._ID = nil
		self._Name = nil
        self._Initialized = false
    end

    return Object
end

function Soulbind:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', "argument must be nil or boolean")
    if(_Argument ~= nil) then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function Soulbind:Initialize()
    if(self:IsInitialized() == false and self._ID ~= nil) then
        local _SoulbindInfo = C_Soulbinds.GetSoulbindData(self:GetID())
        self:SetName(_SoulbindInfo.name)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Soulbind:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, "Soulbind Object")
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Soulbind:GetName()
    return self._Name
end

function Soulbind:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Soulbind:GetID()
    return self._ID
end

function Soulbind:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end