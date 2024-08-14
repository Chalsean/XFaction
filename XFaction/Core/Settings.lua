local addon, Engine = ...
local LogCategory = 'Constants'

--#region XF Instantiation
local XF = {}
setmetatable(XF, self)

Engine[1] = XF
Engine[2] = G
_G[addon] = Engine

XF.AddonName = addon
XF.Name = 'XFaction'
XF.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XF.Version = C_AddOns.GetAddOnMetadata(addon, 'Version')
XF.Start = GetServerTime()
XF.Verbosity = 4

XF.Class = {}
XF.Function = {}
XF.Object = {}

XF.Addons = {
	ElvUI = {},
}
XF.ChangeLog = {}
XF.DataText = {}
XF.Factories = {}
XF.Frames = {}
XF.Handlers = {}
XF.Mailbox = {}
XF.Options = {}

XF.Initialized = false

XF.Player = {
	LastBroadcast = 0,
	InInstance = false
}
--#endregion

--#region Libraries
XF.Lib = {
	Deflate = LibStub:GetLibrary('LibDeflate'),
	QT = LibStub('LibQTip-1.0'),
	Broker = LibStub('LibDataBroker-1.1'),
	Locale = LibStub('AceLocale-3.0'):GetLocale(XF.Name, true),
	Config = LibStub('AceConfigRegistry-3.0'),
	ConfigDialog = LibStub('MSA-AceConfigDialog-3.0'),
	LSM = LibStub('LibSharedMedia-3.0')
}
XF.Lib.BCTL = assert(BNetChatThrottleLib, 'XFaction requires BNetChatThrottleLib')
--#endregion

--#region Program Settings
XF.Icons = {
	String = '|T%d:16:16:0:0:64:64:4:60:4:60|t',
	Texture = '|T%s:17:17|t',
	WoWToken = 1121394,
	Alliance = 2565243,
	Horde = 463451,
	Neutral = 132311,
	Gold = [[|TInterface\MONEYFRAME\UI-GoldIcon:16:16|t]],
	Guild = 'ElvUI-Windtools-Healer', -- Kept the name to give credit to Windtools
}

XF.Enum = {
	Version = {
		Prod = 1,
		Beta = 2,
		Alpha = 3,
	},
	Priority = {
		High = 1,
		Medium = 2,
		Low = 3,
	},
	Channel = {
		GUILD = 1,
		COMMUNITY = 2,
		CUSTOM = 3,
	},
	Message = {
		DATA = '1',
		GCHAT = '2',
		LOGOUT = '3',
		LOGIN = '4',
		ACHIEVEMENT = '5',
		LINK = '6',
		ORDER = '7',
		PING = '8',
		ACK = '9'
	},
	Metric = {
		Messages = XF.Lib.Locale['DTMETRICS_MESSAGES'],
		BNetSend = XF.Lib.Locale['DTMETRICS_BNET_SEND'],
		BNetReceive = XF.Lib.Locale['DTMETRICS_BNET_RECEIVE'],
		ChannelSend = XF.Lib.Locale['DTMETRICS_CHANNEL_SEND'],
		ChannelReceive = XF.Lib.Locale['DTMETRICS_CHANNEL_RECEIVE'],
		Error = XF.Lib.Locale['DTMETRICS_ERROR'],
		Warning = XF.Lib.Locale['DTMETRICS_WARNING'],
	},
    Protocol = {
        Unknown = 1,
        BNet = 2,
        Chat = 3,
        Whisper = 4
    }
}

XF.Settings = {
	System = {
		Roster = true,
		UIDLength = 11,
	},
	Expansions = {
		WOW_PROJECT_MAINLINE,
		WOW_PROJECT_CLASSIC,
	},
	Player = {
		Heartbeat = 60 * 2,      -- Seconds between player status broadcast
		MinimumHeartbeat = 15,
		Retry = 60,              -- Number of times to try and get player information before giving up
	},
	Confederate = {
		UnitStale = 60 * 10,   -- Seconds before you consider another unit offline
		UnitScan = 60,         -- Seconds between offline checks
	},
	LocalGuild = {
		ScanTimer = 5,           -- Seconds between local guild scans
		LoginTTL = 60 * 5,       -- Seconds before giving up on querying for guild on login
		MaxGuildInfo = 500,      -- Maximum # of characters guild info can take
	},	
	Factions = {'Alliance', 'Horde', 'Neutral'},
	Network = {
		CompressionLevel = 9,
		Channel = {
			Total = 10,
			NoticeTimer = 2,
			LoginChannelSyncTimer = 5,
			LoginChannelSyncAttempts = 6,
		},
		Chat = {
			PacketSize = 217,
		},
		BNet = {
			FriendTimer = 2,
			PacketSize = 425,	
			Ping = {
				Timer = 60 * 2,     -- Seconds between pinging friends
			},
		},
		Mailbox = {
			Scan = 60 * 2,   -- Seconds between scanning mailbox for stale messages
			Stale = 60 * 60  -- Seconds until a message is considered stale
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
	Factories = {
		Scan = 60 * 7,
		Purge = 60 * 30,
	},
	Setup = {
		MaxTeams = 30,
		MaxGuilds = 10,
	},
}
--#endregion