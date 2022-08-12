local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildMessageFactory'
local LogCategory = 'FGuildMessage'

GuildMessageFactory = Factory:newChildConstructor()

function GuildMessageFactory:new()
    local _Object = GuildMessageFactory.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function GuildMessageFactory:CreateNew()
    local _NewMessage = GuildMessage:new()
    _NewMessage:Initialize()
    return _NewMessage
end