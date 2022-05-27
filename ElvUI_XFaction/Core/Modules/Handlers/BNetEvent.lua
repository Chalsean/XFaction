local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'BNetEvent'
local LogCategory = 'HEBNet'
local TotalChannels = 10

BNetEvent = {}

function BNetEvent:new(inObject)
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

function BNetEvent:Initialize()
	if(self:IsInitialized() == false) then
		XFG:RegisterEvent('BN_CONNECTED', self.CallbackBNetConnected)
        XFG:Info(LogCategory, "Registered for BN_CONNECTED events")
        XFG:RegisterEvent('BN_DISCONNECTED', self.CallbackBNetDisconnected)
        XFG:Info(LogCategory, "Registered for BN_DISCONNECTED events")
        XFG:RegisterEvent('BN_FRIEND_INFO_CHANGED', self.CallbackFriendInfo)
        XFG:Info(LogCategory, "Registered for BN_FRIEND_INFO_CHANGED events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function BNetEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
        XFG.Network.Sender:CanBNet(true)
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function BNetEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function BNetEvent:CallbackBNetConnected()
    XFG:Info(LogCategory, "Enabling BNet due to BN_CONNECTED")
    XFG.Network.Sender:CanBNet(true)
end

function BNetEvent:CallbackBNetDisconnected()
    XFG:Info(LogCategory, "Disabling BNet due to BN_DISCONNECTED")
    XFG.Network.Sender:CanBNet(false)
end

-- The friend API leaves much to be desired, you essentially have to keep scanning
function BNetEvent:CallbackFriendInfo(inFriendIndex)
    XFG:Debug(LogCategory, "Scanning BNet friends due to BN_FRIEND_INFO_CHANGED")
    XFG.Network.BNet.Friends:Reset()
    XFG.Network.BNet.Friends:Initialize()
end