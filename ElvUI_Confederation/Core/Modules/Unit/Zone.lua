local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MZone'
local Initialized = false
--local ZONE = LibStub:GetLibrary("LibZoneInfo")
--CON.Zone = ZONE

local function Initialize()
	if(Initialized == false) then
		if(DB.Zones == nil) then
			DB.Zones = {
				ZonesByName = {},
				ZonesByID = {}
			}
		end
		Initialized = true
	end
end

function CON:GetZoneID(ZoneName)
	-- Initialize()
	-- CON:DataDumper(LogCategory, ZoneName)
	-- if(DB.Zones.ZonesByName[ZoneName] == nil) then
	-- 	local id, name  = ZONE:GetZoneInfo(ZoneName)
	-- 	DB.Zones.ZonesByName[name] = {
	-- 		ID = id,
	-- 		Name = name
	-- 	}
	-- 	DB.Zones.ZonesByID[id] = DB.Zones.ZonesByName[name]
	-- end
	-- return DB.Zones.ZonesByName[ZoneName].ID
end

function CON:GetZoneName(ZoneID)
	-- Initialize()
	-- if(DB.Zones.ZonesByID[ZoneID] == nil) then
	-- 	local id, name = ZONE:GetZoneInfoByID(ZoneID)
	-- 	DB.Zones.ZonesByName[name] = {
	-- 		ID = id,
	-- 		Name = name
	-- 	}
	-- 	DB.Zones.ZonesByID[id] = DB.Zones.ZonesByName[name]
	-- end
	-- return DB.Zones.ZonesByID[ZoneID].Name
end