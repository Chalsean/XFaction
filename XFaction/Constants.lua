local addon, Engine = ...
local LogCategory = 'Constants'

local XFG = LibStub('AceAddon-3.0'):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0", 'AceBucket-3.0')

Engine[1] = XFG
Engine[2] = G
_G[addon] = Engine

XFG.AddonName = addon
XFG.Category = 'XFaction'
XFG.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XFG.Version = GetAddOnMetadata(addon, "Version")
XFG.Start = GetServerTime()

XFG.DataText = {}
XFG.Factories = {}
XFG.Frames = {}
XFG.Handlers = {}
XFG.Nameplates = {}

XFG.Initialized = false

XFG.Icons = {
	String = '|T%d:16:16:0:0:64:64:4:60:4:60|t',
	Texture = '|T%s:17:17|t',
	WoWToken = 1121394,
	Kyrian = 3257748,
	Venthyr = 3257751,
	['Night Fae'] = 3257750,
	Necrolord = 3257749,
	Alliance = 2565243,
	Horde = 463451,
	Gold = [[|TInterface\MONEYFRAME\UI-GoldIcon:16:16|t]],
	Guild = 'ElvUI-Windtools-Healer',
}

XFG.Lib = {
	Deflate = LibStub:GetLibrary('LibDeflate'),
	QT = LibStub('LibQTip-1.0'),
	Realm = LibStub:GetLibrary('LibRealmInfo'),
	Broker = LibStub('LibDataBroker-1.1'),
	Config = LibStub('AceConfig-3.0'),
	ConfigDialog = LibStub('AceConfigDialog-3.0'),
	Locale = LibStub('AceLocale-3.0'):GetLocale(XFG.Category, true),
	Cmd = LibStub('AceConfigCmd-3.0'),
	Race = LibStub('LibRace'),
	BabbleRace = LibStub('LibBabble-Race-3.0'),
	Spec = LibStub('LibSpec'),
	Class = LibStub('LibClass'),
	Profession = LibStub('LibProfession'),
	Tourist = LibStub('LibTourist-3.0'),
}

XFG.Player = {
	LastBroadcast = 0,
	InInstance = false
}

XFG.Cache = {
	Channels = {},
	NewVersionNotify = false,
	FirstScan = {},
}

XFG.Settings = {
	System = {
		Roster = true,
	},
	Expansions = {
		[WOW_PROJECT_MAINLINE] = 3601566,
		[WOW_PROJECT_CLASSIC] = 630785,
	--    [WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = 630783,
	--    [WOW_PROJECT_WRATH_OF_THE_LICH_KING_CLASSIC] = 630787,
	},
	Player = {
		Heartbeat = 60 * 2,      -- Seconds between player status broadcast
		MinimumHeartbeat = 15
	},
	Confederate = {
		UnitStale = 60 * 10,   -- Seconds before you consider another unit offline
		UnitScan = 60,       -- Seconds between offline checks
		DefaultTeams = {
			U = 'Unknown',
		},
		DefaultRealms = {
			[0] = 'Torghast',
		}
	},
	LocalGuild = {
		ScanTimer = 30,          -- Seconds between forced local guild scans
		LoginGiveUp = 60 * 5     -- Seconds before giving up on querying for guild on login
	},
	-- EK specific teams
	Teams = {
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
		ENK = 'Social',
		ENKA = 'Social',
		ENKH = 'Social',
		CC = 'CC'
	},
	Network = {
		CompressionLevel = 6,
		LoginLimit = 42,
		Channel = {
			Total = 10,
			Name = nil,
			Password = nil
		},
		BNet = {
			PacketSize = 420,
			Ping = {
				Timer = 60,         -- Seconds between pinging friends
			},
			Link = {
				Broadcast = 60 * 2, -- Seconds between broadcasting links
				Scan = 60 * 3,      -- Seconds between link scans for stale links
				Stale = 60 * 10,    -- Seconds until considering a link stale
				PercentStart = 10,  -- Number of links across confederate before random selection kicks in
			},
		},
		Message = {
			Subject = {
				DATA = '1',
				GCHAT = '2',
				LOGOUT = '3',
				LOGIN = '4',
				ACHIEVEMENT = '5',
				LINK = '6',
			},
			Tag = {},
		},
		Type = {
			BROADCAST = '1', -- BNet + Local Channel
			WHISPER = '2',   -- Whisper only
			LOCAL = '3',     -- Local Channel only
			BNET = '4',      -- BNet only
		},
		Mailbox = {
			Scan = 60 * 2,   -- Seconds between scanning mailbox for stale messages
			Stale = 60 * 5   -- Seconds until a message is considered stale
		},
	},
	Frames = {
		Chat = {
			Prepend = '&xfaction;',
		},
	},
	DataText = {
		AutoHide = .25,
	},
	Metric = {
		Messages = XFG.Lib.Locale['DTMETRICS_MESSAGES'],
		BNetSend = XFG.Lib.Locale['DTMETRICS_BNET_SEND'],
		BNetReceive = XFG.Lib.Locale['DTMETRICS_BNET_RECEIVE'],
		ChannelSend = XFG.Lib.Locale['DTMETRICS_CHANNEL_SEND'],
		ChannelReceive = XFG.Lib.Locale['DTMETRICS_CHANNEL_RECEIVE'],
		Error = XFG.Lib.Locale['DTMETRICS_ERROR'],
		Warning = XFG.Lib.Locale['DTMETRICS_WARNING'],
	},
	Factories = {
		Scan = 60 * 7,
		Purge = 60 * 30,
	}
}