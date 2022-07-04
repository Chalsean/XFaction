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
				Description = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DT_CONFIG_BROKER']
				},
				Space = {
					order = 2,
					type = 'description',
					name = '',
				},
				Label = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['LABEL'],
					desc = XFG.Lib.Locale['DT_CONFIG_LABEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild[ info[#info] ] = value;
						XFG.DataText.Guild:RefreshBroker()
					end
				},
				Line = {
					order = 4,
					type = 'header',
					name = ''
				},
				Description1 = {
					order = 5,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_HEADER']
				},
				Space3 = {
					order = 6,
					type = 'description',
					name = '',
				},
				Confederate = {
					order = 7,
					type = 'toggle',
					name = XFG.Lib.Locale['CONFEDERATE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				GuildName = {
					order = 8,
					type = 'toggle',
					name = XFG.Lib.Locale['GUILD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				MOTD = {
					order = 9,
					type = 'toggle',
					name = XFG.Lib.Locale['MOTD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_MOTD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line1 = {
					order = 10,
					type = 'header',
					name = ''
				},
				Description2 = {
					order = 11,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_HEADER']
				},
				Space4 = {
					order = 12,
					type = 'description',
					name = '',
				},
				Achievement = {
					order = 13,
					type = 'toggle',
					name = XFG.Lib.Locale['ACHIEVEMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Covenant = {
					order = 14,
					type = 'toggle',
					name = XFG.Lib.Locale['COVENANT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Faction = {
					order = 15,
					type = 'toggle',
					name = XFG.Lib.Locale['FACTION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Guild = {
					order = 16,
					type = 'toggle',
					name = XFG.Lib.Locale['GUILD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Level = {
					order = 17,
					type = 'toggle',
					name = XFG.Lib.Locale['LEVEL'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Main = {
					order = 18,
					type = 'toggle',
					name = XFG.Lib.Locale['MAIN'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Dungeon = {  -- Mythic+
					order = 19,
					type = 'toggle',
					name = XFG.Lib.Locale['DUNGEON'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Note = {
					order = 20,
					type = 'toggle',
					name = XFG.Lib.Locale['NOTE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Profession = {
					order = 21,
					type = 'toggle',
					name = XFG.Lib.Locale['PROFESSION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Race = {
					order = 22,
					type = 'toggle',
					name = XFG.Lib.Locale['RACE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Rank = {
					order = 23,
					type = 'toggle',
					name = XFG.Lib.Locale['RANK'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Realm = {
					order = 24,
					type = 'toggle',
					name = XFG.Lib.Locale['REALM'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Spec = {
					order = 25,
					type = 'toggle',
					name = XFG.Lib.Locale['SPEC'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Team = {
					order = 26,
					type = 'toggle',
					name = XFG.Lib.Locale['TEAM'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Version = {
					order = 27,
					type = 'toggle',
					name = XFG.Lib.Locale['VERSION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Zone = {
					order = 28,
					type = 'toggle',
					name = XFG.Lib.Locale['ZONE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line2 = {
					order = 29,
					type = 'header',
					name = ''
				},
				Sort = {
					order = 30,
					type = 'select',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_SORT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_SORT_TOOLTIP'],
					values = {
						Achievement = XFG.Lib.Locale['ACHIEVEMENT'],
						Guild = XFG.Lib.Locale['GUILD'],
						Level = XFG.Lib.Locale['LEVEL'],            
						Dungeon = XFG.Lib.Locale['DUNGEON'],
                        Name = XFG.Lib.Locale['NAME'],
						Note = XFG.Lib.Locale['NOTE'],
						Race = XFG.Lib.Locale['RACE'],
						Rank = XFG.Lib.Locale['RANK'],
						Realm = XFG.Lib.Locale['REALM'],
						Team = XFG.Lib.Locale['TEAM'],
						Version = XFG.Lib.Locale['VERSION'],
						Zone = XFG.Lib.Locale['ZONE'],
                    },
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Size = {
					order = 31,
					type = 'range',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_SIZE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_SIZE_TOOLTIP'],
					min = 200, max = 1000, step = 5,
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
            },
		},
		Link = {
			order = 2,
			type = 'group',
			name = XFG.Lib.Locale['DTLINKS_NAME'],
			guiInline = true,
			args = {
				Description = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DT_CONFIG_BROKER']
				},
				Space = {
					order = 2,
					type = 'description',
					name = '',
				},
				Faction = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['FACTION'],
					desc = XFG.Lib.Locale['DT_CONFIG_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Link[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Link[ info[#info] ] = value;
						XFG.DataText.Links:RefreshBroker()
					end
				},
				Label = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['LABEL'],
					desc = XFG.Lib.Locale['DT_CONFIG_LABEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Link[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Link[ info[#info] ] = value;
						XFG.DataText.Links:RefreshBroker()
					end
				},
			},
		},
	},	
}