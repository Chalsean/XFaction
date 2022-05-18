local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MZone'
local Initialized = false

local MaxRaces = 37

local function Initialize()
	if(Initialized == false) then
		local continents = {GetMapContinents()};
		for continentN =1, #continents /2 do
    		local continentID = continents[2* continentN -1];
    		local continentName = continents[2* continentN];
    		local zones = {GetMapZones(continentN)};
    		for zoneN =1, #zones /2 do
        		local zoneID = zones[2* zoneN -1];
        		local zoneName = zones[2* zoneN];
        		local subZones = {GetMapSubzones(zoneID)};
        		for subZoneN =1, #subZones /2 do
            		local subZoneID = zones[2* subZoneN -1];
            		local subZoneName = zones[2* subZoneN];
            
		            CON:Debug(LogCategory, continentName .."(" ..continentID .."): " ..zoneName .."(" ..zoneID .."): " ..subZoneName .."(" ..subZoneID ..")");
		        end;
    		end;
		end;
		Initialized = true
	end
end

function CON:GetRaceID(RaceName, Faction)
	Initialize()
	for i = 1, MaxRaces do
		if(DB.Races[i].raceName == RaceName) then
			if(Faction == nil) then
				return DB.Races[i].raceID
			elseif(DB.Races[i].Faction == Faction) then
				return DB.Races[i].raceID
			end
		end
	end
end

function CON:GetRace(ID)
	Initialize()
	return DB.Races[ID].raceName, DB.Races[ID].Faction
end