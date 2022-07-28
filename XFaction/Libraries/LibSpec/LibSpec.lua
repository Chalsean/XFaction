--[[--------------------------------------------------------------------
	LibSpec
	World of Warcraft library for obtaining information about specs.
----------------------------------------------------------------------]]

local _Major, _Minor = 'LibSpec', 1
assert(LibStub, _Major .. ' requires LibStub')
local lib, _OldMinor = LibStub:NewLibrary(_Major, _Minor)
if not lib then return end

local _Standalone = (...) == _Major
local _SpecData
local Unpack

function lib:GetSpec(inName)
	assert(type(inName) == 'string')
	if Unpack then Unpack()	end
	for _, _Spec in pairs(_SpecData) do
		if(_Spec.Name == inName) then
			return _Spec.ID, _Spec.Name, _Spec.Class, _Spec.Icon
		end
	end
end

function lib:GetSpecByID(inID)
	assert(type(inName) == 'number')
	if Unpack then Unpack() end
	for _, _Spec in pairs(_SpecData) do
		if(_Spec.ID == inID) then
			return _Spec.ID, _Spec.Name, _Spec.Class, _Spec.Icon
		end
	end
end

function lib:Iterator()
	if Unpack then Unpack() end
	return next, _SpecData, nil
end

------------------------------------------------------------------------

function Unpack()
	for _ID, _Spec in pairs(_SpecData) do
		local _SpecID, _SpecName, _ClassName, _SpecIconID = strsplit(',', _Spec)
		_SpecData[_ID] = {
			ID = tonumber(_SpecID),
			Name = _SpecName,
			Class = _ClassName,
			Icon = tonumber(_SpecIconID),
		}
	end
	Unpack = nil
end

------------------------------------------------------------------------

_SpecData = {
	[1] = '62,Arcane,Mage,135932',
	[2] = '63,Fire,Mage,135810',
	[3] = '250,Blood,Death Knight,135770',
	[4] = '251,Frost,Death Knight,135773',
	[5] = '252,Unholy,Death Knight,135775',
	[6] = '253,Beast Mastery,Hunter,461112',
	[7] = '254,Marksmanship,Hunter,236179',
	[8] = '255,Survival,Hunter,461113',
	[9] = '66,Protection,Paladin,236264',
	[10] = '257,Holy,Priest,237542',
	[11] = '258,Shadow,Priest,136207',
	[12] = '259,Assassination,Rogue,236270',
	[13] = '260,Outlaw,Rogue,236286',
	[14] = '261,Subtlety,Rogue,132320',
	[15] = '262,Elemental,Shaman,136048',
	[16] = '581,Vengeance,Demon Hunter,1247265',
	[17] = '264,Restoration,Shaman,136052',
	[18] = '265,Affliction,Warlock,136145',
	[19] = '266,Demonology,Warlock,136172',
	[20] = '267,Destruction,Warlock,136186',
	[21] = '268,Brewmaster,Monk,608951',
	[22] = '269,Windwalker,Monk,608953',
	[23] = '270,Mistweaver,Monk,608952',
	[24] = '70,Retribution,Paladin,135873',
	[25] = '102,Balance,Druid,136096',
	[26] = '71,Arms,Warrior,132355',
	[27] = '103,Feral,Druid,132115',
	[28] = '72,Fury,Warrior,132347',
	[29] = '104,Guardian,Druid,132276',
	[30] = '73,Protection,Warrior,132341',
	[31] = '263,Enhancement,Shaman,237581',
	[32] = '105,Restoration,Druid,136041',
	[33] = '64,Frost,Mage,135846',
	[34] = '256,Discipline,Priest,135940',
	[35] = '577,Havoc,Demon Hunter,1247264',
	[36] = '65,Holy,Paladin,135920',
}

------------------------------------------------------------------------

if _Standalone then
	LR_SpecData = _SpecData
end