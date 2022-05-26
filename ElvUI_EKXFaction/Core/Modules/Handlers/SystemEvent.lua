local EKX, E, L, V, P, G = unpack(select(2, ...))
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
		EKX:RegisterEvent('PLAYER_ENTERING_WORLD', self.CallbackEnterWorld)
        EKX:Info(LogCategory, "Registered for PLAYER_ENTERING_WORLD events")
        EKX:RegisterEvent('PLAYER_LOGOUT', self.CallbackLogout)
        EKX:Info(LogCategory, "Registered for PLAYER_LOGOUT events")
        EKX:Hook('ReloadUI', self.CallbackReloadUI, true)
        EKX:Info(LogCategory, "Created hook for pre-ReloadUI")
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
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SystemEvent:CallbackEnterWorld(inInitialLogin, inReloadUI)
    if(inInitialLogin) then
        EKX.UIReload = false
    end
end

function SystemEvent:CallbackLogout()
    if(EKX.UIReload) then return end
    EKX.Player.Unit:IsOnline(false)
    EKX.Network.Sender:BroadcastUnitData(EKX.Player.Unit)
end

function SystemEvent:CallbackReloadUI()
    EKX.UIReload = true
end