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
				Instance = {
					order = 2,
					type = 'toggle',
					name = XFG.Lib.Locale['DEBUG_LOG_INSTANCE'],
					desc = XFG.Lib.Locale['DEBUG_LOG_INSTANCE_TOOLTIP'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					get = function(info) return XFG.Config.Debug[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.Debug[ info[#info] ] = value
						XFG.DebugFlag = XFG.Config.Debug.Enable
					end,
				},
				Verbosity = {
					order = 3,
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
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function() XFG.Channels:Print() end,
				},
				Class = {
					order = 2,
					type = 'execute',
					name = XFG.Lib.Locale['CLASS'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function() XFG.Classes:Print() end,
				},
				Confederate = {
					order = 3,
					type = 'execute',
					name = XFG.Lib.Locale['CONFEDERATE'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Confederate:Print() end,
				},
				Continent = {
					order = 4,
					type = 'execute',
					name = XFG.Lib.Locale['CONTINENT'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Continents:Print() end,
				},
				Event = {
					order = 6,
					type = 'execute',
					name = XFG.Lib.Locale['EVENT'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Events:Print() end,
				},
				Faction = {
					order = 7,
					type = 'execute',
					name = XFG.Lib.Locale['FACTION'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Factions:Print() end,
				},
				Friend = {
					order = 14,
					type = 'execute',
					name = XFG.Lib.Locale['FRIEND'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Friends:Print() end,
				},
				Guild = {
					order = 15,
					type = 'execute',
					name = XFG.Lib.Locale['GUILD'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Guilds:Print() end,
				},
				Link = {
					order = 16,
					type = 'execute',
					name = XFG.Lib.Locale['LINK'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Links:Print() end,
				},
				Node = {
					order = 17,
					type = 'execute',
					name = XFG.Lib.Locale['NODE'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Nodes:Print() end,
				},
				Player = {
					order = 18,
					type = 'execute',
					name = XFG.Lib.Locale['PLAYER'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Player.Unit:Print() end,
				},
				Profession = {
					order = 19,
					type = 'execute',
					name = 	XFG.Lib.Locale['PROFESSION'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Professions:Print() end,
				},
				Race = {
					order = 20,
					type = 'execute',
					name = XFG.Lib.Locale['RACE'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Races:Print() end,
				},
				RaiderIO = {
					order = 21,
					type = 'execute',
					name = XFG.Lib.Locale['RAIDERIO'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.RaidIO:Print() end,					
				},
				Realm = {
					order = 22,
					type = 'execute',
					name = XFG.Lib.Locale['REALM'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Realms:Print() end,
				},				
				Spec = {
					order = 24,
					type = 'execute',
					name = XFG.Lib.Locale['SPEC'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Specs:Print() end,
				},
				Target = {
					order = 25,
					type = 'execute',
					name = XFG.Lib.Locale['TARGET'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Targets:Print() end,
				},
				Team = {
					order = 26,
					type = 'execute',
					name = XFG.Lib.Locale['TEAM'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Teams:Print() end,
				},
				Timer = {
					order = 27,
					type = 'execute',
					name = XFG.Lib.Locale['TIMER'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Timers:Print() end,
				},
				Zone = {
					order = 28,
					type = 'execute',
					name = XFG.Lib.Locale['ZONE'],
					disabled = function () return not XFG.Config.Debug.Enable end,
					func = function(info) XFG.Zones:Print() end,
				},
			},
		},
	},
}