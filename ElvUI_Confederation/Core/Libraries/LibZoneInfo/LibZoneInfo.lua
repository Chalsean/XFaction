--[[--------------------------------------------------------------------
	LibRealmInfo
	World of Warcraft library for obtaining information about realms.
	Copyright 2014-2019 Phanx <addons@phanx.net>
	Zlib license. Standalone distribution strongly discouraged.
	https://github.com/phanx-wow/LibRealmInfo
	https://wow.curseforge.com/projects/librealminfo
	https://www.wowinterface.com/downloads/info22987-LibRealmInfo
----------------------------------------------------------------------]]

local MAJOR, MINOR = "LibZoneInfo", 13
assert(LibStub, MAJOR.." requires LibStub")
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local standalone = (...) == MAJOR
local _ZoneData = {}
local _Initialized = false

function Debug(SubCategory, ...)
	local status, res = pcall(format, ...)
	if status then
	  if DLAPI then DLAPI.DebugLog(MAJOR, format("OK~%s~9~%s", SubCategory, res)) end
	end
end

local function shallowCopy(t)
	if not t then return end

	local n = {}
	for k, v in next, t do
		n[k] = v
	end
	return n
end

local function getNameForAPI(name)
	return name and (name:gsub("[%s%-]", "")) or nil
end

------------------------------------------------------------------------
-- Word of warning: a zone appears multiple times, the lib simply returns the first match
function lib:GetZoneInfoByName(inName)
	assert(type(inName) == 'string', "Usage: GetZoneInfoByName(string)")

	if(_Initialized == false) then
		Initialize()
	end

	for _ID, _Zone in pairs(_ZoneData) do		
		if(_Zone.Name_lang == inName) then
			Debug("GetZoneInfoByName", "Found first zone that matched name [%d:%s]", _Zone.ID, inName)
			return _Zone.Name_lang,
				   _Zone.ID, 
				   _Zone.ParentUiMapID, 
				   _Zone.Flags, 
				   _Zone.System, 
				   _Zone.Type, 
				   _Zone.BountySetID, 
				   _Zone.BountyDisplayLocation, 
				   _Zone.VisibilityPlayerConditionID, 
				   _Zone.HelpTextPosition, 
				   _Zone.BkgAtlasID, 
				   _Zone.AlternateUiMapGroup, 
				   _Zone.ContentTuningID
		end
	end

	Debug("GetZoneInfoByName", "No info found for zone name [%s]", inName)
end

------------------------------------------------------------------------

function lib:GetZoneInfo(inID)
	assert(type(inID) == 'number', "Usage: GetZoneInfo(number)")

	if(_Initialized == false) then
		Initialize()
	end

	if(_ZoneData[inID] ~= nil) then
		Debug("GetZoneInfo", "Found zone ID [%d]", inID)
		return _ZoneData[inID].Name_lang,
		       _ZoneData[inID].ID, 
			   _ZoneData[inID].ParentUiMapID, 
			   _ZoneData[inID].Flags, 
			   _ZoneData[inID].System, 
			   _ZoneData[inID].Type, 
			   _ZoneData[inID].BountySetID, 
			   _ZoneData[inID].BountyDisplayLocation, 
			   _ZoneData[inID].VisibilityPlayerConditionID, 
			   _ZoneData[inID].HelpTextPosition, 
			   _ZoneData[inID].BkgAtlasID, 
			   _ZoneData[inID].AlternateUiMapGroup, 
			   _ZoneData[inID].ContentTuningID
	end

	Debug("GetZoneInfo", "No info found for zone ID [%d]", inID)
end

------------------------------------------------------------------------

function Initialize()
	Debug("Initialize", "Unpacking datafile")

	for _Key, _Pack in pairs(_UIMapDB) do
		-- Name_lang,ID,ParentUiMapID,Flags,System,Type,BountySetID,BountyDisplayLocation,VisibilityPlayerConditionID,HelpTextPosition,BkgAtlasID,AlternateUiMapGroup,ContentTuningID
		-- Durotar,1,12,6,0,3,0,0,0,0,0,0,70
		-- System: 0 (World), 
		-- Type: 2 (Continent), 3 (Zone), 4 (Dungeon), 5 (Micro-Dungeon), 6 (Orphan)
		local _Name, _ID, _ParentID, _Flags, _System, _Type, _BountyID, _BountyLocation, _BountyConditionID, _HelpText, _AtlasID, _AltMapGroup, _ContentID = strsplit(",", _Pack)
		_Name:gsub("%&comma%;", ",")

		_ZoneData[_ID] = {
			Name_lang = _Name,
			ID = _ID, 
			ParentUiMapID = _ParentID, 
			Flags = _Flags, 
			System = _System, 
			Type = _Type, 
			BountySetID = _BountyID, 
			BountyDisplayLocation = _BountyLocation, 
			VisibilityPlayerConditionID = _BountyConditionID, 
			HelpTextPosition = _HelpText, 
			BkgAtlasID = _AtlasID, 
			AlternateUiMapGroup = _AltMapGroup, 
			ContentTuningID = _ContentID
		}
	end
	_Initialized = true
	collectgarbage()

	Debug("Initialize", "Done unpacking datafile")
end

if standalone then
	LRI_ZoneData = _ZoneData
end