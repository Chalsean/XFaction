local XF, G = unpack(select(2, ...))
local ObjectName = 'WIM'

XFC.WIM = Addon:newChildConstructor()

--#region Constructors
function XFC.WIM:new()
    local object = XFC.WIM.parent.new(self)
    object.__name = ObjectName
    return object
end

function XFC.WIM:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:API(WIM)
        self:IsLoaded(true)
        XF:Info(self:ObjectName(), 'WIM loaded successfully')
		self:IsInitialized(true)
	end
end
--#endregion