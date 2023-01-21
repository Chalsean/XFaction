local XFG, G = unpack(select(2, ...))

BNetEvent = Object:newChildConstructor()

--#region Constructors
function BNetEvent:new()
    local object = BNetEvent.parent.new(self)
    object.__name = 'BNetEvent'
    return object
end
--#endregion

--#region Initializers
function BNetEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFG.Events:Add({name = 'Friend', 
                        event = 'BN_FRIEND_INFO_CHANGED', 
                        callback = XFG.Handlers.BNetEvent.CallbackFriendInfo, 
                        instance = true,
                        start = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
-- The friend API leaves much to be desired, it spams and will give you invalid indexes like 0
-- Making the index kind of worthless, it's easier to just scan
function BNetEvent:CallbackFriendInfo()
    XFG.Friends:CheckFriends()
end
--#endregion