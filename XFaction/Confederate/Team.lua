local XFG, G = unpack(select(2, ...))

Team = Object:newChildConstructor()

function Team:new()
    local _Object = Team.parent.new(self)
    _Object.__name = 'Team'
    _Object._Initials = nil
    return _Object
end

function Team:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _Initials (' .. type(self._Initials) .. '): ' .. tostring(self._Initials))
end

function Team:GetInitials()
    return self._Initials
end

function Team:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self._Initials = inInitials
    return self:GetInitials()
end