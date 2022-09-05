local XFG, G = unpack(select(2, ...))
local ObjectName = 'Color'

Color = Object:newChildConstructor()

function Color:new()
    local object = Color.parent.new(self)
    object.__name = ObjectName
    object.mixin = nil
    object.r = nil
    object.g = nil
    object.b = nil
    object.hex = nil
    return object
end

function Color:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  r (' .. type(self.r) .. '): ' .. tostring(self.r))
        XFG:Debug(ObjectName, '  g (' .. type(self.g) .. '): ' .. tostring(self.g))
        XFG:Debug(ObjectName, '  b (' .. type(self.b) .. '): ' .. tostring(self.b))
        XFG:Debug(ObjectName, '  hex (' .. type(self.hex) .. '): ' .. tostring(self.hex))
    end
end

function Color:GetMixin()
    return self.mixin
end

function Color:SetMixin(inMixin)
    assert(type(inMixin) == 'table')
    self.mixin = inMixin
    self.r, self.g, self._B = inMixin:GetRGB()
    self.hex = inMixin:GenerateHexColor()
end

function Color:GetRGB()
    return self.r, self.g, self._B
end

function Color:GetRGBPercent()
    return self.r / 255, self.g / 255, self._B / 255
end

function Color:GetHex()
    return self.hex
end