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

--#region Methods
function XFC.HeroCollection:CallbackHeroChanged()
	local self = XFO.Heros
	try(function ()
		local id = XFF.SpecHeroID()
		if(self:Contains(id)) then
			XF.Player.Unit:Hero(self:Get(id))
		end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion