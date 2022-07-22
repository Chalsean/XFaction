--[[--------------------------------------------------------------------
	LibProfession
	World of Warcraft library for obtaining information about Professions.
----------------------------------------------------------------------]]

local _Major, _Minor = 'LibProfession', 1
assert(LibStub, _Major .. ' requires LibStub')
local lib, _OldMinor = LibStub:NewLibrary(_Major, _Minor)
if not lib then return end

local _Standalone = (...) == _Major
local _ProfessionData
local Unpack

function lib:GetProfession(inName)
	assert(type(inName) == 'string')
	if Unpack then Unpack()	end
	for _, _Profession in pairs(_ProfessionData) do
		if(_Profession.Name == inName) then
			return _Profession.ID, _Profession.Name, _Profession.Class, _Profession.Icon
		end
	end
end

function lib:GetProfessionByID(inID)
	assert(type(inName) == 'number')
	if Unpack then Unpack() end
	for _, _Profession in pairs(_ProfessionData) do
		if(_Profession.ID == inID) then
			return _Profession.ID, _Profession.Name, _Profession.Icon
		end
	end
end

function lib:Iterator()
	if Unpack then Unpack() end
	return next, _ProfessionData, nil
end

------------------------------------------------------------------------

function Unpack()
	for _ID, _Profession in pairs(_ProfessionData) do
		local _ProfessionID, _ProfessionName, _ProfessionIconID = strsplit(',', _Profession)
		_ProfessionData[_ID] = {
			ID = tonumber(_ProfessionID),
			Name = _ProfessionName,
			Icon = tonumber(_ProfessionIconID),
		}
	end
	Unpack = nil
end

------------------------------------------------------------------------

_ProfessionData = {
	[1] = '182,Herbalism,136065',
	[2] = '186,Mining,136248',
	[3] = '197,Tailoring,136249',
	[4] = '202,Engineering,136243',
	[5] = '171,Alchemy,136240',
	[6] = '773,Inscription,237171',
	[7] = '165,Leatherworking,133611',
	[8] = '333,Blacksmithing,136241',
	[9] = '755,Jewelcrafting,134071',
	[10] = '393,Skinning,134366',
}

------------------------------------------------------------------------

if _Standalone then
	LR_ProfessionData = _ProfessionData
end