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
					set = function(info, value) end
				},
				Class = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Classes:Print() end,
					set = function(info, value) end
				},
				Confederate = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Confederate:Print() end,
					set = function(info, value) end
				},
				Covenant = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Covenants:Print() end,
					set = function(info, value) end
				},
				Event = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Events:Print() end,
					set = function(info, value) end
				},
				Faction = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Factions:Print() end,
					set = function(info, value) end
				},
				Friend = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Friends:Print() end,
					set = function(info, value) end
				},
				Guild = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Guilds:Print() end,
					set = function(info, value) end
				},
				Link = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Links:Print() end,
					set = function(info, value) end
				},
				Player = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Player.Unit:Print() end,
					set = function(info, value) end
				},
				Profession = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Professions:Print() end,
					set = function(info, value) end
				},
				Race = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Races:Print() end,
					set = function(info, value) end
				},
				Realm = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Realms:Print() end,
					set = function(info, value) end
				},
				Soulbind = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Soulbinds:Print() end,
					set = function(info, value) end
				},
				Spec = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Specs:Print() end,
					set = function(info, value) end
				},
				Target = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Targets:Print() end,
					set = function(info, value) end
				},
				Team = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Teams:Print() end,
					set = function(info, value) end
				},
				Timer = {
					order = 1,
					type = 'toggle',
					name = '',
					desc = '',
					get = function(info) XFG.Timers:Print() end,
					set = function(info, value) end
				},
			},
		},
	},	
}