local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'WIM'

XFC.WIM = XFC.Addon:newChildConstructor()

--#region Constructors
function XFC.WIM:new()
    local object = XFC.WIM.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.WIM:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.WIM:SetAPI(WIM)        
        XFO.WIM:IsLoaded(true)
        XF:Info(ObjectName, 'WIM loaded successfully')
		self:IsInitialized(true)
	end
end
--#endregion