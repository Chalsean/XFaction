local XF, G = unpack(select(2, ...))
local ObjectName = 'Profession'

Profession = Object:newChildConstructor()

--#region Constructors
function Profession:new()
    local object = Profession.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    return object
end
--#endregion

--#region Print
function Profession:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function Profession:GetIconID()
    return self.iconID
end

function Profession:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion