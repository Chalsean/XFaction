local XFG, G = unpack(select(2, ...))
local ObjectName = 'NodeFactory'
local LogCategory = 'FNode'

NodeFactory = Factory:newChildConstructor()

function NodeFactory:new()
    local _Object = NodeFactory.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function NodeFactory:CreateNew()
    local _NewNode = Node:new()
    _NewNode:Initialize()
    return _NewNode
end