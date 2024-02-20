local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'BNetEvent'

XFC.BNetEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.BNetEvent:new()
    local object = XFC.BNetEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.BNetEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.Events:Add({name = 'Friend', 
                        event = 'BN_FRIEND_INFO_CHANGED', 
                        callback = XFO.Friends.CheckFriends, 
                        instance = true,
                        groupDelta = XF.Settings.Network.BNet.FriendTimer})
		self:IsInitialized(true)
	end
end
--#endregion