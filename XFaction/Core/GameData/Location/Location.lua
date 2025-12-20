local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Location'

XFC.Location = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Location:new()
    local object = XFC.Location.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.Location:Serialize()
    if(self:ID() ~= nil) then
        return self:ID()
    end
    return self:Key()
end
--#endregion