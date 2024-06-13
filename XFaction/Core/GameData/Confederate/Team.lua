local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Team'

Team = XFC.Object:newChildConstructor()

--#region Constructors
function Team:new()
    local object = Team.parent.new(self)
    object.__name = ObjectName
    object.initials = nil
    return object
end
--#endregion

--#region Print
function Team:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
end
--#endregion

--#region Accessors
function Team:GetInitials()
    return self.initials
end

function Team:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self.initials = inInitials
end
--#endregion