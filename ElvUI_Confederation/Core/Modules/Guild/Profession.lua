local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Profession'
local LogCategory = 'O' .. ObjectName

Profession = {}

function Profession:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or _typeof == 'number' or
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

    if(_newObject == true) then
        self._ID = 0
		self._Name = nil
        self._IconID = nil
        self._Initialized = false
    end

    return Object
end

function Profession:Initialize()
    if(self:IsInitialized() == false) then
        local _Name, _Icon, _, _, _, _, _ProfessionID = GetProfessionInfo(self._ID)
        self._ID = _ProfessionID
        self._Name = _Name
        self._IconID = _Icon
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Profession:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', "argument needs to be nil or boolean")
    if(type(_Argument) == 'boolean') then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function Profession:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, "Profession Object")
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _IconID (" .. type(self._IconID) .. "): ".. tostring(self._IconID))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Profession:GetName()
    return self._Name
end

function Profession:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Profession:GetID()
    return self._ID
end

function Profession:SetID(_ProfessionID)
    assert(type(_ProfessionID) == 'number')
    self._ID = _ProfessionID
    return self:GetID()
end

function Profession:GetIconID()
    return self._IconID
end

function Profession:SetIconID(_IconID)
    assert(type(_IconID) == 'number')
    self._IconID = _IconID
    return self:GetIconID()
end