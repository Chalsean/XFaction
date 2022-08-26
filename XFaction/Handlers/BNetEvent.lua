local XFG, G = unpack(select(2, ...))
local ObjectName = 'BNetHandler'

BNetEvent = Object:newChildConstructor()

function BNetEvent:new()
    local _Object = BNetEvent.parent.new(self)
    _Object.__name = 'BNetEvent'
    return _Object
end

function BNetEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()   
        XFG.Events:Add('Friend', 'BN_FRIEND_INFO_CHANGED', XFG.Handlers.BNetEvent.CallbackFriendInfo, true, true)
        XFG.Events:Add('BNetConnect', 'BN_CONNECTED', XFG.Handlers.BNetEvent.CallbackConnected, true, true)
        XFG.Events:Add('BNetDisconnect', 'BN_DISCONNECTED', XFG.Handlers.BNetEvent.CallbackDisconnected, true, true)
        if(BNConnected()) then
            XFG:Info(ObjectName, 'Connected to BNet')
        else
            XFG:Warn(ObjectName, 'Not connected to BNet')
        end
		self:IsInitialized(true)
	end
end

-- The friend API leaves much to be desired, it spams and will give you invalid indexes like 0
-- Making the index kind of worthless, it's easier to just scan
function BNetEvent:CallbackFriendInfo()
    XFG.Friends:CheckFriends()
end

function BNetEvent:CallbackConnected(inFlag)
    XFG:Info(ObjectName, 'Connected to BNet')
end

function BNetEvent:CallbackDisconnected(inFlag, inNotify)
    XFG:Warn(ObjectName, 'Disconnected from BNet')
end