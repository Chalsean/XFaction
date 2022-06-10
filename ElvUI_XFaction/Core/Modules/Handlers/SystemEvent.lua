local XFG, E, L, V, P, G = unpack(select(2, ...))
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
		XFG:RegisterEvent('PLAYER_ENTERING_WORLD', self.CallbackEnterWorld)
        XFG:Info(LogCategory, "Registered for PLAYER_ENTERING_WORLD events")
        XFG:RegisterEvent('PLAYER_LOGOUT', self.CallbackLogout)
        XFG:Info(LogCategory, "Registered for PLAYER_LOGOUT events")
        XFG:Hook('ReloadUI', self.CallbackReloadUI, true)
        XFG:Info(LogCategory, "Created hook for pre-ReloadUI")
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
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SystemEvent:CallbackEnterWorld(inInitialLogin, inReloadUI)
    
end

function SystemEvent:CallbackLogout()
    if(XFG.DB.UIReload) then 
        -- Backup information on reload to be restored
        XFG.Confederate:CreateBackup()
        XFG.Network.BNet.Friends:CreateBackup()
        XFG.Network.BNet.Links:CreateBackup()
    else
        local _NewMessage = LogoutMessage:new()
        _NewMessage:Initialize()
        _NewMessage:SetType(XFG.Network.Type.BROADCAST)
        _NewMessage:SetSubject(XFG.Network.Message.Subject.LOGOUT)
        if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
            _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
        end
        _NewMessage:SetGuildID(XFG.Player.Guild:GetID())
        _NewMessage:SetUnitName(XFG.Player.Unit:GetUnitName())
        _NewMessage:SetData(' ')
        XFG.Network.Outbox:Send(_NewMessage)
    end    
end

function SystemEvent:CallbackReloadUI()
    if(XFG.DB ~= nil) then
        XFG.DB.UIReload = true
    end
end