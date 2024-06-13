local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'WIM'

XFWIM = Addon:newChildConstructor()

--#region Constructors
function XFWIM:new()
    local object = XFWIM.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFWIM:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XF.Addons.WIM:SetAPI(WIM)        
        XF.Addons.WIM:IsLoaded(true)
        XF:Info(ObjectName, 'WIM loaded successfully')
		self:IsInitialized(true)
	end
end
--#endregion