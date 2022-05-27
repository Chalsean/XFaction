local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Soulbind'
local LogCategory = 'USoulbind'

Soulbind = {}

function Soulbind:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

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
        self._Initialized = false
    end

    return Object
end

function Soulbind:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
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
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): " .. tostring(self._Initialized))
end

function Soulbind:GetKey()
    return self._Key
end

function Soulbind:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Soulbind:GetName()
    return self._Name
end

function Soulbind:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Soulbind:GetID()
    return self._ID
end

function Soulbind:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Soulbind:Equals(inSoulbind)
    if(inSoulbind == nil) then return false end
    if(type(inSoulbind) ~= 'table' or inSoulbind.__name == nil or inSoulbind.__name ~= 'Soulbind') then return false end
    if(self:GetKey() ~= inSoulbind:GetKey()) then return false end
    return true
end