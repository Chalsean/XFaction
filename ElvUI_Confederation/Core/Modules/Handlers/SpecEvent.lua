local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'SpecEvent'
local LogCategory = 'HESpec'

SpecEvent = {}

function SpecEvent:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Initialized = false
    end

    return Object
end

function SpecEvent:Initialize()
	if(self:IsInitialized() == false) then
		CON:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', self.CallbackSpecChanged)
        CON:Info(LogCategory, "Registered for ACTIVE_TALENT_GROUP_CHANGED events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SpecEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function SpecEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SpecEvent:CallbackSpecChanged()
    local _SpecGroupID = GetSpecialization()
	local _SpecID = GetSpecializationInfo(_SpecGroupID)
    local _NewSpec = CON.Specs:GetSpec(_SpecID)
    local _CurrentSpec = CON.Player.Unit:GetSpec(_SpecID)

    -- For whatever reason the event fires twice in succession when a player changes specs
    if(_NewSpec:GetKey() ~= _CurrentSpec:GetKey()) then
        CON.Player.Unit:SetSpec(_NewSpec)
        CON:Info(LogCategory, "Updated player spec information to %s based on ACTIVE_TALENT_GROUP_CHANGED event", _NewSpec:GetName())
    end
end