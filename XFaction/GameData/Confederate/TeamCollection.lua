local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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
        self:Add('?', 'Unknown')
		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.TeamCollection:Deserialize(inString)
	assert(type(inString) == 'string')
	local initials, name = inString:match('XFt:(%a-):(%a+)')
	if(initials ~= nil and name ~= nil) then
		self:Add(initials, name)
	end
end

function XFC.TeamCollection:Add(inTeam, inName)
	assert(type(inTeam) == 'table' and inTeam.__name == 'Team' or type(inTeam) == 'string')
	assert(type(inName) == 'string' or inName == nil)
    if(type(inTeam) == 'table') then
        self.parent.Add(self, inTeam)
    elseif(not self:Contains(inTeam)) then
		local team = XFC.Team:new()
		team:Initialize()
		team:Name(inName)
		team:Initials(inTeam)
		team:Key(inTeam)
		self.parent.Add(self, team)
		XF:Info(ObjectName, 'Initialized team [%s:%s]', team:Initials(), team:Name())
	end
end
--#endregion