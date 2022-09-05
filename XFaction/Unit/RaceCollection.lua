local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaceCollection'
local GetRaceInfo = C_CreatureInfo.GetRaceInfo
local GetRaceFactionInfo = C_CreatureInfo.GetFactionInfo

RaceCollection = ObjectCollection:newChildConstructor()

function RaceCollection:new()
	local object = RaceCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function RaceCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(not XFG.Cache.UIReload or XFG.Cache.Races == nil) then
			XFG.Cache.Races = {}
			for i = 1, XFG.Settings.Race.Total do
				local raceInfo = GetRaceInfo(i)
				local factionInfo = GetRaceFactionInfo(i)
				if(raceInfo and factionInfo) then
					XFG.Cache.Races[#XFG.Cache.Races + 1] = {
						ID = raceInfo.raceID,
						Name = raceInfo.raceName,
						Faction = factionInfo.groupTag,
					}
				end
			end
		else
			XFG:Debug(ObjectName, 'Race information found in cache')
		end

		for _, data in ipairs(XFG.Cache.Races) do
			local race = Race:new()
			race:SetKey(data.ID)
			race:SetID(data.ID)
			race:SetName(data.Name)
			race:SetFaction(XFG.Factions:GetByName(data.Faction))
			self:Add(race)
			XFG:Info(ObjectName, 'Initialized race [%d:%s:%s]', race:GetID(), race:GetName(), race:GetFaction():GetName())
		end

		self:IsInitialized(true)
	end
end