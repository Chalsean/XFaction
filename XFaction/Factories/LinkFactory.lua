local XFG, G = unpack(select(2, ...))
local ObjectName = 'LinkFactory'
local LogCategory = 'FLink'

LinkFactory = Factory:newChildConstructor()

function LinkFactory:new()
    local _Object = LinkFactory.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function LinkFactory:CreateNew()
    local _NewLink = Link:new()
    return _NewLink
end