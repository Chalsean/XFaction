local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Team'

XFC.Team = Object:newChildConstructor()

--#region Constructors
function XFC.Team:new()
    local object = XFC.Team.parent.new(self)
    object.__name = ObjectName
    object.initials = nil
    return object
end
--#endregion

--#region Print
function XFC.Team:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
end
--#endregion

--#region Accessors
function XFC.Team:GetInitials()
    return self.initials
end

function XFC.Team:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self.initials = inInitials
end
--#endregion

--#region Serialize
function XFC.Team:Deserialize(inString)
	assert(type(inString) == 'string')
	local teamInitial, teamName = inString:match('XFt:(%a-):(%a+)')
	if(teamInitial ~= nil and teamName ~= nil) then
		team:Initialize()
		team:SetName(inTeamName)
		team:SetInitials(inTeamInitials)
		team:SetKey(inTeamInitials)
        XF:Info(ObjectName, 'Initialized team [%s:%s]', self:GetInitials(), self:GetName())
	end
end
--#endregion