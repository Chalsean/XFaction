local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Spec'
local LogCategory = 'O' .. ObjectName

Spec = {}

function Spec:new(_Argument)
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

    if(_newObject) then
        self._ID = (_typeof == 'number') and _Argument or nil
		self._Name = nil
        self._IconID = nil
        self._Initialized = false
    end

    return Object
end

function Spec:Initialize()
    if(self:IsInitialized() == false) then
        local _, _Name, _, _Icon = GetSpecializationInfoByID(self._ID)
        self._Name = _Name
        self._IconID = _Icon
        self:IsInitialized(true)
    end
end

function Spec:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', "argument needs to be nil or boolean")
    if(type(_Argument) == 'boolean') then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function Spec:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, "Spec Object")
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _IconID (" .. type(self._IconID) .. "): ".. tostring(self._IconID))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Spec:GetName()
    return self._Name
end

function Spec:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Spec:GetID()
    return self._ID
end

function Spec:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end

function Spec:GetIconID()
    return self._IconID
end

function Spec:SetIconID(_IconID)
    assert(type(_IconID) == 'number')
    self._IconID = _IconID
    return self:GetIconID()
end