local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'WIM'

XFC.WIM = XFC.Addon:newChildConstructor()

--#region Constructors
function XFC.WIM:new()
    local object = XFC.WIM.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.WIM:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        XFO.WIM:API(WIM)        
        XFO.WIM:IsLoaded(true)
        XF:Info(self:ObjectName(), 'WIM loaded successfully')
		self:IsInitialized(true)
	end
end
--#endregion