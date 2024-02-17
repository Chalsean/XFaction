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
			local team = XFC.Team:new()
			team:Initialize()
			team:SetName(name)
			team:SetInitials(initials)
			team:SetKey(initials)
			self:Add(team)
			XF:Info(ObjectName, 'Initialized team [%s:%s]', team:GetInitials(), team:GetName())
		end
		self:IsInitialized(true)
	end
end
--#endregion