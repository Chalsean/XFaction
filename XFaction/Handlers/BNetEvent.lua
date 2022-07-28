local XFG, G = unpack(select(2, ...))
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
        XFG:CreateEvent('Friend', 'BN_FRIEND_INFO_CHANGED', XFG.Handlers.BNetEvent.CallbackFriendInfo, true, true)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function BNetEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
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

-- The friend API leaves much to be desired, it spams and will give you invalid indexes like 0
-- Making the index kind of worthless, it's easier to just scan
function BNetEvent:CallbackFriendInfo()
    XFG.Friends:CheckFriends()
end
