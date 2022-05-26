local CON, E, L, V, P, G = unpack(select(2, ...))
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
		CON:RegisterEvent('BN_CONNECTED', self.CallbackBNetConnected)
        CON:Info(LogCategory, "Registered for BN_CONNECTED events")
        CON:RegisterEvent('BN_DISCONNECTED', self.CallbackBNetDisconnected)
        CON:Info(LogCategory, "Registered for BN_DISCONNECTED events")
        CON:RegisterEvent('BN_FRIEND_INFO_CHANGED', self.CallbackFriendInfo)
        CON:Info(LogCategory, "Registered for BN_FRIEND_INFO_CHANGED events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function BNetEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
        CON.Network.Sender:CanBNet(true)
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function BNetEvent:Print()
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function BNetEvent:CallbackBNetConnected()
    CON:Info(LogCategory, "Enabling BNet due to BN_CONNECTED")
    CON.Network.Sender:CanBNet(true)
end

function BNetEvent:CallbackBNetDisconnected()
    CON:Info(LogCategory, "Disabling BNet due to BN_DISCONNECTED")
    CON.Network.Sender:CanBNet(false)
end

-- The friend API leaves much to be desired, you essentially have to keep scanning
function BNetEvent:CallbackFriendInfo(inFriendIndex)
    CON:Debug(LogCategory, "Scanning BNet friends due to BN_FRIEND_INFO_CHANGED")
    CON.Network.BNet.Friends:Reset()
    CON.Network.BNet.Friends:Initialize()
end