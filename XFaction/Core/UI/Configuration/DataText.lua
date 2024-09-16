local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local LogCategory = 'Config'

--#region DTGuild
local function KeysSortedByValue(tbl, sortFunction)
	local keys = {}
	for key in pairs(tbl) do
		if(XF.Config.DataText.Guild.Enable[key]) then
	  		table.insert(keys, key)
		end
	end
  
	table.sort(keys, function(a, b)
	  return sortFunction(tonumber(tbl[a]), tonumber(tbl[b]))
	end)
  
	return keys
end

function XF:SortGuildColumns()
	local order = KeysSortedByValue(XF.Config.DataText.Guild.Order, function(a, b) return a < b end)
	for i = 1, #order do
		local key = order[i]
		XF.Config.DataText.Guild.Order[key] = i
	end
end

local function GuildOrderMenu()
	if(XF.Cache.DTGuildTotalEnabled == nil) then XF.Cache.DTGuildTotalEnabled = 0 end
	if(XF.Cache.DTGuildTotalEnabled == 0) then
		for column, isEnabled in pairs (XF.Config.DataText.Guild.Enable) do
			if(isEnabled and XF.Config.DataText.Guild.Order[column] ~= 0) then
				XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled + 1
			end
		end
	end

	local menu = {}
	for i = 1, XF.Cache.DTGuildTotalEnabled do
		menu[tostring(i)] = i
	end

	return menu
end

local function GuildRemovedMenuItem(inColumnName)
	local index = tonumber(XF.Config.DataText.Guild.Order[inColumnName])
	XF.Config.DataText.Guild.Order[inColumnName] = 0
	XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled - 1
	for column, order in pairs (XF.Config.DataText.Guild.Order) do
		order = tonumber(order)
		if(order > index) then
			XF.Config.DataText.Guild.Order[column] = order - 1
		end
	end
end

local function GuildAddedMenuItem(inColumnName)
	XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled + 1
	XF.Config.DataText.Guild.Order[inColumnName] = XF.Cache.DTGuildTotalEnabled
end

local function GuildSelectedMenuItem(inColumnName, inSelection)
	local oldNumber = tonumber(XF.Config.DataText.Guild.Order[inColumnName])
	local newNumber = tonumber(inSelection)
	XF.Config.DataText.Guild.Order[inColumnName] = newNumber
	for columnName, orderNumber in pairs (XF.Config.DataText.Guild.Order) do
		orderNumber = tonumber(orderNumber)
		if(columnName ~= inColumnName) then
			if(oldNumber < newNumber and orderNumber > oldNumber and orderNumber <= newNumber) then
				XF.Config.DataText.Guild.Order[columnName] = orderNumber - 1
			elseif(oldNumber > newNumber and orderNumber < oldNumber and orderNumber >= newNumber) then
				XF.Config.DataText.Guild.Order[columnName] = orderNumber + 1
			end
		end
	end
end
--#endregion

