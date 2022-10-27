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
				local team = Team:new()
				team:Initialize()
				team:SetName(data.name)
				team:SetInitials(data.initials)
				team:SetKey(data.initials)
				XFG:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:GetName())
			end
		else
			for initials, name in pairs (XFG.Settings.Teams) do
				local team = Team:new()
				team:Initialize()
				team:SetName(name)
				team:SetInitials(initials)
				team:SetKey(initials)
				self:Add(team)
				XFG:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:GetName())
			end
		end

		for initials, name in pairs (XFG.Settings.Confederate.DefaultTeams) do
			if(not self:Contains(initials)) then
				local team = Team:new()
				team:Initialize()
				team:SetName(name)
				team:SetInitials(initials)
				team:SetKey(initials)
				self:Add(team)
				XFG:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:GetName())
			end
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