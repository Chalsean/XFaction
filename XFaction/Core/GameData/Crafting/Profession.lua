local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Profession'

XFC.Profession = Object:newChildConstructor()

--#region Constructors
function XFC.Profession:new()
    local object = XFC.Profession.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    return object
end
--#endregion

--#region Print
function XFC.Profession:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function XFC.Profession:GetIconID()
    return self.iconID
end

function XFC.Profession:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion