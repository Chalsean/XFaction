local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'BNetEvent'
local LogCategory = 'HEBNet'

BNetEvent = {}

function BNetEvent:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Initialized = false

    return _Object
end

function BNetEvent:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
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

function BNetEvent:GetKey()
    return self._Key
end

function BNetEvent:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function BNetEvent:CallbackBNetConnected()
    XFG:Info(LogCategory, "Enabling BNet due to BN_CONNECTED")
    XFG.Network.BNet.Comm:CanBNet(true)
end

function BNetEvent:CallbackBNetDisconnected()
    XFG:Info(LogCategory, "Disabling BNet due to BN_DISCONNECTED")
    XFG.Network.BNet.Comm:CanBNet(false)
end

-- The friend API leaves much to be desired, you essentially have to keep scanning
-- This also spams, so only uncomment the logging to troubleshoot
function BNetEvent:CallbackFriendInfo(inFriendIndex)
    --XFG:Debug(LogCategory, "Scanning BNet friends due to BN_FRIEND_INFO_CHANGED")
    XFG.Network.BNet.Friends:Reset()
    XFG.Network.BNet.Friends:Initialize()
    DT:ForceUpdate_DataText(XFG.DataText.Bridge.Name)
end
