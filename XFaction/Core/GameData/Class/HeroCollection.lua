local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'HeroCollection'

-- Additional logic can be found in the mainline branch
XFC.HeroCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.HeroCollection:new()
    local object = XFC.HeroCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion