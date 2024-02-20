local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Spec'

XFC.Spec = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Spec:new()
    local object = XFC.Spec.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.class = nil
    return object
end
--#endregion

--#region Print
function XFC.Spec:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
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

function XFC.Spec:HasClass()
    return self.class ~= nil
end

function XFC.Spec:GetClass()
    return self.class
end

function XFC.Spec:SetClass(inClass)
    assert(type(inClass) == 'table' and inClass.__name ~= nil and inClass.__name == 'Class', 'argument must be Class object')
    self.class = inClass
end
--#endregion