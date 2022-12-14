local addon, Engine = ...
local LogCategory = 'Constants'

--#region XFG Instantiation
local XFG = {}
setmetatable(XFG, self)

Engine[1] = XFG
Engine[2] = G
_G[addon] = Engine

XFG.AddonName = addon
XFG.Name = 'XFaction'
XFG.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XFG.Version = GetAddOnMetadata(addon, 'Version')
XFG.Start = GetServerTime()
XFG.Verbosity = 4

XFG.Addons = {
	ElvUI = {},
}
XFG.DataText = {}
XFG.Factories = {}
XFG.Frames = {}
XFG.Handlers = {}
XFG.Mailbox = {}
XFG.Options = {}

XFG.Initialized = false

XFG.Player = {
	LastBroadcast = 0,
	InInstance = false
}
--#endregion

--#region Libraries
XFG.Lib = {
	Deflate = LibStub:GetLibrary('LibDeflate'),
	QT = LibStub('LibQTip-1.0'),
	Broker = LibStub('LibDataBroker-1.1'),
	Locale = LibStub('AceLocale-3.0'):GetLocale(XFG.Name, true),
	Config = LibStub('AceConfigRegistry-3.0'),
	ConfigDialog = LibStub('MSA-AceConfigDialog-3.0'),
	LSM = LibStub('LibSharedMedia-3.0'),
	Event = LibStub('AceEvent-3.0'),
}
XFG.Lib.BCTL = assert(BNetChatThrottleLib, 'XFaction requires BNetChatThrottleLib')
--#endregion

--#region Program Settings
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
	Neutral = 132311,
	Gold = [[|TInterface\MONEYFRAME\UI-GoldIcon:16:16|t]],
	Guild = 'ElvUI-Windtools-Healer', -- Kept the name to give credit to Windtools
}

XFG.Settings = {
	System = {
		Roster = true,
		UIDLength = 11,
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
			['?'] = 'Unknown',
		},
		DefaultRealms = {
			[0] = 'Torghast',
		}
	},
	LocalGuild = {
		ScanTimer = 30,          -- Seconds between forced local guild scans
		LoginGiveUp = 60 * 5,    -- Seconds before giving up on querying for guild on login
		MaxGuildInfo = 500,      -- Maximum # of characters guild info can take
	},	
	Factions = {'Alliance', 'Horde', 'Neutral'},
	Network = {
		CompressionLevel = 9,
		Channel = {
			Total = 10,
		},
		Chat = {
			PacketSize = 217,
		},
		BNet = {	
			PacketSize = 425,	
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
				JOIN = '7',
			},
			Tag = {},
			IPC = {
				ADDON_LOADED = 'XFADDON_LOADED',
				CACHE_LOADED = 'XFCACHE_LOADED',
				CONFIG_LOADED = 'XFCONFIG_LOADED',
				REALMS_LOADED = 'XFREALM_LOADED',
				ROSTER_INIT = 'XFROSTER_INIT',
				ROSTER_UPDATED = 'XFROSTER_UPDATED',
				TEAMS_LOADED = 'XFTEAMS_LOADED',
				INITIALIZED = 'XFINIT',
				LINKS_UPDATED = 'XFLINKS_UPDATED',
				NODES_UPDATED = 'XFNODES_UPDATED',
			},
		},
		Type = {
			BROADCAST = '1', -- BNet + Local Channel
			WHISPER = '2',   -- Whisper only
			LOCAL = '3',     -- Local Channel only
			BNET = '4',      -- BNet only
		},		
		Mailbox = {
			Scan = 60 * 2,   -- Seconds between scanning mailbox for stale messages
			Stale = 60 * 15   -- Seconds until a message is considered stale
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
	},
	Profession = {
		Total = 100,
	},
	Race = {
		Total = 100,
	},
	Setup = {
		MaxTeams = 30,
		MaxGuilds = 10,
	},
}
--#endregion