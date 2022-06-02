local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...
local LogCategory = 'Initialize'

local XFG = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")

Engine[1] = XFG
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[addon] = Engine

XFG.AddonName = addon
XFG.Category = 'XFaction'
XFG.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XFG["RegisteredModules"] = {}
XFG.Version = tonumber(GetAddOnMetadata(addon, "Version"))
XFG.Handlers = {}
XFG.Initialized = false

XFG.Lib = {}
XFG.Lib.Compress = LibStub:GetLibrary("LibCompress")
XFG.Lib.Encode = XFG.Lib.Compress:GetAddonEncodeTable()
XFG.Lib.Realm = LibStub:GetLibrary('LibRealmInfo')

XFG.DataText = {}
XFG.DataText.Guild = {}

XFG.DataText.Soulbind = {}
XFG.DataText.Soulbind.Name = 'Soulbind (X)'

XFG.Player = {}
XFG.Player.LastBroadcast = 0

XFG.Network = {}
XFG.Network.BNet = {}
XFG.Network.Message = {}
XFG.Network.ChannelName = 'EKXFactionChat'
XFG.Network.Message.Tag = {
	LOCAL = 'EKXF',
	BNET = 'EKBNet'
}
XFG.Network.Message.Subject = {
	DATA = '1',
	GCHAT = '2',
	EVENT = '3',
	LOGOUT = '4',
	WHISPER = '5',
	LOGIN = '6'
}
XFG.Network.Message.Type = {
	MESSAGE = '1',
	GUILD = '2',
	LOGOUT = '3'
}
XFG.Network.Type = {
	BROADCAST = '1', -- BNet + Local Channel
	WHISPER = '2',     -- Whisper Local
	LOCAL = '3',         -- Local Channel only
	BNET = '4'            -- BNet only
}	

XFG.Frames = {}
XFG.Frames.ChatType = {
	GUILD = 'GUILD',
	CHANNEL = 'CHANNEL',
	SYSTEM = 'SYSTEM'
}

XFG.Cache = {}
XFG.Cache.Teams = {
	A = 'Acheron',
	C = 'Chivalry',
	D = 'Duelist',
	E = 'Empire',
	F = 'Fireforged',
	G = 'Gallant',
	H = 'Harbinger',
	K = 'Kismet',
	L = 'Legacy',
	M = 'Mercenary',
	O = 'Olympus',
	R = 'Reckoning',
	S = 'Sellswords',
	T = 'Tsunami',
	Y = 'Gravity',
	BANK = 'Management',
	U = 'Unknown',
	ENKA = 'Social'
}
XFG.Cache.Guilds = {}
XFG.Cache.Guilds['Eternal Kingdom'] = 'EK'
XFG.Cache.Guilds['Endless Kingdom'] = 'ENK'
XFG.Cache.Guilds['Enduring Kingdom'] = 'EDK'
XFG.Cache.Guilds['Alternal Kingdom'] = 'AK'
XFG.Cache.Guilds['Alternal Kingdom Two'] = 'AK2'
XFG.Cache.Guilds['Alternal Kingdom Three'] = 'AK3'
XFG.Cache.Guilds['Alternal Kingdom Four'] = 'AK4'

XFG.Cache.Realms = {}
XFG.Cache.Realms.Proudmoore = {
	Alliance = {'Eternal Kingdom', 'Endless Kingdom', 'Alternal Kingdom', 'Alternal Kingdom Two', 'Alternal Kingdom Three'},
	Horde = {'Alternal Kingdom Four', 'Enduring Kingdom'}
}
-- XFG.Cache.Realms['Area 52'] = {
-- 	Alliance = {},
-- 	Horde = {'Eternal Kingdom'}
-- }

function XFG:Init()
	
	XFG.Player.GUID = UnitGUID('player')
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Teams = TeamCollection:new(); XFG.Teams:Initialize()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Player.Faction = XFG.Factions:GetFactionByName(UnitFactionGroup('player'))

	-- Globals are lua's version of static variables
	XFG.Network.Mailbox = MessageCollection:new(); XFG.Network.Mailbox:Initialize()	
	XFG.Network.BNet.Friends = FriendCollection:new(); XFG.Network.BNet.Friends:Initialize()

	XFG.Ranks = RankCollection:new(); XFG.Ranks:Initialize()
	XFG.Guilds = GuildCollection:new(); XFG.Guilds:Initialize()

	-- Make sure we have all the realm/guild combinations accounted for
	local i = 1
	for _RealmName, _FactionGuilds in pairs(XFG.Cache.Realms) do
		local _NewRealm = Realm:new()
		_NewRealm:SetKey(_RealmName)
		_NewRealm:SetName(_RealmName)
		_NewRealm:Initialize()
		XFG.Realms:AddRealm(_NewRealm)
		for _FactionName, _Guilds in pairs(_FactionGuilds) do
			local _Faction = XFG.Factions:GetFactionByName(_FactionName)
			for _, _GuildName in ipairs (_Guilds) do
				local _NewGuild = Guild:new()
				_NewGuild:Initialize()
				_NewGuild:SetID(i)
				_NewGuild:SetName(_GuildName)
				_NewGuild:SetFaction(_Faction)
				_NewGuild:SetRealm(_NewRealm)
				if(XFG.Cache.Guilds[_GuildName] ~= nil) then
					_NewGuild:SetShortName(XFG.Cache.Guilds[_GuildName])
				end
				XFG.Guilds:AddGuild(_NewGuild)
				i = i + 1
			end
		end
	end

	XFG.Player.Realm = XFG.Realms:GetRealm(GetRealmName())

	-- These handlers will register additional handlers
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()
	XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
	
	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()
	XFG.Frames.System = SystemFrame:new(); XFG.Frames.System:Initialize()

	EP:RegisterPlugin(addon, XFG.InitializeConfig)
end

E.Libs.EP:HookInitialize(XFG, XFG.Init)