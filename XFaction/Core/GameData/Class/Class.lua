local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Class'

XFC.Class = XFC.Object:newChildConstructor()

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

--#region Properties
function XFC.Class:APIName(inAPIName)
    assert(type(inAPIName) == 'string' or inAPIName == nil)
    if(inAPIName ~= nil) then
        self.apiName = inAPIName
    end
    return self.apiName
end

function XFC.Class:RGBPercent()
    return self.r / 255, self.g / 255, self.b / 255
end

function XFC.Class:RGB(inR, inG, inB)
    assert((type(inR) == 'number' and type(inG) == 'number' and type(inB) == 'number') or (inR == nil and inG == nil and inB == nil))
    if(inR ~= nil) then
        self.r = inR
        self.g = inG
        self.b = inB
    end
    return self.r, self.g, self.b
end

function XFC.Class:Hex(inHex)
    assert(type(inHex) == 'string' or inHex == nil)
    if(inHex ~= nil) then
        self.hex = inHex
    end
    return self.hex
end
--#endregion

--#region Methods
function XFC.Class:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  apiName (' .. type(self.apiName) .. '): ' .. tostring(self.apiName))
    XF:Debug(self:ObjectName(), '  r (' .. type(self.r) .. '): ' .. tostring(self.r))
    XF:Debug(self:ObjectName(), '  g (' .. type(self.g) .. '): ' .. tostring(self.g))
    XF:Debug(self:ObjectName(), '  b (' .. type(self.b) .. '): ' .. tostring(self.b))
    XF:Debug(self:ObjectName(), '  hex (' .. type(self.hex) .. '): ' .. tostring(self.hex))
end
--#endregion