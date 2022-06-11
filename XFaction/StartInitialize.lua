local addon, Engine = ...
local LogCategory = 'StartInitialize'

local XFG = LibStub('AceAddon-3.0'):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")

Engine[1] = XFG
Engine[2] = G
_G[addon] = Engine

XFG.AddonName = addon
XFG.Category = 'XFaction'
XFG.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XFG["RegisteredModules"] = {}
XFG.Version = GetAddOnMetadata(addon, "Version")
XFG.Handlers = {}

XFG.Options = {}
XFG.Options.Defaults = {}
XFG.Options.Defaults.profile = {}
XFG.Initialized = false

XFG.Icons = {}
XFG.Icons.String = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
XFG.Icons.WoWToken = 1121394
XFG.Icons.Kyrian = 3257748
XFG.Icons.Venthyr = 3257751
XFG.Icons['Night Fae'] = 3257750
XFG.Icons.Necrolord = 3257749
XFG.Icons.Alliance = 2565243
XFG.Icons.Horde = 463451

XFG.Lib = {}
XFG.Lib.Compress = LibStub:GetLibrary("LibCompress")
XFG.Lib.Encode = XFG.Lib.Compress:GetAddonEncodeTable()
XFG.Lib.QT = LibStub('LibQTip-1.0')
XFG.Lib.Realm = LibStub:GetLibrary('LibRealmInfo')
XFG.Lib.Broker = LibStub('LibDataBroker-1.1')
XFG.Lib.Config = LibStub('AceConfig-3.0')
XFG.Lib.ConfigDialog = LibStub('AceConfigDialog-3.0')
XFG.Lib.Profiler = LibStub('AceDBOptions-3.0')

XFG.DataText = {}
XFG.DataText.AutoHide = 2
XFG.DataText.Soulbind = {}
XFG.DataText.Soulbind.BrokerName = 'Soulbind (X)'
XFG.DataText.Token = {}
XFG.DataText.Token.BrokerName = 'WoW Token (X)'
XFG.DataText.Token.Events = { 'PLAYER_ENTERING_WORLD', 'PLAYER_LOGIN', 'TOKEN_MARKET_PRICE_UPDATED' }
XFG.DataText.Links = {}
XFG.DataText.Links.BrokerName = 'Links (X)'
XFG.DataText.Guild = {}
XFG.DataText.Guild.BrokerName = 'Guild (X)'
XFG.DataText.Guild.ColumnNames = {
	NAME = 'Name',
	RACE = 'Race',
	LEVEL = 'Level',
	REALM = 'Realm',
	GUILD = 'Guild',
	TEAM = 'Team',
	RANK = 'Rank',
	ZONE = 'Zone',
	NOTE = 'Note'
}
XFG.DataText.Guild.SortColumn = XFG.DataText.Guild.ColumnNames.TEAM
XFG.DataText.Guild.ReverseSort = false
XFG.DataText.Shard = {}
XFG.DataText.Shard.BrokerName = 'Shard (X)'
XFG.DataText.Shard.Timer = 60
XFG.DataText.Shard.Events = {
	'PLAYER_ENTERING_WORLD',
	'PLAYER_LOGIN',
	'PARTY_LEADER_CHANGED',
	'VIGNETTE_MINIMAP_UPDATED',
	'ZONE_CHANGED',
	'COMBAT_LOG_EVENT_UNFILTERED'
}

XFG.Player = {}
XFG.Player.LastBroadcast = 0

XFG.Network = {}
XFG.Network.BNet = {}
XFG.Network.BNet.PingTimer = 60 * 5
XFG.Network.BNet.LinksTimer = 60 * 10
XFG.Network.Message = {}
XFG.Network.ChannelName = 'EKXFactionChat'
XFG.Network.Message.Tag = {
	LOCAL = 'EKXF',
	BNET = 'EKBNet'
}
XFG.Network.Message.Subject = {
	DATA = '1',
	GCHAT = '2',
	LOGOUT = '3',
	LOGIN = '4',
	PING = '5',
	ACHIEVEMENT = '6',
	LINK = '7'
}
XFG.Network.Type = {
	BROADCAST = '1', -- BNet + Local Channel
	LOCAL = '3',     -- Local Channel only
	BNET = '4'       -- BNet only
}	

XFG.Frames = {}
XFG.Frames.ChatType = {
	GUILD = 'GUILD',
	CHANNEL = 'CHANNEL',
	SYSTEM = 'SYSTEM',
	ACHIEVEMENT = 'ACHIEVEMENT'
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
	U = 'Unknown',
	ENK = 'Social'
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