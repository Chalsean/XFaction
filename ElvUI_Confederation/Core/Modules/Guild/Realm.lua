local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Realm'
local LogCategory = 'O' .. ObjectName

Realm = {}

function Realm:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or _typeof == 'string' or
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
        self._Name = nil
        self._ID = nil
        self._Units = {}
        self._NumberOfUnits = 0
        self._Initialized = false
    end

    return Object
end

function Realm:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Realm:Initialize()
	if(self:IsInitialized() == false) then
        self:SetName(GetRealmName())
        self:SetKey(self:GetName())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Realm:Print(inPrintOffline)
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Realm Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    for _Key, _Unit in pairs (self._Units) do
        if(inPrintOffline == true or _Unit:IsOnline()) then    
            _Unit:Print()
        end
    end
end

function Realm:GetKey()
    return self._Key
end

function Realm:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Realm:GetName()
    return self._Name
end

function Realm:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Realm:Contains(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Realm:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', "argument must be Unit object")

    if(self:Contains(inUnit:GetKey()) == false) then
        self._Units[inUnit:GetKey()] = inUnit
        self._NumberOfUnits = self._NumberOfUnits + 1
    end

    return self:Contains(inUnit:GetKey())
end