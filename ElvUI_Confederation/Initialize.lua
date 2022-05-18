local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...

local CON = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0")

Engine[1] = CON
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[addon] = Engine

CON.Category = 'Confederation'
CON.CommunityID = '397041391'
CON.Config = {}
CON.Title = format('|cff33ccff%s|r', 'Confederation')
CON["RegisteredModules"] = {}
CON.Version = tonumber(GetAddOnMetadata(addon, "Version"))

function CON:Init()
	self.initialized = true
	
	E.db.Confederation = {
		Name = 'Eternal Kingdom',
		RealmIDs = { 
			5,    -- Proudmoore
			3676  -- Area 52 
		},
		Data = {
			PlayerGUID = nil,
			Player = {},
			CurrentRealm = {
				Name = nil,
				ID = nil
			},
			Realms = {
				Region = nil,
				RealmsByName = {},
				RealmsByID = {}
			},
			Guild = {
				Name = nil,
				TotalMembers = nil,
				OnlineMembers = nil,
				Roster = {},
				
			},
			Zones = {
				ZonesByName = {},
				ZonesByID = {}
			},
			Teams = {},
			Covenant = {},
			Soulbind = {}
		},
		Config = {}
	}

	E.db.Confederation.Data.Guild.Name = GetGuildInfo('player')
	E.db.Confederation.Data.CurrentRealm.Name = GetRealmName()	
	E.db.Confederation.Data.PlayerGUID = UnitGUID('player')

	if(E.db.Confederation.Data.CurrentRealm.Name == 'Proudmoore') then
		E.db.Confederation.Data.CurrentRealm.ID = 5
	elseif(E.db.Confederation.Data.CurrentRealm.Name == 'Area 52') then
		-- this bnet realm id does not match in-game realm id, no idea why
		-- its forcing some hardcoding until i can find a solution
		E.db.Confederation.Data.CurrentRealm.ID = 3676
	end

	EP:RegisterPlugin(addon, CON.ConfigCallback)
end

E.Libs.EP:HookInitialize(CON, CON.Init)