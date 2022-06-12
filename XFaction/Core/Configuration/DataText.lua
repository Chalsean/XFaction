local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function DefaultConfigs()
	if(XFG.Config.DataText == nil) then XFG.Config.DataText = {} end
	if(XFG.Config.DataText.Guild == nil) then XFG.Config.DataText.Guild = {} end
	if(XFG.Config.DataText.Guild.GuildName == nil) then XFG.Config.DataText.Guild.GuildName = true end
	if(XFG.Config.DataText.Guild.Confederate == nil) then XFG.Config.DataText.Guild.Confederate = true end
	if(XFG.Config.DataText.Guild.MOTD == nil) then XFG.Config.DataText.Guild.MOTD = true end

	if(XFG.Config.DataText.Guild.Covenant == nil) then XFG.Config.DataText.Guild.Covenant = true end
	if(XFG.Config.DataText.Guild.Faction == nil) then XFG.Config.DataText.Guild.Faction = true end
	if(XFG.Config.DataText.Guild.Guild == nil) then XFG.Config.DataText.Guild.Guild = true end
	if(XFG.Config.DataText.Guild.Level == nil) then XFG.Config.DataText.Guild.Level = true end
	if(XFG.Config.DataText.Guild.Note == nil) then XFG.Config.DataText.Guild.Note = false end
	if(XFG.Config.DataText.Guild.Profession == nil) then XFG.Config.DataText.Guild.Profession = true end
	if(XFG.Config.DataText.Guild.Race == nil) then XFG.Config.DataText.Guild.Race = true end
	if(XFG.Config.DataText.Guild.Rank == nil) then XFG.Config.DataText.Guild.Rank = true end
	if(XFG.Config.DataText.Guild.Realm == nil) then XFG.Config.DataText.Guild.Realm = false end
	if(XFG.Config.DataText.Guild.Spec == nil) then XFG.Config.DataText.Guild.Spec = true end
	if(XFG.Config.DataText.Guild.Team == nil) then XFG.Config.DataText.Guild.Team = true end
	if(XFG.Config.DataText.Guild.Zone == nil) then XFG.Config.DataText.Guild.Zone = true end

	if(XFG.Config.DataText.Links == nil) then XFG.Config.DataText.Links = {} end
	if(XFG.Config.DataText.Links.OnlyMine == nil) then XFG.Config.DataText.Links.OnlyMine = false end

	if(XFG.Config.DataText.Shard == nil) then XFG.Config.DataText.Shard = {} end
	if(XFG.Config.DataText.Shard.Timer == nil) then XFG.Config.DataText.Shard.Timer = 60 end

	if(XFG.Config.DataText.Soulbind == nil) then XFG.Config.DataText.Soulbind = {} end
	if(XFG.Config.DataText.Soulbind.Conduits == nil) then XFG.Config.DataText.Soulbind.Conduits = true end
end

function XFG:DataTextConfig()
	DefaultConfigs()
	XFG.Options.DataText = {
		name = XFG.Lib.Locale['DT_HEADER'],
		order = 1,
		type = 'group',
		args = {
			XGuild = {
				order = 1,
				type = 'group',
				name = XFG.Lib.Locale['DTGUILD_NAME'],
				guiInline = true,
				args = {
					Description1 = {
						order = 1,
						type = 'description',
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
						name = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_HEADER']
					},
					Space4 = {
						order = 8,
						type = 'description',
						name = '',
					},
					Covenant = {
						order = 9,
						type = 'toggle',
						name = XFG.Lib.Locale['COVENANT'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Faction = {
						order = 10,
						type = 'toggle',
						name = XFG.Lib.Locale['FACTION'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Guild = {
						order = 11,
						type = 'toggle',
						name = XFG.Lib.Locale['GUILD'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Level = {
						order = 12,
						type = 'toggle',
						name = XFG.Lib.Locale['LEVEL'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Note = {
						order = 13,
						type = 'toggle',
						name = XFG.Lib.Locale['NOTE'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Profession = {
						order = 14,
						type = 'toggle',
						name = XFG.Lib.Locale['PROFESSION'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Race = {
						order = 15,
						type = 'toggle',
						name = XFG.Lib.Locale['RACE'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Rank = {
						order = 16,
						type = 'toggle',
						name = XFG.Lib.Locale['RANK'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Realm = {
						order = 17,
						type = 'toggle',
						name = XFG.Lib.Locale['REALM'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Spec = {
						order = 18,
						type = 'toggle',
						name = XFG.Lib.Locale['SPEC'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Team = {
						order = 19,
						type = 'toggle',
						name = XFG.Lib.Locale['TEAM'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Zone = {
						order = 20,
						type = 'toggle',
						name = XFG.Lib.Locale['ZONE'],
						desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
				}
			},				
			XLinks = {
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
			XShard = {
				order = 3,
				type = 'group',
				name = XFG.Lib.Locale['DTSHARD_NAME'],
				guiInline = true,
				args = {
					Timer = {
						order = 1,
						type = 'range',
						name = XFG.Lib.Locale['DTLINKS_CONFIG_FORCE_CHECK'],
						min = 15, max = 300, step = 1,
						desc = XFG.Lib.Locale['DTLINKS_CONFIG_FORCE_CHECK_TOOLTIP'],
						get = function(info) return XFG.Config.DataText.Shard[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Shard[ info[#info] ] = value; end
					},						
				}
			},
			XSoulbind = {
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

	XFG.Lib.Config:RegisterOptionsTable('XFaction DataText', XFG.Options.DataText)
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction DataText', 'DataText', 'XFaction')
end