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
		if(#XFG.Cache.Teams > 0) then
			self:IsCached(true)
			for _, data in ipairs (XFG.Cache.Teams) do
				self:Add(data.initials, data.name)
			end
		else
			for initials, name in pairs (XFG.Settings.Teams) do
				self:Add(initials, name)
			end
		end

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
	local teamInitial, teamName = inString:match('XFt:(%a):(%a+)')
	XFG.Cache.Teams[#XFG.Cache.Teams + 1] = {
		initials = teamInitial,
		name = teamName,
	}
end
--#endregion

--#region Hash
function TeamCollection:Add(inTeamInitials, inTeamName)
	assert(type(inTeamInitials) == 'string')
	assert(type(inTeamName) == 'string')

	-- If team does not exist, create
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