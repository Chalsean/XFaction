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
			name = '',
			guiInline = true,
			args = {
				Channel = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Channels:Print() end,
					set = function(info, value) XFG.Channels:Print() end
				},
				Class = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Classes:Print() end,
					set = function(info, value) XFG.Classes:Print() end
				},
				Confederate = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Confederate:Print() end,
					set = function(info, value) XFG.Confederate:Print() end
				},
				Covenant = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Covenants:Print() end,
					set = function(info, value) XFG.Covenants:Print() end
				},
				Event = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Events:Print() end,
					set = function(info, value) XFG.Events:Print() end
				},
				Faction = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Factions:Print() end,
					set = function(info, value) XFG.Factions:Print() end
				},
				Friend = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Friends:Print() end,
					set = function(info, value) XFG.Friends:Print() end
				},
				Guild = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Guilds:Print() end,
					set = function(info, value) XFG.Guilds:Print() end
				},
				Link = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Links:Print() end,
					set = function(info, value) XFG.Links:Print() end
				},
				Player = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Player.Unit:Print() end,
					set = function(info, value) XFG.Player.Unit:Print() end
				},
				Profession = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Professions:Print() end,
					set = function(info, value) XFG.Professions:Print() end
				},
				Race = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Races:Print() end,
					set = function(info, value) XFG.Races:Print() end
				},
				Realm = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Realms:Print() end,
					set = function(info, value) XFG.Realms:Print() end
				},
				Soulbind = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Soulbinds:Print() end,
					set = function(info, value) XFG.Soulbinds:Print() end
				},
				Spec = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Specs:Print() end,
					set = function(info, value) XFG.Specs:Print() end
				},
				Target = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Targets:Print() end,
					set = function(info, value) XFG.Targets:Print() end
				},
				Team = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Teams:Print() end,
					set = function(info, value) XFG.Teams:Print() end
				},
				Timer = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Timers:Print() end,
					set = function(info, value) XFG.Timers:Print() end
				},
			},
		},
	},	
}