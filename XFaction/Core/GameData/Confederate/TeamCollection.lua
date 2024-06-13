local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TeamCollection'

TeamCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function TeamCollection:new()
	local object = TeamCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function TeamCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		for initials, name in pairs (XF.Settings.Confederate.DefaultTeams) do
			self:Add(initials, name)
		end
		self:IsInitialized(true)
	end
end
--#endregion

--#region DataSet
function TeamCollection:SetObjectFromString(inString)
	assert(type(inString) == 'string')
	local teamInitial, teamName = inString:match('XFt:(%a-):(%a+)')
	if(teamInitial ~= nil and teamName ~= nil) then
		self:Add(teamInitial, teamName)
	end
end
--#endregion

--#region Hash
function TeamCollection:Add(inTeamInitials, inTeamName)
	assert(type(inTeamInitials) == 'string')
	assert(type(inTeamName) == 'string')
	if(not self:Contains(inTeamInitials)) then
		local team = Team:new()
		team:Initialize()
		team:Name(inTeamName)
		team:SetInitials(inTeamInitials)
		team:Key(inTeamInitials)
		self.parent.Add(self, team)
		XF:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:Name())
	end
end
--#endregion