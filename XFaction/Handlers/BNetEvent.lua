local XFG, G = unpack(select(2, ...))

BNetEvent = Object:newChildConstructor()

function BNetEvent:new()
    local object = BNetEvent.parent.new(self)
    object.__name = 'BNetEvent'
    return object
end

function BNetEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add('Friend', 'BN_FRIEND_INFO_CHANGED', XFG.Handlers.BNetEvent.CallbackFriendInfo, true, true)
		self:IsInitialized(true)
	end
end

-- The friend API leaves much to be desired, it spams and will give you invalid indexes like 0
-- Making the index kind of worthless, it's easier to just scan
function BNetEvent:CallbackFriendInfo()
    XFG.Friends:CheckFriends()
end