local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Dungeon'

XFC.Dungeon = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Dungeon:new()
    local object = XFC.Dungeon.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion