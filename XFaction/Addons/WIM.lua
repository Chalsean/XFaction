local XFG, G = unpack(select(2, ...))
local ObjectName = 'WIM'

XFWIM = Addon:newChildConstructor()

--#region Constructors
function XFWIM:new()
    local object = XFWIM.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion