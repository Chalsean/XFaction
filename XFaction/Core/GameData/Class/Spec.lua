local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Spec'

XFC.Spec = Object:newChildConstructor()

--#region Constructors
function XFC.Spec:new()
    local object = XFC.Spec.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    return object
end
--#endregion

--#region Print
function XFC.Spec:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function XFC.Spec:GetIconID()
    return self.iconID
end

function XFC.Spec:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion