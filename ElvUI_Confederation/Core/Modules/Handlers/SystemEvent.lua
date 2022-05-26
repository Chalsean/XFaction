local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'SystemEvent'
local LogCategory = 'HESystem'
local TotalChannels = 10

SystemEvent = {}

function SystemEvent:new(inObject)
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

function SystemEvent:Initialize()
	if(self:IsInitialized() == false) then
		CON:RegisterEvent('PLAYER_ENTERING_WORLD', self.CallbackEnterWorld)
        CON:Info(LogCategory, "Registered for PLAYER_ENTERING_WORLD events")
        CON:RegisterEvent('PLAYER_LOGOUT', self.CallbackLogout)
        CON:Info(LogCategory, "Registered for PLAYER_LOGOUT events")
        CON:Hook('ReloadUI', self.CallbackReloadUI, true)
        CON:Info(LogCategory, "Created hook for pre-ReloadUI")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SystemEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function SystemEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SystemEvent:CallbackEnterWorld(inInitialLogin, inReloadUI)
    if(inInitialLogin) then
        CON.UIReload = false
    end
end

function SystemEvent:CallbackLogout()
    if(CON.UIReload) then return end
    CON.Player.Unit:IsOnline(false)
    CON.Network.Sender:BroadcastUnitData(CON.Player.Unit)
end

function SystemEvent:CallbackReloadUI()
    CON.UIReload = true
end