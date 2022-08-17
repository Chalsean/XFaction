local XFG, G = unpack(select(2, ...))
local ObjectName = 'UnitFactory'

UnitFactory = Factory:newChildConstructor()

function UnitFactory:new()
    local _Object = UnitFactory.parent.new(self)
    self.__name = ObjectName
    return _Object
end

function UnitFactory:CreateNew()
    local _NewUnit = Unit:new()
    return _NewUnit
end