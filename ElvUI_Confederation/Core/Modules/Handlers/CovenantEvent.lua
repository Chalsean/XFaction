local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CovenantEvent'
local LogCategory = 'HECovenant'

CovenantEvent = {}

function CovenantEvent:new(inObject)
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

function CovenantEvent:Initialize()
	if(self:IsInitialized() == false) then
		CON:RegisterEvent('COVENANT_CHOSEN', self.CallbackCovenantChosen)
        CON:Info(LogCategory, "Registered for COVENANT_CHOSEN events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function CovenantEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function CovenantEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function CovenantEvent:CallbackCovenantChosen(event)
	local _NewCovenantID = C_Covenants.GetActiveCovenantID()
	if(_NewCovenantID > 0 and CON.Covenants:Contains(_NewCovenantID)) then
		CON.Player.Unit:SetCovenant(CON.Covenants:GetCovenant(_NewCovenantID))
		CON:Info(LogCategory, "Updated player covenant information based on COVENANT_CHOSEN event")
	end
end