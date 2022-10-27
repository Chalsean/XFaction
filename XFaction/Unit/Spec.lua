local XFG, G = unpack(select(2, ...))
local ObjectName = 'Spec'

Spec = Object:newChildConstructor()

--#region Constructors
function Spec:new()
    local object = Spec.parent.new(self)
    object.__name = ObjectName
    object.ID = nil
    object.iconID = nil
    return object
end
--#endregion

--#region Print
function Spec:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function Spec:GetID()
    return self.ID
end

function Spec:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Spec:GetIconID()
    return self.iconID
end

function Spec:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion