local XFG, G = unpack(select(2, ...))
local ObjectName = 'ColorCollection'

ColorCollection = ObjectCollection:newChildConstructor()

function ColorCollection:new()
    local object = ColorCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function ColorCollection:Add(inName, inMixin)
    local color = Color:new()
    color:Initialize()
    color:SetKey(inName)
    color:SetName(inName)
    color:SetMixin(inMixin)
    self.parent.Add(self, color)
end