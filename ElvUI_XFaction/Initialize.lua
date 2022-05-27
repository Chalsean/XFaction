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

XFG.Category = 'XFaction'
XFG.XFGfig = {}
XFG.XFGfig.BroadcastNonAddon = false
XFG.Title = format('|cff33ccff%s|r', 'XFaction')
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
XFG.DataText.Guild.Name = 'Guild (X)'
XFG.DataText.Soulbind = {}
XFG.DataText.Soulbind.Name = 'Soulbind (X)'

XFG.Player = {}
XFG.Player.LastBroadcast = 0

XFG.Network = {}
XFG.Network.BNet = {}
XFG.Network.Message = {}
XFG.Network.ChannelName = 'XFGFaction'
XFG.Network.Message.Tag = {
	LOCAL = 'XFG',
	BNET = 'EKBNet'
}
XFG.Network.Message.Subject = {
	DATA = 'DATA',
	GUILD_CHAT = 'GCHAT',
	EVENT = 'EVENT'
}
XFG.Network.Type = {
	BROADCAST = 'BROADCAST',
	WHISPER = 'WHISPER'
}	

XFG.Frames = {}
XFG.Frames.ChatType = {
	GUILD = 'GUILD',
	ONLINE = 'ONLINE',
	OFFLINE = 'OFFLINE'
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

function XFG:Init()
	self.initialized = true
	
	XFG.Guild = Guild:new()
	XFG.Guild:SetName('Eternal Kingdom')
	XFG.Guild:SetKey('EK')
	XFG.Guild:SetMainRealmName('Proudmoore')
	XFG.Guild:SetMainGuildName('Eternal Kingdom')	
	
	-- Globals are lua's version of static variables
	XFG.Network.Mailbox = MessageCollection:new(); XFG.Network.Mailbox:Initialize()	
	XFG.Network.Channels = ChannelCollection:new(); XFG.Network.Channels:Initialize()
	
	XFG.Network.BNet.Friends = FriendCollection:new(); XFG.Network.BNet.Friends:Initialize()
	XFG.Network.BNet.Realms = { 'Proudmoore', 'Area 52' } -- config	
	
	XFG.Player.GUID = UnitGUID('player')
	XFG.Player.RealmName = GetRealmName()	
	XFG.Realms = RealmCollection:new(); XFG.Realms:Initialize()
	XFG.Teams = TeamCollection:new(); XFG.Teams:Initialize()
	XFG.Factions = FactionCollection:new(); XFG.Factions:Initialize()
	XFG.Player.Faction = XFG.Factions:GetFactionByName(UnitFactionGroup('player'))
	XFG.Ranks = RankCollection:new(); XFG.Ranks:Initialize()
    
	-- These handlers will register additional handlers
	XFG.Handlers.TimerEvent = TimerEvent:new(); XFG.Handlers.TimerEvent:Initialize()
	XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
	
	XFG.Frames.Chat = ChatFrame:new(); XFG.Frames.Chat:Initialize()	

	local _GChat = GuildMessage:new()
	_GChat:SetKey("d;afja")
	_GChat:SetFromGUID('blargh')
	XFG:DataDumper(LogCategory, _GChat)
	_GChat:Print()

	EP:RegisterPlugin(addon, XFG.ConfigCallback)
end

E.Libs.EP:HookInitialize(XFG, XFG.Init)