XF.Options.args.DataText = {
	name = XF.Lib.Locale['DATATEXT'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		General = {
			order = 1,
			type = 'group',
			name = XF.Lib.Locale['GENERAL'],
			args = {
				Header = {
					order = 1,
					type = 'group',
					name = XF.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XF.Lib.Locale['DTGENERAL_DESCRIPTION'],
						},
					}
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Font = {
					name = XF.Lib.Locale['DT_CONFIG_FONT'],
					type = 'select',
					order = 3,
					dialogControl = 'LSM30_Font',
					values = XF.Lib.LSM:HashTable('font'),
					get = function(info) return XF.Config.DataText[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText[ info[#info] ] = value; 
						XFO.DTGuild:PostInitialize()
						XFO.DTLinks:PostInitialize()
						XFO.DTMetrics:PostInitialize()
					end
				},
				FontSize = {
					order = 4,
					name = XF.Lib.Locale['DT_CONFIG_FONT_SIZE'],
					desc = XF.Lib.Locale['DT_CONFIG_FONT_SIZE_TOOLTIP'],
					type = 'range',
					min = 6, max = 22, step = 1,
					get = function(info) return XF.Config.DataText[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText[ info[#info] ] = value; 
						XFO.DTGuild:PostInitialize()
						XFO.DTLinks:PostInitialize()
						XFO.DTMetrics:PostInitialize()
					end
				},
			},
		},
		Guild = {
			order = 1,
			type = 'group',
			name = XF.Lib.Locale['DTGUILD_NAME'],
			args = {
				Description = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = XF.Lib.Locale['DTGUILD_BROKER_HEADER']
				},
				Space = {
					order = 2,
					type = 'description',
					name = '',
				},
				NonXFaction = {
					order = 3,
					type = 'toggle',
					name = XF.Lib.Locale['NONXFACTION'],
					desc = XF.Lib.Locale['DT_CONFIG_NONXFACTION_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild[ info[#info] ] = value;
						XFO.DTGuild:RefreshBroker()
					end
				},
				Label = {
					order = 3,
					type = 'toggle',
					name = XF.Lib.Locale['LABEL'],
					desc = XF.Lib.Locale['DT_CONFIG_LABEL_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild[ info[#info] ] = value;
						XFO.DTGuild:RefreshBroker()
					end
				},
				Size = {
					order = 4,
					type = 'range',
					name = XF.Lib.Locale['DTGUILD_CONFIG_SIZE'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_SIZE_TOOLTIP'],
					min = 200, max = 1000, step = 5,
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line = {
					order = 8,
					type = 'header',
					name = ''
				},
				Description1 = {
					order = 9,
					type = 'description',
					fontSize = 'medium',
					name = XF.Lib.Locale['DTGUILD_CONFIG_HEADER']
				},
				Space2 = {
					order = 10,
					type = 'description',
					name = '',
				},
				Confederate = {
					order = 11,
					type = 'toggle',
					name = XF.Lib.Locale['CONFEDERATE'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				GuildName = {
					order = 12,
					type = 'toggle',
					name = XF.Lib.Locale['GUILD'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_GUILD_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				MOTD = {
					order = 13,
					type = 'toggle',
					name = XF.Lib.Locale['MOTD'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_MOTD_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line1 = {
					order = 14,
					type = 'header',
					name = ''
				},
				Description2 = {
					order = 15,
					type = 'description',
					fontSize = 'medium',
					name = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_HEADER']
				},
				Space3 = {
					order = 16,
					type = 'description',
					name = '',
				},
				Sort = {
					order = 17,
					type = 'select',
					name = XF.Lib.Locale['DTGUILD_CONFIG_SORT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_SORT_TOOLTIP'],
					values = {
						Achievement = XF.Lib.Locale['ACHIEVEMENT'],
						Guild = XF.Lib.Locale['GUILD'],
						ItemLevel = XF.Lib.Locale['ITEMLEVEL'],
						Level = XF.Lib.Locale['LEVEL'],       
						Location = XF.Lib.Locale['LOCATION'],
						Dungeon = XF.Lib.Locale['DUNGEON'],
						MythicKey = XF.Lib.Locale['MYTHICKEY'],
                        Name = XF.Lib.Locale['NAME'],
						Note = 	XF.Lib.Locale['NOTE'],
						Race = XF.Lib.Locale['RACE'],
						Raid = XF.Lib.Locale['RAID'],
						Rank = XF.Lib.Locale['RANK'],
						Realm = XF.Lib.Locale['REALM'],
						Team = XF.Lib.Locale['TEAM'],
						Version = XF.Lib.Locale['VERSION'],
                    },
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line2 = {
					order = 18,
					type = 'header',
					name = ''
				},
				Column = {
					order = 19,
					type = 'select',
					name = XF.Lib.Locale['DTGUILD_SELECT_COLUMN'],
					desc = XF.Lib.Locale['DTGUILD_SELECT_COLUMN_TOOLTIP'],
					values = {
						Achievement = XF.Lib.Locale['ACHIEVEMENT'],
						Faction = XF.Lib.Locale['FACTION'],
						Guild = XF.Lib.Locale['GUILD'],
						ItemLevel = XF.Lib.Locale['ITEMLEVEL'],
						Level = XF.Lib.Locale['LEVEL'],            
						Dungeon = XF.Lib.Locale['DUNGEON'],
						Hero = XF.Lib.Locale['HERO'],
						Location = XF.Lib.Locale['LOCATION'],
						MythicKey = XF.Lib.Locale['MYTHICKEY'],
                        Name = XF.Lib.Locale['NAME'],
						Note = 	XF.Lib.Locale['NOTE'],
						Profession = XF.Lib.Locale['PROFESSION'],
						PvP = XF.Lib.Locale['PVP'],
						Race = XF.Lib.Locale['RACE'],
						Raid = XF.Lib.Locale['RAID'],
						Rank = XF.Lib.Locale['RANK'],
						Realm = XF.Lib.Locale['REALM'],
						Spec = XF.Lib.Locale['SPEC'],
						Team = XF.Lib.Locale['TEAM'],
						Version = XF.Lib.Locale['VERSION'],						
					},
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value end
				},
				Space4 = {
					order = 20,
					type = 'description',
					name = '',
					--hidden = function()	return XF.Config.DataText.Guild.Enable.Achievement	end,
				},
				Achievement = {
					order = 21,
					type = 'toggle',
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'],
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Achievement' end,
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				AchievementOrder = {
					order = 22,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Achievement' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Achievement) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Achievement) then return tostring(XF.Config.DataText.Guild.Order.Achievement) end end,
					set = function(info, value) GuildSelectedMenuItem('Achievement', value) end
				},				
				AchievementAlignment = {
					order = 23,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Achievement' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Achievement) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Achievement end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Achievement = value; end
				},
				Faction = {
					order = 28,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Faction' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				FactionOrder = {
					order = 29,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Faction' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Faction) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Faction) then return tostring(XF.Config.DataText.Guild.Order.Faction) end end,
					set = function(info, value) GuildSelectedMenuItem('Faction', value) end
				},
				FactionAlignment = {
					order = 30,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Faction' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Faction) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Faction end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Faction = value; end
				},
				Guild = {
					order = 31,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Guild' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				GuildOrder = {
					order = 32,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Guild' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Guild) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Guild) then return tostring(XF.Config.DataText.Guild.Order.Guild) end end,
					set = function(info, value) GuildSelectedMenuItem('Guild', value) end
				},
				GuildAlignment = {
					order = 33,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Guild' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Guild) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Guild end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Guild = value; end
				},
				Hero = {
					order = 34,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Hero' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_HERO_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				HeroOrder = {
					order = 35,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Hero' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Hero) end,
					name = XF.Lib.Locale['HERO'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_HERO_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Hero) then return tostring(XF.Config.DataText.Guild.Order.Hero) end end,
					set = function(info, value) GuildSelectedMenuItem('Hero', value) end
				},
				HeroAlignment = {
					order = 36,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Hero' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Hero) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_HERO_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Hero end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Hero = value; end
				},
				ItemLevel = {
					order = 37,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				ItemLevelOrder = {
					order = 38,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.ItemLevel) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.ItemLevel) then return tostring(XF.Config.DataText.Guild.Order.ItemLevel) end end,
					set = function(info, value) GuildSelectedMenuItem('ItemLevel', value) end
				},
				ItemLevelAlignment = {
					order = 39,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.ItemLevel) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.ItemLevel end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.ItemLevel = value; end
				},				
				Level = {
					order = 40,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Level' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				LevelOrder = {
					order = 41,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Level' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Level) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Level) then return tostring(XF.Config.DataText.Guild.Order.Level) end end,
					set = function(info, value) GuildSelectedMenuItem('Level', value) end
				},
				LevelAlignment = {
					order = 42,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Level' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Level) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Level end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Level = value; end
				},				
				Dungeon = {
					order = 43,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Dungeon' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				DungeonOrder = {
					order = 44,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Dungeon' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Dungeon) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Dungeon) then return tostring(XF.Config.DataText.Guild.Order.Dungeon) end end,
					set = function(info, value) GuildSelectedMenuItem('Dungeon', value) end
				},
				DungeonAlignment = {
					order = 45,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Dungeon' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Dungeon) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Dungeon end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Dungeon = value; end
				},
				Name = {
					order = 46,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					disabled = true,
					name = ENABLE,
					disabled = true,
					desc = '',
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				NameOrder = {
					order = 47,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) return tostring(XF.Config.DataText.Guild.Order.Name) end,
					set = function(info, value) GuildSelectedMenuItem('Name', value) end
				},
				NameAlignment = {
					order = 48,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Name end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Name = value; end
				},
				Main = {
					order = 49,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					name = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ENABLE_MAIN'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Note = {
					order = 50,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Note' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				NoteOrder = {
					order = 51,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Note' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Note) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Note) then return tostring(XF.Config.DataText.Guild.Order.Note) end end,
					set = function(info, value) GuildSelectedMenuItem('Note', value) end
				},
				NoteAlignment = {
					order = 52,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Note' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Note) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Note end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Note = value; end
				},
				Profession = {
					order = 53,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Profession' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				ProfessionOrder = {
					order = 54,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Profession' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Profession) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Profession) then return tostring(XF.Config.DataText.Guild.Order.Profession) end end,
					set = function(info, value) GuildSelectedMenuItem('Profession', value) end
				},
				ProfessionAlignment = {
					order = 55,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Profession' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Profession) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Profession end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Profession = value; end
				},
				PvP = {
					order = 56,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'PvP' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				PvPOrder = {
					order = 57,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'PvP' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.PvP) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.PvP) then return tostring(XF.Config.DataText.Guild.Order.PvP) end end,
					set = function(info, value) GuildSelectedMenuItem('PvP', value) end
				},
				PvPAlignment = {
					order = 58,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'PvP' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.PvP) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.PvP end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.PvP = value; end
				},
				Race = {
					order = 59,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Race' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				RaceOrder = {
					order = 60,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Race' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Race) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Race) then return tostring(XF.Config.DataText.Guild.Order.Race) end end,
					set = function(info, value) GuildSelectedMenuItem('Race', value) end
				},
				RaceAlignment = {
					order = 61,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Race' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Race) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Race end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Race = value; end
				},
				Raid = {
					order = 62,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Raid' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				RaidOrder = {
					order = 63,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Raid' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Raid) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Raid) then return tostring(XF.Config.DataText.Guild.Order.Raid) end end,
					set = function(info, value) GuildSelectedMenuItem('Raid', value) end
				},
				RaidAlignment = {
					order = 64,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Raid' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Raid) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Raid end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Raid = value; end
				},
				Rank = {
					order = 65,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Rank' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				RankOrder = {
					order = 66,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Rank' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Rank) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Rank) then return tostring(XF.Config.DataText.Guild.Order.Rank) end end,
					set = function(info, value) GuildSelectedMenuItem('Rank', value) end
				},
				RankAlignment = {
					order = 67,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Rank' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Rank) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Rank end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Rank = value; end
				},
				Realm = {
					order = 68,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Realm' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				RealmOrder = {
					order = 69,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Realm' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Realm) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Realm) then return tostring(XF.Config.DataText.Guild.Order.Realm) end end,
					set = function(info, value) GuildSelectedMenuItem('Realm', value) end
				},
				RealmAlignment = {
					order = 70,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Realm' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Realm) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Realm end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Realm = value; end
				},
				Spec = {
					order = 71,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Spec' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				SpecOrder = {
					order = 72,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Spec' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Spec) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Spec) then return tostring(XF.Config.DataText.Guild.Order.Spec) end end,
					set = function(info, value) GuildSelectedMenuItem('Spec', value) end
				},
				SpecAlignment = {
					order = 73,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Spec' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Spec) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Spec end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Spec = value; end
				},
				Team = {
					order = 74,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Team' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				TeamOrder = {
					order = 75,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Team' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Team) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Team) then return tostring(XF.Config.DataText.Guild.Order.Team) end end,
					set = function(info, value) GuildSelectedMenuItem('Team', value) end
				},
				TeamAlignment = {
					order = 76,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Team' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Team) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Team end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Team = value; end
				},
				Version = {
					order = 77,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Version' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				VersionOrder = {
					order = 78,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Version' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Version) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Version) then return tostring(XF.Config.DataText.Guild.Order.Version) end end,
					set = function(info, value) GuildSelectedMenuItem('Version', value) end
				},
				VersionAlignment = {
					order = 79,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Version' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Version) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Version end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Version = value; end
				},
				Location = {
					order = 80,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Location' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LOCATION_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				LocationOrder = {
					order = 81,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Location' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Location) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LOCATION_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Location) then return tostring(XF.Config.DataText.Guild.Order.Location) end end,
					set = function(info, value) GuildSelectedMenuItem('Location', value) end
				},
				LocationAlignment = {
					order = 82,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Location' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Location) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LOCATION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.Location end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.Location = value; end
				},		
				MythicKey = {
					order = 83,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'MythicKey' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_MYTHICKEY_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				MythicKeyOrder = {
					order = 84,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'MythicKey' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.MythicKey) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_MYTHICKEY_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.MythicKey) then return tostring(XF.Config.DataText.Guild.Order.MythicKey) end end,
					set = function(info, value) GuildSelectedMenuItem('MythicKey', value) end
				},
				MythicKeyAlignment = {
					order = 85,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'MythicKey' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.MythicKey) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_MYTHICKEY_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment.MythicKey end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment.MythicKey = value; end
				},
            },
		},
		Link = {
			order = 2,
			type = 'group',
			name = XF.Lib.Locale['DTLINKS_NAME'],
			args = {
				Header = {
					order = 1,
					type = 'group',
					name = QUEST_DESCRIPTION,
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XF.Lib.Locale['DTLINKS_DESCRIPTION'],
						},
					}
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Broker = {
					order = 3,
					type = 'group',
					name = XF.Lib.Locale['DT_CONFIG_BROKER'],
					inline = true,
					args = {
						Faction = {
							order = 1,
							type = 'toggle',
							name = FACTION,
							desc = XF.Lib.Locale['DT_CONFIG_FACTION_TOOLTIP'],
							get = function(info) return XF.Config.DataText.Link[ info[#info] ] end,
							set = function(info, value) 
								XF.Config.DataText.Link[ info[#info] ] = value;
								XFO.DTLinks:RefreshBroker()
							end
						},
						Label = {
							order = 2,
							type = 'toggle',
							name = XF.Lib.Locale['LABEL'],
							desc = XF.Lib.Locale['DT_CONFIG_LABEL_TOOLTIP'],
							get = function(info) return XF.Config.DataText.Link[ info[#info] ] end,
							set = function(info, value) 
								XF.Config.DataText.Link[ info[#info] ] = value;
								XFO.DTLinks:RefreshBroker()
							end
						},
					},
				},
			},
		},
		Metric = {
			order = 3,
			type = 'group',
			name = XF.Lib.Locale['DTMETRICS_NAME'],
			args = {
				Description = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = XF.Lib.Locale['DT_CONFIG_BROKER']
				},
				Space = {
					order = 2,
					type = 'description',
					name = '',
				},
				Total = {
					order = 3,
					type = 'toggle',
					name = XF.Lib.Locale['DTMETRICS_CONFIG_TOTAL'],
					desc = XF.Lib.Locale['DTMETRICS_CONFIG_TOTAL_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Metric[ info[#info] ] = value; 
						XFO.DTMetrics:RefreshBroker()
					end
				},
				Average = {
					order = 4,
					type = 'toggle',
					name = XF.Lib.Locale['DTMETRICS_CONFIG_AVERAGE'],
					desc = XF.Lib.Locale['DTMETRICS_CONFIG_AVERAGE_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Metric[ info[#info] ] = value; 
						XFO.DTMetrics:RefreshBroker()
					end
				},
				Error = {
					order = 5,
					type = 'toggle',
					name = XF.Lib.Locale['DTMETRICS_CONFIG_ERROR'],
					desc = XF.Lib.Locale['DTMETRICS_CONFIG_ERROR_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Metric[ info[#info] ] = value; 
						XFO.DTMetrics:RefreshBroker()
					end
				},
				Warning = {
					order = 6,
					type = 'toggle',
					name = XF.Lib.Locale['DTMETRICS_CONFIG_WARNING'],
					desc = XF.Lib.Locale['DTMETRICS_CONFIG_WARNING_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Metric[ info[#info] ] = value; 
						XFO.DTMetrics:RefreshBroker()
					end
				},
				Line3 = {
					order = 7,
					type = 'header',
					name = ''
				},
				Rate = {
					order = 8,
					type = 'range',
					name = XF.Lib.Locale['DTMETRICS_RATE'],
					desc = XF.Lib.Locale['DTMETRICS_RATE_TOOLTIP'],
					min = 1, max = 60 * 60 * 24, step = 1,
					get = function(info) return XF.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Metric[ info[#info] ] = value; 
						XFO.DTMetrics:RefreshBroker()
					end
				},
			},
		},
	},	
}