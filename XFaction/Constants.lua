local addon, Engine = ...
local LogCategory = 'Constants'

local XFG = LibStub('AceAddon-3.0'):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")

Engine[1] = XFG
Engine[2] = G
_G[addon] = Engine

XFG.AddonName = addon
XFG.Category = 'XFaction'
XFG.Title = '|cffFF4700X|r|cff33ccffFaction|r'
XFG.Version = GetAddOnMetadata(addon, "Version")
XFG.Handlers = {}

XFG.Initialized = false

XFG.Icons = {
	String = '|T%d:16:16:0:0:64:64:4:60:4:60|t',
	WoWToken = 1121394,
	Kyrian = 3257748,
	Venthyr = 3257751,
	['Night Fae'] = 3257750,
	Necrolord = 3257749,
	Alliance = 2565243,
	Horde = 463451,
	Gold = [[|TInterface\MONEYFRAME\UI-GoldIcon:16:16|t]],
}

XFG.Lib = {
	Compress = LibStub:GetLibrary("LibCompress"),	
	QT = LibStub('LibQTip-1.0'),
	Realm = LibStub:GetLibrary('LibRealmInfo'),
	Broker = LibStub('LibDataBroker-1.1'),
	Config = LibStub('AceConfig-3.0'),
	ConfigDialog = LibStub('AceConfigDialog-3.0'),
	Locale = LibStub('AceLocale-3.0'):GetLocale(XFG.Category, true),
}
XFG.Lib.Encode = XFG.Lib.Compress:GetAddonEncodeTable()

XFG.DataText = {
	AutoHide = 2
}

XFG.Player = {
	LastBroadcast = 0
}

XFG.Frames = {}
XFG.Cache = {
	Channels = {}
}

XFG.Settings = {
	Confederate = {
		Name = 'Eternal Kingdom',
		Initials = 'EK',
		OfflineDelta = 60 * 5   -- Seconds before you consider another unit offline
	},
	Guilds = {
		Proudmoore = {
			Alliance = {
				EKA = 'Eternal Kingdom', 
				ENK = 'Endless Kingdom', 
				AK  = 'Alternal Kingdom', 
				AK2 = 'Alternal Kingdom Two', 
				AK3 = 'Alternal Kingdom Three'
			},
			Horde = {
				AK4 = 'Alternal Kingdom Four', 
				EKH = 'Eternal Kingdom Horde',
				EDK = 'EDK Bank'
			}
		},
	},
	Ranks = {
		['1'] = 'Guild Master',
		['2'] = 'Chancellor',
		['3'] = 'Master of Coin',
		['4'] = 'Royal Emissary',
		['5'] = 'Ambassador',
		['6'] = 'Templar',
		['7'] = 'Grand Army',
		['8'] = 'Grand Alt',
		['9'] = 'Noble Citizen',
		['10'] = 'Squire',
		['11'] = 'Stockade'
	},
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
		U = 'Unknown',
		ENK = 'Social',
		ENKA = 'Social',
		ENKH = 'Social'
	},
	Channels = {},
	DataText = {
		Guild = {
			Ranks = {}
		}
	},
	Races = {
		Total = 37
	},
	Professions = {
		Herbalism = {
			ID = 182,
			Icon = 136065
		}, 
		Mining = {
			ID = 186,
			Icon = 136248
		}, 
		Tailoring = {
			ID = 197,
			Icon = 136249
		}, 
		Engineering = {
			ID = 202,
			Icon = 136243
		}, 
		Alchemy = {
			ID = 171,
			Icon = 136240
		}, 
		Inscription = {
			ID = 773,
			Icon = 237171
		}, 
		Leatherworking = {
			ID = 165,
			Icon = 133611
		}, 
		Enchanting = {
			ID = 333,
			Icon = 136244
		}, 
		Blacksmithing = {
			ID = 164,
			Icon = 136241
		}, 
		Jewelcrafting = {
			ID = 755,
			Icon = 134071
		}, 
		Skinning = {
			ID = 393,
			Icon = 134366
		}
	},
	Specs = {
		250,
		251,
		252,
		577,
		581,
		102,
		103,
		104,
		105,
		253,
		254,
		255,
		62,
		63,
		64,
		268,
		269,
		270,
		65,
		66,
		70,
		256,
		257,
		258,
		259,
		260,
		261,
		262,
		263,
		264,
		265,
		266,
		267,
		71,
		72,
		73
	},
}

XFG.Network = {
	BNet = {
		PingTimer = 60 * 5,
		LinksTimer = 60 * 10
	},
	Channel = {
		-- This is the default, gets changed if configured properly in guild info
		Name = XFG.Settings.Confederate.Initials .. 'XFactionChat',
		Password = ''
	},
	Message = {
		Subject = {
			DATA = '1',
			GCHAT = '2',
			LOGOUT = '3',
			LOGIN = '4',
			ACHIEVEMENT = '5',
			LINK = '6'
		},
		Tag = {
			LOCAL = XFG.Settings.Confederate.Initials .. 'XF',
			BNET  = XFG.Settings.Confederate.Initials .. 'BNET'
		}
	},
	Type = {
		BROADCAST = '1', -- BNet + Local Channel
		LOCAL = '3',     -- Local Channel only
		BNET = '4'       -- BNet only
	}
}