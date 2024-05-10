local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RaceCollection'
local GetRaceInfo = C_CreatureInfo.GetRaceInfo
local GetRaceFactionInfo = C_CreatureInfo.GetFactionInfo

RaceCollection = XFC.ObjectCollection:newChildConstructor()

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
		for i = 1, XF.Settings.Race.Total do
			local raceInfo = GetRaceInfo(i)
			local factionInfo = GetRaceFactionInfo(i)
			if(raceInfo and factionInfo) then
				local race = Race:new()
				race:Key(raceInfo.raceID)
				race:ID(raceInfo.raceID)
				race:Name(raceInfo.raceName)
				race:SetFaction(XF.Factions:GetByName(factionInfo.groupTag))
				self:Add(race)
				XF:Info(ObjectName, 'Initialized race [%d:%s:%s]', race:ID(), race:Name(), race:GetFaction():Name())
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion