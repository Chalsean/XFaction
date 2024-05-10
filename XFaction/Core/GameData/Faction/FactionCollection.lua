local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'FactionCollection'

FactionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function FactionCollection:new()
	local object = FactionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function FactionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for i, factionName in pairs (XF.Settings.Factions) do
			local faction = Faction:new()
			faction:Name(factionName)
			faction:Initialize()
			faction:Key(i)
			self:Add(faction)
			XF:Info(ObjectName, 'Initialized faction [%d:%s]', faction:Key(), faction:Name())
		end		
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function FactionCollection:GetByName(inName)
	assert(type(inName) == 'string')
	for _, faction in self:Iterator() do
		if(faction:Name() == inName) then
			return faction
		end
	end
end

function FactionCollection:GetByID(inID)
	assert(type(inID) == 'string')
	for _, faction in self:Iterator() do
		if(faction:ID() == inID) then
			return faction
		end
	end
end
--#endregion