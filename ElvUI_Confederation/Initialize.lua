local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...
local LogCategory = 'Initialize'

local CON = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")

Engine[1] = CON
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[addon] = Engine

CON.Category = 'Confederation'
CON.Config = {}
CON.Config.BroadcastNonAddon = false
CON.Title = format('|cff33ccff%s|r', 'Confederation')
CON["RegisteredModules"] = {}
CON.Version = tonumber(GetAddOnMetadata(addon, "Version"))
CON.Handlers = {}

CON.Lib = {}
CON.Lib.Compress = LibStub:GetLibrary("LibCompress")
CON.Lib.Encode = CON.Lib.Compress:GetAddonEncodeTable()
CON.Lib.Realm = LibStub:GetLibrary('LibRealmInfo')

function CON:Init()
	self.initialized = true
	
	CON.Confederate = Confederate:new()
	CON.Confederate:SetName('Eternal Kingdom')
	CON.Confederate:SetKey('EK')
	CON.Confederate:SetMainRealmName('Proudmoore')
	CON.Confederate:SetMainGuildName('Eternal Kingdom')
	CON.Cache = {}
	
	CON.Network = {}
	CON.Network.ChannelName = 'EKConfederate'
	CON.Network.Message = {}
	CON.Network.Message.Tag = {
		LOCAL = 'EKCon',
		BNET = 'EKBNet'
	}
	CON.Network.Message.Subject = {
		DATA = 'DATA',
		GUILD_CHAT = 'GCHAT'
	}
	CON.Network.Type = {
		BROADCAST = 'BROADCAST',
		WHISPER = 'WHISPER'
	}	
	
	CON.Network.Mailbox = MessageCollection:new(); CON.Network.Mailbox:Initialize()
	CON.Network.Sender = Sender:new()
	CON.Network.Receiver = Receiver:new(); CON.Network.Receiver:Initialize()
	CON.Network.Channels = ChannelCollection:new(); CON.Network.Channels:Initialize()
	CON.Network.BNet = {}
	CON.Network.BNet.Friends = FriendCollection:new(); CON.Network.BNet.Friends:Initialize()
	CON.Network.BNet.Realms = { 'Proudmoore', 'Area 52' } -- config
	CON.Handlers.BNetEvent = BNetEvent:new(); CON.Handlers.BNetEvent:Initialize()

	-- Globals are lua's version of static variables
	CON.Player = {}
	CON.Player.GUID = UnitGUID('player')	
	CON.Player.RealmName = GetRealmName()
	CON.Player.LastBroadcast = 0
	CON.Realms = RealmCollection:new(); CON.Realms:Initialize()
	CON.Factions = FactionCollection:new(); CON.Factions:Initialize()
	CON.Player.Faction = CON.Factions:GetFactionByName(UnitFactionGroup('player'))
	CON.Races = RaceCollection:new(); CON.Races:Initialize()
	CON.Ranks = RankCollection:new(); CON.Ranks:Initialize()
    CON.Classes = ClassCollection:new(); CON.Classes:Initialize()
    CON.Specs = SpecCollection:new(); CON.Specs:Initialize()
    CON.Covenants = CovenantCollection:new(); CON.Covenants:Initialize()
    CON.Soulbinds = SoulbindCollection:new(); CON.Soulbinds:Initialize()
    CON.Professions = ProfessionCollection:new(); CON.Professions:Initialize()

	-- These handlers will register additional handlers
	CON.Handlers.TimerEvent = TimerEvent:new(); CON.Handlers.TimerEvent:Initialize()
	CON.Handlers.SystemEvent = SystemEvent:new(); CON.Handlers.SystemEvent:Initialize()

	CON.Frames = {}
	CON.Frames.Chat = ChatFrame:new(); CON.Frames.Chat:Initialize()
	CON.Frames.ChatType = {
		GUILD = 'GUILD',
		ONLINE = 'ONLINE',
		OFFLINE = 'OFFLINE'
	}

	CON.DataText = {}
	CON.DataText.XGuild = {}
	EP:RegisterPlugin(addon, CON.ConfigCallback)
end

E.Libs.EP:HookInitialize(CON, CON.Init)