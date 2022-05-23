local CON, E, L, V, P, G = unpack(select(2, ...))
local DB = E.db.Confederation.Data
local LogCategory = 'MRoster'
local Initialized = false

DB.Guild.Ranks = {
	GM = 'Guild Master',
	Chancellor = 'Guild Lead',
	Ambassador = 'Raid Lead',
	Templar = 'Team Admin',
	Squire = 'Trial',
	Veteran = 'Retired Raider',
}

DB.Guild.Ranks["Royal Emissary"] = 'Team Lead'
DB.Guild.Ranks["Master of Coin"] = 'Bank'
DB.Guild.Ranks["Grand Alt"] = 'Raider Alt'
DB.Guild.Ranks["Noble Citizen"] = 'Non-Raider'
DB.Guild.Ranks["Grand Army"] = 'Raider'
DB.Guild.Ranks["Cat Herder"] = 'Guild Master Alt'

local function BuildUnitData(GuildIndex)
	local unit, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, _, _, isMobile, _, standing, GUID = GetGuildRosterInfo(GuildIndex)
	local ParsedName = string.Split(unit, "-")
	local _, _, Race = GetPlayerInfoByGUID(GUID);
	local UnitData = {
		GUID = GUID,
		Unit = unit,
		Name = ParsedName[1],
		RealmName = DB.CurrentRealm.Name,
		GuildName = DB.Guild.Name,
		GuildIndex = i,
		GuildRank = (DB.Guild.Ranks[rank] ~= nil) and DB.Guild.Ranks[rank] or rank,
		Level = level,
		Class = class,
		Zone = zone,
		Note = note,
		Online = online,
		Status = status,
		IsMobile = isMobile,
		Race = Race,
		TimeStamp = GetServerTime(),
		Faction = UnitFactionGroup('player'),
		Covenant = nil,
		Soulbind = nil,
		Team = nil,
		RunningCovenant = false
	}

	local ParsedGUID = string.Split(GUID, "-")
	UnitData.RealmID = ParsedGUID[2]

	if(UnitData.GUID == DB.PlayerGUID) then
		UnitData.Spec = CON:GetActiveSpec()

		local FirstProfessionID, SecondProfessionID = GetProfessions()
		if(FirstProfessionID ~= nil) then
			UnitData.Profession1 = CON:GetProfession(FirstProfessionID)
		end
		if(SecondProfessionID ~= nil) then
			UnitData.Profession2 = CON:GetProfession(SecondProfessionID)
		end
		
		if(CON:HasActiveCovenant()) then
			UnitData.Covenant = CON:GetActiveCovenant()
		end
		if(CON:HasActiveSoulbind()) then
			UnitData.Soulbind = CON:GetActiveSoulbind()
		end
		RunningAddon = true
	end	

	local UpperNote = string.upper(UnitData.Note)
	if(string.match(UpperNote, "%[EN?KA%]")) then
		UnitData.Alt = true
	else
		UnitData.Alt = false
	end

	if(string.match(UpperNote, "%[ENKA%]")) then
		UnitData.Team = 'NonRaid'
	elseif(string.match(UpperNote, "%[A%]")) then
		UnitData.Team = 'Acheron'
	elseif(string.match(UpperNote, "%[C%]")) then
		UnitData.Team = 'Chivalry'
	elseif(string.match(UpperNote, "%[D%]")) then
		UnitData.Team = 'Duelist'
	elseif(string.match(UpperNote, "%[E%]")) then
		UnitData.Team = 'Empire'
	elseif(string.match(UpperNote, "%[F%]")) then
		UnitData.Team = 'Fireforged'
	elseif(string.match(UpperNote, "%[G%]")) then
		UnitData.Team = 'Gallant'
	elseif(string.match(UpperNote, "%[H%]")) then
		UnitData.Team = 'Harbinger'
	elseif(string.match(UpperNote, "%[K%]")) then
		UnitData.Team = 'Kismet'
	elseif(string.match(UpperNote, "%[L%]")) then
		UnitData.Team = 'Legacy'
	elseif(string.match(UpperNote, "%[O%]")) then
		UnitData.Team = 'Olympus'
	elseif(string.match(UpperNote, "%[S%]")) then
		UnitData.Team = 'Sellswords'
	elseif(string.match(UpperNote, "%[T%]")) then
		UnitData.Team = 'Tsunami'
	elseif(string.match(UpperNote, "%[T%]")) then
		UnitData.Team = 'Tsunami'
	elseif(string.match(UpperNote, "%[Y%]")) then
		UnitData.Team = 'Gravity'
	elseif(string.match(UpperNote, "%[R%]")) then
		UnitData.Team = 'Reckoning'
	elseif(string.match(UpperNote, "%[BANK%]")) then
		UnitData.Team = 'Management'
	else
		UnitData.Team = 'Unknown'
	end

	if(UnitData.Alt == true) then
		local ParsedNotes = string.Split(UnitData.Note, ") ")
		UnitData.AltName = ParsedNotes[table.getn(ParsedNotes)]
	end

	return UnitData
end

local function CallbackRosterUpdate()
	DB.Guild.TotalMembers, _, DB.Guild.OnlineMembers = GetNumGuildMembers()
	
	for i = 1, DB.Guild.TotalMembers do
		local UnitData = BuildUnitData(i)
		
		-- Detect a new person joined guild
		if(DB.Guild.Roster[UnitData.GUID] == nil) then
			CON:Debug(LogCategory, format('Detected guild member not in cache [%s]', UnitData.Unit))
			if(CON:AddGuildMember(UnitData) and UnitData.RunningCovenant == false and UnitData.Online == true) then
				CON:BroadcastUnitData(UnitData)
				--CON:BnetUnitData(UnitData)
			end

		-- Detect members going offline
		elseif(UnitData.Online == false and DB.Guild.Roster[UnitData.GUID].Online == true) then
			CON:Debug(LogCategory, format("Detected someone going offline [%s]", UnitData.Unit))
			if(CON:RemoveGuildMember(UnitData) and UnitData.RunningCovenant == false) then
				CON:BroadcastUnitData(UnitData)
				--CON:BnetUnitData(UnitData)
			end
		
		-- Detect members coming online
		elseif(UnitData.Online == true and DB.Guild.Roster[UnitData.GUID].Online == false) then
			CON:Debug(LogCategory, format("Detected someone coming online [%s]", UnitData.Unit))
			if(CON:AddGuildMember(UnitData) and UnitData.RunningCovenant == false) then
				CON:BroadcastUnitData(UnitData)
				--CON:BnetUnitData(UnitData)
			end

		-- Detect members staying online, need to check for changes for broadcast to peer guilds
		elseif(UnitData.Online == true and UnitData.RunningCovenant == false) then
			for Key, Value in pairs (UnitData) do
				if(Key ~= 'TimeStamp' and DB.Guild.Roster[UnitData.GUID][Key] ~= Value) then
					local OldValue = DB.Guild.Roster[UnitData.GUID][Key]
					if(CON:AddGuildMember(UnitData)) then
						CON:Debug(LogCategory, "Detected unit status change [%s][%s][%s][%s]", UnitData.Unit, Key, OldValue, Value)
						CON:BroadcastUnitData(UnitData)
						--CON:BnetUnitData(UnitData)
					end
					break
				end
			end
		end
	end
end

local function InitializeRoster()
	if(Initialized == false) then
		if(DB.Guild.Roster == nil) then
			DB.Guild.Roster = {}
		end
		if(DB.Player == nil) then
			DB.Player = {}
		end

		CON:Info(LogCategory, "Initializing local guild roster cache")
		DB.Guild.TotalMembers, _, DB.Guild.OnlineMembers = GetNumGuildMembers()
		
		for i = 1, DB.Guild.TotalMembers do
			local UnitData = BuildUnitData(i)
			CON:AddGuildMember(UnitData)
		end

		Initialized = true
	end
end

do
	InitializeRoster()
	CON:RegisterEvent('GUILD_ROSTER_UPDATE', CallbackRosterUpdate)

	-- Broadcast you have logged in, because only you know your covenant/soulbind
	CON:BroadcastUnitData(DB.Player)
	
	
	-- Broadcast a request to everyone for current information
	CON:BroadcastStatus()
end