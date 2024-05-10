local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Spec'

Spec = XFC.Object:newChildConstructor()

--#region Constructors
function Spec:new()
    local object = Spec.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    return object
end
--#endregion

--#region Print
function Spec:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function Spec:GetIconID()
    return self.iconID
end

function Spec:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion