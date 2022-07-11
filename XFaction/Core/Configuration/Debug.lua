local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Debug = {
	name = '',
	order = 1,
	type = 'group',
	args = {
		Print = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['DEBUG_PRINT'],
			guiInline = true,
			args = {
				Channel = {
					order = 1,
					name = XFG.Lib.Locale['CHANNEL'],
					type = 'execute',
					func = function() XFG.Channels:Print() end,
				},
				Class = {
					order = 2,
					type = 'execute',
					name = XFG.Lib.Locale['CLASS'],
					func = function() XFG.Classes:Print() end,
				},
				Confederate = {
					order = 3,
					type = 'execute',
					name = XFG.Lib.Locale['CONFEDERATE'],
					func = function(info) XFG.Confederate:Print() end,
				},
				Covenant = {
					order = 4,
					type = 'execute',
					name = XFG.Lib.Locale['COVENANT'],
					func = function(info) XFG.Covenants:Print() end,
				},
				Event = {
					order = 5,
					type = 'execute',
					name = XFG.Lib.Locale['EVENT'],
					func = function(info) XFG.Events:Print() end,
				},
				Faction = {
					order = 6,
					type = 'execute',
					name = XFG.Lib.Locale['FACTION'],
					func = function(info) XFG.Factions:Print() end,
				},
				Friend = {
					order = 7,
					type = 'execute',
					name = XFG.Lib.Locale['FRIEND'],
					func = function(info) XFG.Friends:Print() end,
				},
				Guild = {
					order = 8,
					type = 'execute',
					name = XFG.Lib.Locale['GUILD'],
					func = function(info) XFG.Guilds:Print() end,
				},
				Link = {
					order = 9,
					type = 'execute',
					name = XFG.Lib.Locale['LINK'],
					func = function(info) XFG.Links:Print() end,
				},
				Player = {
					order = 10,
					type = 'execute',
					name = XFG.Lib.Locale['PLAYER'],
					func = function(info) XFG.Player.Unit:Print() end,
				},
				Profession = {
					order = 11,
					type = 'execute',
					name = XFG.Lib.Locale['PROFESSION'],
					func = function(info) XFG.Professions:Print() end,
				},
				Race = {
					order = 12,
					type = 'execute',
					name = XFG.Lib.Locale['RACE'],
					func = function(info) XFG.Races:Print() end,
				},
				Realm = {
					order = 13,
					type = 'execute',
					name = XFG.Lib.Locale['REALM'],
					func = function(info) XFG.Realms:Print() end,
				},
				Soulbind = {
					order = 14,
					type = 'execute',
					name = XFG.Lib.Locale['SOULBIND'],
					func = function(info) XFG.Soulbinds:Print() end,					
				},
				Spec = {
					order = 15,
					type = 'execute',
					name = XFG.Lib.Locale['SPEC'],
					func = function(info) XFG.Specs:Print() end,
				},
				Target = {
					order = 16,
					type = 'execute',
					name = XFG.Lib.Locale['TARGET'],
					func = function(info) XFG.Targets:Print() end,
				},
				Team = {
					order = 17,
					type = 'execute',
					name = XFG.Lib.Locale['TEAM'],
					func = function(info) XFG.Teams:Print() end,
				},
				Timer = {
					order = 18,
					type = 'execute',
					name = XFG.Lib.Locale['TIMER'],
					func = function(info) XFG.Timers:Print() end,
				},
			},
		},
	},	
}