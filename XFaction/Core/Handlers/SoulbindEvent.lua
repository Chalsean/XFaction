local XFG, G = unpack(select(2, ...))
local ObjectName = 'SoulbindEvent'
local LogCategory = 'HESoulbind'

SoulbindEvent = {}

function SoulbindEvent:new(inObject)
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

function SoulbindEvent:Initialize()
	if(self:IsInitialized() == false) then
		XFG:RegisterEvent('SOULBIND_ACTIVATED', self.CallbackSoulbindActivated)
        XFG:Info(LogCategory, "Registered for SOULBIND_ACTIVATED events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function SoulbindEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function SoulbindEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function SoulbindEvent:CallbackSoulbindActivated()
    local _SoulbindID = C_Soulbinds.GetActiveSoulbindID()
    if(XFG.Soulbinds:Contains(_SoulbindID)) then
        local _Soulbind = XFG.Soulbinds:GetSoulbind(_SoulbindID)
        XFG.Player.Unit:SetSoulbind(_Soulbind)
        XFG:Info(LogCategory, "Updated player soulbind to %s based on SOULBIND_ACTIVATED event", _Soulbind:GetName())
        XFG.DataText.Soulbind:RefreshBroker()
    elseif(_SoulbindID ~= 0) then -- 0 is some kind of special timing state value
        XFG:Error(LogCategory, "Active Soulbind not found in SoulbindCollection: " .. tostring(_SoulbindID))
    end
end