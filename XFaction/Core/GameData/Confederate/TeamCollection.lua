local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'TeamCollection'

XFC.TeamCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TeamCollection:new()
	local object = XFC.TeamCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.TeamCollection:Initialize()
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
function XFC.TeamCollection:SetObjectFromString(inString)
	assert(type(inString) == 'string')
	local teamInitial, teamName = inString:match('XFt:(%a-):(%a+)')
	if(teamInitial ~= nil and teamName ~= nil) then
		self:Add(teamInitial, teamName)
	end
end
--#endregion

--#region Hash
function XFC.TeamCollection:Add(inTeamInitials, inTeamName)
	assert(type(inTeamInitials) == 'string')
	assert(type(inTeamName) == 'string')
	if(not self:Contains(inTeamInitials)) then
		local team = XFC.Team:new()
		team:Initialize()
		team:SetName(inTeamName)
		team:SetInitials(inTeamInitials)
		team:SetKey(inTeamInitials)
		self.parent.Add(self, team)
		XF:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:GetName())
	end
end
--#endregion