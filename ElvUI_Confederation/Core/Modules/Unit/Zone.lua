local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MZone'
local Initialized = false
local ZONE = LibStub:GetLibrary("LibZoneInfo")
CON.Zone = ZONE

local function Initialize()
	if(Initialized == false) then
		if(DB.Zone == nil) then
			DB.Zone = {
				ZonesByName = {},
				ZonesByID = {}
			}
		end
		Initialized = true
	end
end

function CON:GetZoneID(ZoneName)
	Initialize()
	if(DB.Zone.ZonesByName[ZoneName] == nil) then
		local id, name  = ZONE:GetZoneInfo(ZoneName)
		DB.Zone.ZonesByName[name] = {
			ID = id,
			Name = name
		}
		DB.Zone.ZonesByID[id] = DB.Zone.ZonesByName[name]
	end
	return DB.Zone.ZonesByName[ZoneName].ID
end

function CON:GetZoneName(ZoneID)
	Initialize()
	if(DB.Zone.ZonesByID[ZoneID] == nil) then
		local id, name = ZONE:GetZoneInfoByID(ZoneID)
		DB.Zone.ZonesByName[name] = {
			ID = id,
			Name = name
		}
		DB.Zone.ZonesByID[id] = DB.Zone.ZonesByName[name]
	end
	return DB.Zone.ZonesByID[ZoneID].Name
end