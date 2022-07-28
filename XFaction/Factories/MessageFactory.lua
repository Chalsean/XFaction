local XFG, G = unpack(select(2, ...))
local ObjectName = 'MessageFactory'
local LogCategory = 'FMessage'

MessageFactory = Factory:newChildConstructor()

function MessageFactory:new()
    local _Object = MessageFactory.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function MessageFactory:CreateNew()
    local _NewMessage = Message:new()
    _NewMessage:Initialize()
    return _NewMessage
end