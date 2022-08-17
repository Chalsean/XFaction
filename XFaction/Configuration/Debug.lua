local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Debug = {
	name = XFG.Lib.Locale['DEBUG'],
	order = 1,
	type = 'group',
	args = {
		Logging = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['DEBUG_LOG'],
			guiInline = true,
			args = {
				Enable = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DEBUG_LOG_ENABLE'],
					get = function(info) return XFG.Config.Debug[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.Debug[ info[#info] ] = value	
						XFG.DebugFlag = value
					end,
				},
				Verbosity = {
					order = 2,
					type = 'range',
					name = XFG.Lib.Locale['VERBOSITY'],
					desc = XFG.Lib.Locale['DEBUG_VERBOSITY_TOOLTIP'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					min = 1, max = 4, step = 1,
					get = function(info) return XFG.Config.Debug[ info[#info] ] end,
					set = function(info, value) XFG.Config.Debug[ info[#info] ] = value	end,
				},
			},
		},
		Print = {
			order = 2,
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
				Continent = {
					order = 4,
					type = 'execute',
					name = XFG.Lib.Locale['CONTINENT'],
					func = function(info) XFG.Continents:Print() end,
				},
				Covenant = {
					order = 5,
					type = 'execute',
					name = XFG.Lib.Locale['COVENANT'],
					func = function(info) XFG.Covenants:Print() end,
				},
				Event = {
					order = 6,
					type = 'execute',
					name = XFG.Lib.Locale['EVENT'],
					func = function(info) XFG.Events:Print() end,
				},
				Faction = {
					order = 7,
					type = 'execute',
					name = XFG.Lib.Locale['FACTION'],
					func = function(info) XFG.Factions:Print() end,
				},
				FactoryM = {
					order = 8,
					type = 'execute',
					name = XFG.Lib.Locale['FACTORY_MESSAGE'],
					func = function(info) XFG.Factories.Message:Print() end,
				},
				FactoryGM = {
					order = 9,
					type = 'execute',
					name = XFG.Lib.Locale['FACTORY_GUILD_MESSAGE'],
					func = function(info) XFG.Factories.GuildMessage:Print() end,
				},
				FactoryU = {
					order = 10,
					type = 'execute',
					name = XFG.Lib.Locale['FACTORY_UNIT'],
					func = function(info) XFG.Factories.Unit:Print() end,
				},
				Friend = {
					order = 11,
					type = 'execute',
					name = XFG.Lib.Locale['FRIEND'],
					func = function(info) XFG.Friends:Print() end,
				},
				Guild = {
					order = 12,
					type = 'execute',
					name = XFG.Lib.Locale['GUILD'],
					func = function(info) XFG.Guilds:Print() end,
				},
				Link = {
					order = 13,
					type = 'execute',
					name = XFG.Lib.Locale['LINK'],
					func = function(info) XFG.Links:Print() end,
				},
				Node = {
					order = 14,
					type = 'execute',
					name = XFG.Lib.Locale['NODE'],
					func = function(info) XFG.Nodes:Print() end,
				},
				Player = {
					order = 15,
					type = 'execute',
					name = XFG.Lib.Locale['PLAYER'],
					func = function(info) XFG.Player.Unit:Print() end,
				},
				Profession = {
					order = 16,
					type = 'execute',
					name = XFG.Lib.Locale['PROFESSION'],
					func = function(info) XFG.Professions:Print() end,
				},
				Race = {
					order = 17,
					type = 'execute',
					name = XFG.Lib.Locale['RACE'],
					func = function(info) XFG.Races:Print() end,
				},
				Realm = {
					order = 18,
					type = 'execute',
					name = XFG.Lib.Locale['REALM'],
					func = function(info) XFG.Realms:Print() end,
				},
				Soulbind = {
					order = 19,
					type = 'execute',
					name = XFG.Lib.Locale['SOULBIND'],
					func = function(info) XFG.Soulbinds:Print() end,					
				},
				Spec = {
					order = 20,
					type = 'execute',
					name = XFG.Lib.Locale['SPEC'],
					func = function(info) XFG.Specs:Print() end,
				},
				Target = {
					order = 21,
					type = 'execute',
					name = XFG.Lib.Locale['TARGET'],
					func = function(info) XFG.Targets:Print() end,
				},
				Team = {
					order = 22,
					type = 'execute',
					name = XFG.Lib.Locale['TEAM'],
					func = function(info) XFG.Teams:Print() end,
				},
				Timer = {
					order = 23,
					type = 'execute',
					name = XFG.Lib.Locale['TIMER'],
					func = function(info) XFG.Timers:Print() end,
				},
				Zone = {
					order = 24,
					type = 'execute',
					name = XFG.Lib.Locale['ZONE'],
					func = function(info) XFG.Zones:Print() end,
				},
			},
		},
	},
}