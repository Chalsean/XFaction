local XFG, G = unpack(select(2, ...))
local ObjectName = 'Team'

Team = Object:newChildConstructor()

function Team:new()
    local _Object = Team.parent.new(self)
    _Object.__name = ObjectName
    _Object._Initials = nil
    return _Object
end

function Team:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _Initials (' .. type(self._Initials) .. '): ' .. tostring(self._Initials))
    end
end

function Team:GetInitials()
    return self._Initials
end

function Team:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self._Initials = inInitials
end