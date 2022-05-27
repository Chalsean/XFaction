local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...
local LogCategory = 'Initialize'

local EKX = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")

Engine[1] = EKX
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[addon] = Engine

EKX.Category = 'EKXFaction'
EKX.EKXfig = {}
EKX.EKXfig.BroadcastNonAddon = false
EKX.Title = format('|cff33ccff%s|r', 'EKXFaction')
EKX["RegisteredModules"] = {}
EKX.Version = tonumber(GetAddOnMetadata(addon, "Version"))
EKX.Handlers = {}
EKX.Initialized = false

EKX.Lib = {}
EKX.Lib.Compress = LibStub:GetLibrary("LibCompress")
EKX.Lib.Encode = EKX.Lib.Compress:GetAddonEncodeTable()
EKX.Lib.Realm = LibStub:GetLibrary('LibRealmInfo')

EKX.DataText = {}
EKX.DataText.Guild = {}
EKX.DataText.Guild.Name = 'Guild (X)'

function EKX:Init()
	self.initialized = true
	
	EKX.Guild = Guild:new()
	EKX.Guild:SetName('Eternal Kingdom')
	EKX.Guild:SetKey('EK')
	EKX.Guild:SetMainRealmName('Proudmoore')
	EKX.Guild:SetMainGuildName('Eternal Kingdom')
	EKX.Cache = {}

	EKX.Network = {}
	EKX.Network.ChannelName = 'EKXFaction'
	EKX.Network.Message = {}
	EKX.Network.Message.Tag = {
		LOCAL = 'EKX',
		BNET = 'EKBNet'
	}
	EKX.Network.Message.Subject = {
		DATA = 'DATA',
		GUILD_CHAT = 'GCHAT',
		EVENT = 'EVENT'
	}
	EKX.Network.Type = {
		BROADCAST = 'BROADCAST',
		WHISPER = 'WHISPER'
	}	
	
	EKX.Network.Mailbox = MessageCollection:new(); EKX.Network.Mailbox:Initialize()
	EKX.Network.Sender = Sender:new()
	EKX.Network.Receiver = Receiver:new(); EKX.Network.Receiver:Initialize()
	EKX.Network.Channels = ChannelCollection:new(); EKX.Network.Channels:Initialize()
	EKX.Network.BNet = {}
	EKX.Network.BNet.Friends = FriendCollection:new(); EKX.Network.BNet.Friends:Initialize()
	EKX.Network.BNet.Realms = { 'Proudmoore', 'Area 52' } -- config
	EKX.Handlers.BNetEvent = BNetEvent:new(); EKX.Handlers.BNetEvent:Initialize()

	-- Globals are lua's version of static variables
	EKX.Player = {}
	EKX.Player.GUID = UnitGUID('player')
	EKX.Player.RealmName = GetRealmName()
	EKX.Player.LastBroadcast = 0
	EKX.Realms = RealmCollection:new(); EKX.Realms:Initialize()
	EKX.Factions = FactionCollection:new(); EKX.Factions:Initialize()
	EKX.Player.Faction = EKX.Factions:GetFactionByName(UnitFactionGroup('player'))
	EKX.Races = RaceCollection:new(); EKX.Races:Initialize()
	EKX.Ranks = RankCollection:new(); EKX.Ranks:Initialize()
    EKX.Classes = ClassCollection:new(); EKX.Classes:Initialize()
    EKX.Specs = SpecCollection:new(); EKX.Specs:Initialize()
    EKX.Covenants = CovenantCollection:new(); EKX.Covenants:Initialize()
    EKX.Soulbinds = SoulbindCollection:new(); EKX.Soulbinds:Initialize()
    EKX.Professions = ProfessionCollection:new(); EKX.Professions:Initialize()

	-- These handlers will register additional handlers
	EKX.Handlers.TimerEvent = TimerEvent:new(); EKX.Handlers.TimerEvent:Initialize()
	EKX.Handlers.SystemEvent = SystemEvent:new(); EKX.Handlers.SystemEvent:Initialize()

	EKX.Frames = {}
	EKX.Frames.Chat = ChatFrame:new(); EKX.Frames.Chat:Initialize()
	EKX.Frames.ChatType = {
		GUILD = 'GUILD',
		ONLINE = 'ONLINE',
		OFFLINE = 'OFFLINE'
	}	

	EP:RegisterPlugin(addon, EKX.ConfigCallback)
end

E.Libs.EP:HookInitialize(EKX, EKX.Init)