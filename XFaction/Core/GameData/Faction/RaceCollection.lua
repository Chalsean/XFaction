local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'RaceCollection'

XFC.RaceCollection = XFC.ObjectCollection:newChildConstructor()

--#region Race List
-- https://wago.tools/db2/ChrRaces
local RaceData =
{
	[1] = "Human,Alliance",
	[2] = "Orc,Horde",
	[3] = "Dwarf,Alliance",
	[4] = "Night Elf,Alliance",
	[5] = "Undead,Horde",
	[6] = "Tauren,Horde",
	[7] = "Gnome,Alliance",
	[8] = "Troll,Horde",
	[9] = "Goblin,Horde",
	[10] = "Blood Elf,Horde",
	[11] = "Draenei,Alliance",
	[22] = "Worgen,Alliance",
	[24] = "Panderan,Neutral",
	[25] = "Panderan,Alliance",
	[26] = "Panderan,Horde",
	[27] = "Nightborne,Horde",
	[28] = "Highmountain Tauren,Horde",
	[29] = "Void Elf,Alliance",
	[30] = "Lightforged Draenei,Alliance",
	[31] = "Zandalari Troll,Horde",
	[32] = "Kul Tiran,Alliance",
	[34] = "Dark Iron Dwarf,Alliance",
	[35] = "Vulpera,Horde",
	[36] = "Mag'har Orc,Horde",
	[37] = "Mechagnome,Alliance",
	[52] = "Dracthyr,Alliance",
	[70] = "Dracthyr,Horde",
    [84] = "Earthen,Horde",
    [85] = "Earthen,Alliance",
}
--#endregion

--#region Constructors
function XFC.RaceCollection:new()
	local object = XFC.RaceCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.RaceCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for id, data in pairs (RaceData) do
			local raceData = string.Split(data, ',')
			local race = XFC.Race:new()
			race:Initialize()
			race:Key(tonumber(id))
			race:ID(tonumber(id))
			race:Name(raceData[1])
			race:Faction(XFO.Factions:Get(raceData[2]))
			self:Add(race)
			XF:Info(self:ObjectName(), 'Initialized race [%d:%s:%s]', race:ID(), race:Name(), race:Faction():Name())
		end
		self:IsInitialized(true)
	end
end
--#endregion