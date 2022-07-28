--[[--------------------------------------------------------------------
	LibClass
	World of Warcraft library for obtaining information about Classes.
----------------------------------------------------------------------]]

local _Major, _Minor = 'LibClass', 1
assert(LibStub, _Major .. ' requires LibStub')
local lib, _OldMinor = LibStub:NewLibrary(_Major, _Minor)
if not lib then return end

local _Standalone = (...) == _Major
local _ClassData
local Unpack

function lib:GetClass(inName)
	assert(type(inName) == 'string')
	if Unpack then Unpack()	end
	for _, _Class in pairs(_ClassData) do
		if(_Class.Name == inName) then
			return _Class.ID, _Class.Name, _Class.API, _Class.R, _Class.G, _Class.B, _Class.Hex
		end
	end
end

function lib:GetClassByID(inID)
	assert(type(inName) == 'number')
	if Unpack then Unpack() end
	for _, _Class in pairs(_ClassData) do
		if(_Class.ID == inID) then
			return _Class.ID, _Class.Name, _Class.API, _Class.R, _Class.G, _Class.B, _Class.Hex
		end
	end
end

function lib:Iterator()
	if Unpack then Unpack() end
	return next, _ClassData, nil
end

------------------------------------------------------------------------

function Unpack()
	for _ID, _Class in pairs(_ClassData) do
		local _ClassID, _ClassName, _ClassAPI, _ClassR, _ClassG, _ClassB, _ClassHex = strsplit(',', _Class)
		_ClassData[_ID] = {
			ID = tonumber(_ClassID),
			Name = _ClassName,
			API = _ClassAPI,
			R = tonumber(_ClassR),
			G = tonumber(_ClassG),
			B = tonumber(_ClassB),
			Hex = _ClassHex
		}
	end
	Unpack = nil
end

------------------------------------------------------------------------

_ClassData = {
	[1] = '1,Warrior,WARRIOR,198,155,109,C69B6D',
	[2] = '2,Paladin,PALADIN,244,140,186,F48CBA',
	[3] = '3,Hunter,HUNTER,170,211,114,AAD372',
	[4] = '4,Rogue,ROGUE,255,240,104,FFF468',
	[5] = '5,Priest,PRIEST,255,255,255,FFFFFF',
	[6] = '6,Death Knight,DEATHKNIGHT,196,30,58,C41E3A',
	[7] = '7,Shaman,SHAMAN,0,112,221,0070DD',
	[8] = '8,Mage,MAGE,63,199,235,3FC7EB',
	[9] = '9,Warlock,WARLOCK,135,136,238,8788EE',
	[10] = '10,Monk,MONK,0,255,152,00FF98',
	[11] = '11,Druid,DRUID,255,124,10,FF7C0A',
	[12] = '12,Demon Hunter,DEMONHUNTER,163,48,201,A330C9',
	[13] = '13,Evoker,EVOKER,51,147,127,33937F',
}

------------------------------------------------------------------------

if _Standalone then
	LR_ClassData = _ClassData
end