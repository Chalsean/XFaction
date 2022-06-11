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
		name = 'XFaction - DataText',
		order = 1,
		type = 'group',
		args = {
			XGuild = {
				order = 1,
				type = 'group',
				name = 'Guild (X)',
				guiInline = true,
				args = {
					Description1 = {
						order = 1,
						type = 'description',
						name = '     Show Header Fields'
					},
					Space3 = {
						order = 2,
						type = 'description',
						name = '',
					},
					Confederate = {
						order = 3,
						type = 'toggle',
						name = 'Confederate',
						desc = 'Show name of the confederate',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					GuildName = {
						order = 4,
						type = 'toggle',
						name = 'Guild',
						desc = 'Show name of the current guild',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					MOTD = {
						order = 5,
						type = 'toggle',
						name = 'MOTD',
						desc = 'Show guild message-of-the-day',
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
						name = '     Show Columns'
					},
					Space4 = {
						order = 8,
						type = 'description',
						name = '',
					},
					Covenant = {
						order = 9,
						type = 'toggle',
						name = 'Covenant',
						desc = 'Show players covenant icon',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Faction = {
						order = 10,
						type = 'toggle',
						name = 'Faction',
						desc = 'Show players faction icon',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Guild = {
						order = 11,
						type = 'toggle',
						name = 'Guild',
						desc = 'Show players guild name',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Level = {
						order = 12,
						type = 'toggle',
						name = 'Level',
						desc = 'Show players level',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Note = {
						order = 13,
						type = 'toggle',
						name = 'Note',
						desc = 'Show players note',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Profession = {
						order = 14,
						type = 'toggle',
						name = 'Profession',
						desc = 'Show players profession icons',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Race = {
						order = 15,
						type = 'toggle',
						name = 'Race',
						desc = 'Show players race',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Rank = {
						order = 16,
						type = 'toggle',
						name = 'Rank',
						desc = 'Show players guild rank',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Realm = {
						order = 17,
						type = 'toggle',
						name = 'Realm',
						desc = 'Show players realm name',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Spec = {
						order = 18,
						type = 'toggle',
						name = 'Spec',
						desc = 'Show players spec icon',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Team = {
						order = 19,
						type = 'toggle',
						name = 'Team',
						desc = 'Show players team name',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
					Zone = {
						order = 20,
						type = 'toggle',
						name = 'Zone',
						desc = 'Show players current zone',
						get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
					},
				}
			},				
			XLinks = {
				order = 2,
				type = 'group',
				name = 'Links (X)',
				guiInline = true,
				args = {
					OnlyMine = {
						order = 1,
						type = 'toggle',
						name = 'Show Only Mine',
						desc = 'Show only your active links',
						get = function(info) return XFG.Config.DataText.Links[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Links[ info[#info] ] = value; end
					},						
				}
			},
			XShard = {
				order = 2,
				type = 'group',
				name = 'Shard (X)',
				guiInline = true,
				args = {
					Timer = {
						order = 1,
						type = 'range',
						name = 'Force Check',
						min = 15, max = 300, step = 1,
						desc = 'Seconds until forced to check shard',
						get = function(info) return XFG.Config.DataText.Shard[ info[#info] ] end,
						set = function(info, value) XFG.Config.DataText.Shard[ info[#info] ] = value; XFG.Lib.DT:ForceUpdate_DataText(XFG.DataText.Shard.Name); end
					},						
				}
			},
			XSoulbind = {
				order = 2,
				type = 'group',
				name = 'Soulbind (X)',
				guiInline = true,
				args = {
					Timer = {
						order = 1,
						type = 'toggle',
						name = 'Show Conduits',
						disabled = true,
						desc = 'Show active conduit icons',
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