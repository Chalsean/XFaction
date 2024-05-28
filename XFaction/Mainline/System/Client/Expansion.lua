local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Expansion'

--#region Properties
function XFC.Expansion:MaxLevel()
    return 70
end
--#endregion