local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Achievement'
local LogCategory = 'UAchievement'

Achievement = {}

function Achievement:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
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

    if(_newObject) then
        self._Key = nil
        self._ID = nil
		self._Name = nil
        self._IconID = nil
        self._Initialized = false
    end

    return Object
end

function Spec:Initialize()
    if(self:IsInitialized() == false) then
        local _, _Name, _, _Icon = GetSpecializationInfoByID(self._ID)
        self._Key = self._ID
        self._Name = _Name
        self._IconID = _Icon
        self:IsInitialized(true)
    end
end

function Spec:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Spec:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _IconID (" .. type(self._IconID) .. "): ".. tostring(self._IconID))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Spec:GetKey()
    return self._Key
end

function Spec:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Spec:GetName()
    return self._Name
end

function Spec:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Spec:GetID()
    return self._ID
end

function Spec:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Spec:GetIconID()
    return self._IconID
end

function Spec:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Spec:Equals(inSpec)
    if(inSpec == nil) then return false end
    if(type(inSpec) ~= 'table' or inSpec.__name == nil or inSpec.__name ~= 'Spec') then return false end
    if(self:GetKey() ~= inSpec:GetKey()) then return false end
    return true
end