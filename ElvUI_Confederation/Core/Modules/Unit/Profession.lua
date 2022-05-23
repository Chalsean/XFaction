local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Profession'
local LogCategory = 'UProfession'

Profession = {}

function Profession:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or _typeof == 'number' or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil, string or " .. ObjectName .. " object")

    if(_typeof == 'table') then
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
        self._ID = 0
        self._LocalID = 0
		self._Name = nil
        self._IconID = nil
        self._Initialized = false
    end

    return Object
end

function Profession:Initialize()
    if(self:IsInitialized() == false) then
        local _Name, _Icon, _, _, _, _, _ProfessionID = GetProfessionInfo(self._ID)
        self._Key = _ProfessionID
        self._LocalID = self._ID
        self._ID = _ProfessionID
        self._Name = _Name
        self._IconID = _Icon
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Profession:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Profession:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _LocalID (" .. type(self._LocalID) .. "): ".. tostring(self._LocalID))
    CON:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _IconID (" .. type(self._IconID) .. "): ".. tostring(self._IconID))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Profession:GetKey()
    return self._Key
end

function Profession:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
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

function Profession:Equals(inProfession)
    if(inProfession == nil) then return false end
    if(type(inProfession) ~= 'table' or inProfession.__name == nil or inProfession.__name ~= 'Profession') then return false end
    if(self:GetKey() ~= inProfession:GetKey()) then return false end
    return true
end