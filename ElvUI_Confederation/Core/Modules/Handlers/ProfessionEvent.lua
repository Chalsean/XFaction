local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ProfessionEvent'
local LogCategory = 'HEProfession'

ProfessionEvent = {}

function ProfessionEvent:new(inObject)
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

function ProfessionEvent:Initialize()
	if(self:IsInitialized() == false) then
		CON:RegisterEvent('TRADE_SKILL_NAME_UPDATE', self.CallbackProfessionChanged)
        CON:Info(LogCategory, "Registered for TRADE_SKILL_NAME_UPDATE events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ProfessionEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function ProfessionEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function ProfessionEvent:CallbackProfessionChanged()
    CON:Debug(LogCategory, "Received profession change event")
end