local XFG, G = unpack(select(2, ...))
local ObjectName = 'Team'

Team = Object:newChildConstructor()

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
    XFG:Debug(ObjectName, '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
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