local XFG, G = unpack(select(2, ...))
local ObjectName = 'Team'

Team = Object:newChildConstructor()

function Team:new()
    local object = Team.parent.new(self)
    object.__name = ObjectName
    object.initials = nil
    return object
end

function Team:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
    end
end

function Team:GetInitials()
    return self.initials
end

function Team:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self.initials = inInitials
end