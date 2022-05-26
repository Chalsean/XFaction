local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ZoneCollection'
local LogCategory = 'UCZone'

ZoneCollection = {}

function ZoneCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or _typeof == 'string' or
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
        self._Zones = {}
		self._ZoneCount = 0
		self._Initialized = false
    end

    return Object
end

function ZoneCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ZoneCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function ZoneCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, ObjectName .. " Object")
	CON:Debug(LogCategory, "  _ZoneCount (" .. type(self._ZoneCount) .. "): ".. tostring(self._ZoneCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	CON:Debug(LogCategory, "  _Zones (" .. type(self._Zones) .. "): ")
	for _, _Zone in pairs (self._Zones) do
		_Zone:Print()
	end
end

function ZoneCollection:GetKey()
    return self._Key
end

function ZoneCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function ZoneCollection:Contains(inKey)
	assert(type(inKey) == 'string')
    return self._Zones[inKey] ~= nil
end

function ZoneCollection:GetZone(inKey)
	assert(type(inKey) == 'string')
    return self._Zones[inKey]
end

function ZoneCollection:AddZone(inZone)
    assert(type(inZone) == 'table' and inZone.__name ~= nil and inZone.__name == 'Zone', "argument must be Zone object")
	if(inZone:IsInitialized() == false and Zone:GetKey() == nil) then
		inZone:Initialize()
	end
	if(self:Contains(inZone:GetKey()) == false) then
		self._ZoneCount = self._ZoneCount + 1
	end		
	self._Zones[inZone:GetKey()] = inZone
	return self:Contains(inZone:GetKey())
end