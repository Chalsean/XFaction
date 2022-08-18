local XFG, G = unpack(select(2, ...))
local ObjectName = 'FriendFactory'

FriendFactory = Factory:newChildConstructor()

function FriendFactory:new()
    local _Object = FriendFactory.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function FriendFactory:CreateNew()
    local _NewFriend = Friend:new()
    _NewFriend:Initialize()
    return _NewFriend
end