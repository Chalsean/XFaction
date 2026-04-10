local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Channel'

XFC.Channel = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Channel:new()
    local object = XFC.Channel.parent.new(self)
    object.__name = 'Channel'
    return object
end
--#endregion

--#region Methods
function XFC.Channel:IsGuild()
    return self:Key() == 'GUILD'
end
--#endregion