local XFG, G = unpack(select(2, ...))
local ObjectName = 'TeamCollection'

TeamCollection = ObjectCollection:newChildConstructor()

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
		for initials, name in pairs (XFG.Settings.Confederate.DefaultTeams) do
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
		team:SetName(inTeamName)
		team:SetInitials(inTeamInitials)
		team:SetKey(inTeamInitials)
		self.parent.Add(self, team)
		XFG:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:GetName())
	end
end
--#endregion