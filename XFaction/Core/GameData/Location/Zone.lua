local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Zone'

XFC.Zone = Object:newChildConstructor()

--#region Constructors
function XFC.Zone:new()
    local object = XFC.Zone.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion