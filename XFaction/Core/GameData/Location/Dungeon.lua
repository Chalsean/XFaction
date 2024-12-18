local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

XFC.Dungeon = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Dungeon:new()
    local object = XFC.Dungeon.parent.new(self)
    object.__name = 'Dungeon'
    return object
end
--#endregion