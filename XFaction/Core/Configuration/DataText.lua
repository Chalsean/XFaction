local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.DataText = {
	name = XFG.Lib.Locale['DATATEXT'],
	order = 1,
	type = 'group',
	args = {
		Guild = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['DTGUILD_NAME'],
			guiInline = true,
			args = {
				Description1 = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_HEADER']
				},
				Space3 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Confederate = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['CONFEDERATE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				GuildName = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['GUILD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				MOTD = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['MOTD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_MOTD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line = {
					order = 6,
					type = 'header',
					name = ''
				},
				Description2 = {
					order = 7,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_HEADER']
				},
				Space4 = {
					order = 8,
					type = 'description',
					name = '',
				},
				Achievement = {
					order = 9,
					type = 'toggle',
					name = XFG.Lib.Locale['ACHIEVEMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Covenant = {
					order = 10,
					type = 'toggle',
					name = XFG.Lib.Locale['COVENANT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Dungeon = {
					order = 11,
					type = 'toggle',
					name = XFG.Lib.Locale['DUNGEON'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Faction = {
					order = 12,
					type = 'toggle',
					name = XFG.Lib.Locale['FACTION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Guild = {
					order = 13,
					type = 'toggle',
					name = XFG.Lib.Locale['GUILD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Level = {
					order = 14,
					type = 'toggle',
					name = XFG.Lib.Locale['LEVEL'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Note = {
					order = 15,
					type = 'toggle',
					name = XFG.Lib.Locale['NOTE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Profession = {
					order = 16,
					type = 'toggle',
					name = XFG.Lib.Locale['PROFESSION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Race = {
					order = 17,
					type = 'toggle',
					name = XFG.Lib.Locale['RACE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Rank = {
					order = 18,
					type = 'toggle',
					name = XFG.Lib.Locale['RANK'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Realm = {
					order = 19,
					type = 'toggle',
					name = XFG.Lib.Locale['REALM'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Spec = {
					order = 20,
					type = 'toggle',
					name = XFG.Lib.Locale['SPEC'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Team = {
					order = 21,
					type = 'toggle',
					name = XFG.Lib.Locale['TEAM'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Zone = {
					order = 22,
					type = 'toggle',
					name = XFG.Lib.Locale['ZONE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
			}
		},				
		Links = {
			order = 2,
			type = 'group',
			name = XFG.Lib.Locale['DTLINKS_NAME'],
			guiInline = true,
			args = {
				OnlyMine = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['DTLINKS_CONFIG_ONLY_YOURS'],
					desc = XFG.Lib.Locale['DTLINKS_CONFIG_ONLY_YOURS_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Links[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Links[ info[#info] ] = value; end
				},						
			}
		},
		Shard = {
			order = 3,
			type = 'group',
			name = XFG.Lib.Locale['DTSHARD_NAME'],
			guiInline = true,
			args = {
				Timer = {
					order = 1,
					type = 'range',
					name = XFG.Lib.Locale['DTSHARD_CONFIG_FORCE_CHECK'],
					min = 15, max = 300, step = 1,
					desc = XFG.Lib.Locale['DTSHARD_CONFIG_FORCE_CHECK_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Shard[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Shard[ info[#info] ] = value; end
				},						
			}
		},
		Soulbind = {
			order = 4,
			type = 'group',
			name = XFG.Lib.Locale['DTSOULBIND_NAME'],
			guiInline = true,
			args = {
				Timer = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['DTSOULBIND_CONFIG_CONDUIT'],
					disabled = true,
					desc = XFG.Lib.Locale['DTSOULBIND_CONFIG_CONDUIT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Soulbind[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Soulbind[ info[#info] ] = value; end
				},						
			}
		}
	}
}