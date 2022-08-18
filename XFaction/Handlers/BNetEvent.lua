local XFG, G = unpack(select(2, ...))

BNetEvent = Object:newChildConstructor()

function BNetEvent:new()
    local _Object = BNetEvent.parent.new(self)
    _Object.__name = 'BNetEvent'
    return _Object
end

function BNetEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG:CreateEvent('Friend', 'BN_FRIEND_INFO_CHANGED', XFG.Handlers.BNetEvent.CallbackFriendInfo, true, true)
		self:IsInitialized(true)
	end
end

-- The friend API leaves much to be desired, it spams and will give you invalid indexes like 0
-- Making the index kind of worthless, it's easier to just scan
function BNetEvent:CallbackFriendInfo()
    XFG.Friends:CheckFriends()
end