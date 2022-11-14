local XFG, G = unpack(select(2, ...))
local ObjectName = 'RaceCollection'
local GetRaceInfo = C_CreatureInfo.GetRaceInfo
local GetRaceFactionInfo = C_CreatureInfo.GetFactionInfo

RaceCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function RaceCollection:new()
	local object = RaceCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function RaceCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for i = 1, XFG.Settings.Race.Total do
			local raceInfo = GetRaceInfo(i)
			local factionInfo = GetRaceFactionInfo(i)
			if(raceInfo and factionInfo) then
				local race = Race:new()
				race:SetKey(raceInfo.raceID)
				race:SetID(raceInfo.raceID)
				race:SetName(raceInfo.raceName)
				race:SetFaction(XFG.Factions:GetByName(factionInfo.groupTag))
				self:Add(race)
				XFG:Info(ObjectName, 'Initialized race [%d:%s:%s]', race:GetID(), race:GetName(), race:GetFaction():GetName())
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion