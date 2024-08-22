local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Region'

XFC.Region = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Region:new()
    local object = XFC.Region.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion