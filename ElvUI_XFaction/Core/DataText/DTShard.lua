local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'DTShard'
local CheckShard = true
local LastCheckTime = GetTime() -- millisecond precision but given in seconds
XFG.ShardID = 0

local function ParseGUID(guid)

	LastCheckTime = GetTime()
	
	if guid ~= nil then
		local source, _, _, _, shard_id, _, _ = strsplit("-", guid)
		
		-- Player parses don't have shard info and pets can be on shards other than the players
		if source ~= 'Player' and source ~= 'Pet' and shard_id ~= nil then
			XFG:Debug(LogCategory, format("Parsed guid [%s]", guid))
			if(ShardID ~= shard_id) then
				ShardID = shard_id
				XFG:Info(LogCategory, format("Shard migration [%d]", ShardID))
				return true
			end
		end
	end
	
	return false
end

local function OnEnable(self, event, ...)
	--self.text:SetFormattedText('Shard: ??')	
end

local function OnEvent(self, event, ...)
	if(XFG.Initialized == false) then return end

	-- Try to catch Blizz migrating a player to another shard outside of normal events
	if(CheckShard == false and LastCheckTime + XFG.Config.DataText.Shard.Timer <= GetTime())then
		XFG:Debug(LogCategory, format("Checking for shard migration due to timer [%ds]", XFG.Config.DataText.Shard.Timer))
		CheckShard = true
	end

	-- Shard information is only found in a couple locations, combat logs being primary source
	-- In order to not impact performance, use CheckShard flag to indicate whether should parse log event
	if CheckShard == true and event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local _, _, _, _, _, _, _, destGUID, _, _, _ = CombatLogGetCurrentEventInfo()
		if ParseGUID(destGUID) then
			self.text:SetFormattedText(format('Shard: %d', ShardID))			
		end	
		CheckShard = false	
		return
	end

	-- Vignette is the rare spawns for a zone, their info contains shard id
	if CheckShard == true and event == 'VIGNETTE_MINIMAP_UPDATED' then
		local VignetteGUID, _ = ...
		local VignetteInfo = C_VignetteInfo.GetVignetteInfo(VignetteGUID)
		if ParseGUID(VignetteInfo.objectGUID) then
			self.text:SetFormattedText(format('Shard: %d', ShardID))					
		end
		CheckShard = false
		return
	end
	
	-- Events that can cause a shard migration
	if event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_LOGIN' or event == 'ELVUI_FORCE_UPDATE' or 
	   event == 'PARTY_LEADER_CHANGED' or event == 'PARTY_MEMBERS_CHANGED' or event == 'RAID_ROSTER_UPDATE' or 
	   event == 'ZONE_CHANGED' then
	   
		XFG:Debug(LogCategory, format("Checking for shard migration due to event [%s]", event))
		CheckShard = true
		return
	end
end

local events = {
	'PLAYER_ENTERING_WORLD',
	'PLAYER_LOGIN',
	'PARTY_LEADER_CHANGED',
	'PARTY_MEMBERS_CHANGED',
	'RAID_ROSTER_UPDATE',
	'VIGNETTE_MINIMAP_UPDATED',
	'ZONE_CHANGED',
	'COMBAT_LOG_EVENT_UNFILTERED',
	'ELVUI_FORCE_UPDATE'
}

XFG.Lib.DT:RegisterDatatext(XFG.DataText.Shard.Name, XFG.Category, events, OnEvent, OnEnable)