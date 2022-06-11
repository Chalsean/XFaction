local XFG, G = unpack(select(2, ...))
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
		XFG:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', self.CallbackSpecChanged)
        XFG:Info(LogCategory, "Registered for ACTIVE_TALENT_GROUP_CHANGED events")
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
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SpecEvent:CallbackSpecChanged()
    local _SpecGroupID = GetSpecialization()
	local _SpecID = GetSpecializationInfo(_SpecGroupID)
    if(_SpecID == nil) then return end -- This fires at <lvl 10 even though theres no spec to choose

    local _NewSpec = XFG.Specs:GetSpec(_SpecID)
    local _CurrentSpec = XFG.Player.Unit:GetSpec(_SpecID)
    if(_NewSpec == nil or _CurrentSpec == nil) then return end

    -- For whatever reason the event fires twice in succession when a player changes specs
    if(_NewSpec:GetKey() ~= _CurrentSpec:GetKey()) then
        XFG.Player.Unit:SetSpec(_NewSpec)
        XFG:Info(LogCategory, "Updated player spec information to %s based on ACTIVE_TALENT_GROUP_CHANGED event", _NewSpec:GetName())
    end
end