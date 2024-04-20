local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'TeamCollection'

XFC.TeamCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TeamCollection:new()
	local object = XFC.TeamCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.TeamCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		for initials, name in pairs (XF.Settings.Confederate.DefaultTeams) do
			local team = XFC.Team:new()
			team:Initialize()
			team:Name(name)
			team:Initials(initials)
			team:Key(initials)
			self:Add(team)
			XF:Info(self:ObjectName(), 'Initialized team [%s:%s]', team:Initials(), team:Name())
		end
		self:IsInitialized(true)
	end
end
--#endregion