local XFG, G = unpack(select(2, ...))
local ObjectName = 'Profession'

Profession = Object:newChildConstructor()

--#region Constructors
function Profession:new()
    local object = Profession.parent.new(self)
    object.__name = ObjectName
    object.ID = 0
    object.iconID = nil
    return object
end
--#endregion

--#region Print
function Profession:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
end
--#endregion

--#region Accessors
function Profession:GetID()
    return self.ID
end

function Profession:SetID(inProfessionID)
    assert(type(inProfessionID) == 'number')
    self.ID = inProfessionID
end

function Profession:GetIconID()
    return self.iconID
end

function Profession:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end
--#endregion