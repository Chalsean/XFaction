local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Tag'

XFC.Tag = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Tag:new()
    local object = XFC.Tag.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion