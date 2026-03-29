local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RaceCollection'

XFC.RaceCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.RaceCollection:new()
	local object = XFC.RaceCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.RaceCollection:Get(inID)
	assert(type(inID) == 'number')
	if (not self:Contains(inID)) then
		self:Add(inID)
	end
	return self.parent.Get(self, inID)
end

function XFC.RaceCollection:Add(inRace)
	assert(type(inRace) == 'table' and inRace.__name == 'Race' or type(inRace) == 'number')
	if (type(inRace) == 'number') then
		local name = XFF.RaceInfo(inRace)
		local faction = XFF.RaceFaction(inRace)
		local race = XFC.Race:new()
		race:Initialize()
		race:Key(inRace)
		race:ID(inRace)
		race:Name(name.raceName)		
		race:Faction(XFO.Factions:Get(faction.name))
		self.parent.Add(self, race)
		XF:Info(self:ObjectName(), 'Initialized race [%d:%s:%s]', race:ID(), race:Name(), race:Faction():Name())
	else
		self.parent.Add(self, inRace)
	end
end
--#endregion