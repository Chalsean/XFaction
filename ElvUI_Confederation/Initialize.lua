local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...

local CON = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0")

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
		Data = {
			PlayerGUID = nil,
			Player = {},
			RealmName = nil,
			Guild = {
				Name = nil,
				TotalMembers = nil,
				OnlineMembers = nil,
				Roster = {}
			},
			Teams = {},
			Covenant = {},
			Soulbind = {}
		},
		Config = {}
	}

	EP:RegisterPlugin(addon, CON.ConfigCallback)
end

E.Libs.EP:HookInitialize(CON, CON.Init)