local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MRace'
local Initialized = false

local MaxRaces = 37

local function Initialize()
	if(Initialized == false) then
		CON:Info(LogCategory, "Caching race information")
		if(DB.Races == nil) then
			DB.Races = {}
		end

		for i = 1, MaxRaces do
			local RaceInfo = C_CreatureInfo.GetRaceInfo(i)
			local FactionInfo = C_CreatureInfo.GetFactionInfo(i)
			RaceInfo.Faction = FactionInfo.name
			table.RemoveKey(RaceInfo, 'clientFileString')
			DB.Races[i] = RaceInfo
		end
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