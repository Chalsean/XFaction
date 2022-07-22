--[[--------------------------------------------------------------------
	LibRace
	World of Warcraft library for obtaining information about races.
----------------------------------------------------------------------]]

local _Major, _Minor = 'LibRace', 1
assert(LibStub, _Major .. ' requires LibStub')
local lib, _OldMinor = LibStub:NewLibrary(_Major, _Minor)
if not lib then return end

local _Standalone = (...) == _Major
local _RaceData
local Unpack

function lib:GetRace(inName)
	assert(type(inName) == 'string')
	if Unpack then Unpack()	end
	for _, _Race in pairs(_RaceData) do
		if(_Race.Name == inName) then
			return _Race.ID, _Race.Name, _Race.Faction
		end
	end
end

function lib:GetRaceByID(inID)
	assert(type(inName) == 'number')
	if Unpack then Unpack() end
	for _, _Race in pairs(_RaceData) do
		if(_Race.ID == inID) then
			return _Race.ID, _Race.Name, _Race.Faction
		end
	end
end

function lib:Iterator()
	if Unpack then Unpack() end
	return next, _RaceData, nil
end

------------------------------------------------------------------------

function Unpack()
	for _ID, _Race in pairs(_RaceData) do
		local _RaceName, _FactionName = strsplit(',', _Race)
		_RaceData[_ID] = {
			ID = tonumber(_ID),
			Name = _RaceName,
			Faction = _FactionName
		}
	end
	Unpack = nil
end

------------------------------------------------------------------------

_RaceData = {
	[1] = 'Human,Alliance',
	[2] = 'Orc,Horde',
	[3] = 'Dwarf,Alliance',
	[4] = 'Night Elf,Alliance',
	[5] = 'Undead,Horde',
	[6] = 'Tauren,Horde',
	[7] = 'Gnome,Alliance',
	[8] = 'Troll,Horde',
	[9] = 'Goblin,Horde',
	[10] = 'Blood Elf,Horde',
	[11] = 'Draenei,Alliance',
	[22] = 'Worgen,Alliance',
	[24] = 'Pandaren,Alliance',
	[25] = 'Pandaren,Neutral',
	[26] = 'Pandaren,Horde',
	[27] = 'Nightborne,Horde',
	[28] = 'Highmountain Tauren,Horde',
	[29] = 'Void Elf,Alliance',
	[30] = 'Lightforged Draenei,Alliance',
	[31] = 'Zandalari Troll,Horde',
	[32] = 'Kul Tiran,Alliance',
	[34] = 'Dark Iron Dwarf,Alliance',
	[35] = 'Vulpera,Horde',
	[36] = 'Maghar Orc,Horde',
	[37] = 'Mechagnome,Alliance',
	[52] = 'Dracthyr,Alliance',
	[70] = 'Dracthyr,Horde',
}

------------------------------------------------------------------------

if _Standalone then
	LR_RaceData = _RaceData
end