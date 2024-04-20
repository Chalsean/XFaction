local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Team'

XFC.Team = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Team:new()
    local object = XFC.Team.parent.new(self)
    object.__name = ObjectName
	object.initials = nil
    return object
end
--#endregion

--#region Properties
function XFC.Team:Initials(inInitials)
	assert(type(inInitials) == 'string' or inInitials == nil, 'argument must be string or nil')
	if(inInitials ~= nil) then
		self.initials = inInitials
	end
	return self.initials
end
--#endregion

--#region Methods
function XFC.Team:Deserialize(inString)
	assert(type(inString) == 'string')
	local teamInitial, teamName = inString:match('XFt:(%a-):(%a+)')
	if(teamInitial ~= nil and teamName ~= nil) then
		self:Initialize()
		self:Name(teamName)
		self:Initials(teamInitial)
		self:Key(teamInitial)
        XF:Info(self:ObjectName(), 'Initialized team [%s:%s]', self:Initials(), self:Name())
	end
end
--#endregion