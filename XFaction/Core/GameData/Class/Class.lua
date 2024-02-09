local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Class'

XFC.Class = Object:newChildConstructor()

--#region Constructors
function XFC.Class:new()
    local object = XFC.Class.parent.new(self)
    object.__name = ObjectName
    object.apiName = nil
    object.r = nil
    object.g = nil
    object.b = nil
    object.hex = nil
    return object
end
--#endregion

--#region Print
function XFC.Class:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
    XF:Debug(ObjectName, '  r (' .. type(self.r) .. '): ' .. tostring(self.r))
    XF:Debug(ObjectName, '  g (' .. type(self.g) .. '): ' .. tostring(self.g))
    XF:Debug(ObjectName, '  b (' .. type(self.b) .. '): ' .. tostring(self.b))
    XF:Debug(ObjectName, '  hex (' .. type(self.hex) .. '): ' .. tostring(self.hex))
end
--#endregion

--#region Accessors
function XFC.Class:GetAPIName()
    return self.apiName
end

function XFC.Class:SetAPIName(inAPIName)
    assert(type(inAPIName) == 'string')
    self.apiName = inAPIName
end

function XFC.Class:GetRGB()
    return self.r, self.g, self.b
end

function XFC.Class:GetRGBPercent()
    return self.r / 255, self.g / 255, self.b / 255
end

function XFC.Class:SetRGB(inR, inG, inB)
    assert(type(inR) == 'number')
    assert(type(inG) == 'number')
    assert(type(inB) == 'number')
    self.r = inR
    self.g = inG
    self.b = inB
end

function XFC.Class:SetHex(inHex)
    assert(type(inHex) == 'string')
    self.hex = inHex
end

function XFC.Class:GetHex()
    return self.hex
end
--#endregion