local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Covenant'
local LogCategory = 'O' .. ObjectName

Covenant = {}

function Covenant:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or _typeof == 'number' or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

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
        self._ID = 0
        self._Name = nil
        self._SoulbindIDs = {}
        self._Initialized = false

        if(_typeof == 'number') then
            self._ID = _Argument
        end
    end

    return Object
end

function Covenant:Initialize()
    if(self._Initialized == false) then
        local _CovenantInfo = C_Covenants.GetCovenantData(self._ID)
        self._ID = _CovenantInfo.ID
        self._Name = _CovenantInfo.name
        self._SoulbindIDs = _CovenantInfo.soulbindIDs
        self._Initialized = true
    end
end

function Covenant:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, "Covenant Object")
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
    for _Index, _SoulbindID in PairsByKeys (self._SoulbindIDs) do
        CON:Debug(LogCategory, "  _SoulbindID[" .. tostring(_Index) .. "] (" ..type(_SoulbindID) .. "): ".. tostring(_SoulbindID))
    end
end

function Covenant:GetName()
    return self._Name
end

function Covenant:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Covenant:GetID()
    return self._ID
end

function Covenant:SetID(_ID)
    assert(type(_ID) == 'number')
    self._ID = _ID
    return self:GetID()
end

function Covenant:GetSoulbindIDs()
    return self._SoulbindIDs
end