local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function OrderMenu()
	if(XFG.Cache.DTGuildTotalEnabled == nil) then XFG.Cache.DTGuildTotalEnabled = 0 end
	if(XFG.Cache.DTGuildTotalEnabled == 0) then
		for label, value in pairs (XFG.Config.DataText.Guild.Enable) do
			if(value) then
				orderLabel = label .. 'Order'
				if(XFG.Config.DataText.Guild.Order[orderLabel] ~= 0) then
					XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled + 1
				end
			end
		end
	end

	local menu = {}
	for i = 1, XFG.Cache.DTGuildTotalEnabled do
		menu[tostring(i)] = i
	end

	return menu
end

local function RemovedMenuItem(inColumnName)
	local index = XFG.Config.DataText.Guild.Order[inColumnName .. 'Order']
	XFG.Config.DataText.Guild.Order[inColumnName .. 'Order'] = 0
	XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled - 1
	for columnName, orderNumber in pairs (XFG.Config.DataText.Guild.Order) do
		if(orderNumber > index) then
			XFG.Config.DataText.Guild.Order[columnName] = orderNumber - 1
		end
	end
end

local function AddedMenuItem(inColumnName)
	local orderLabel = inColumnName .. 'Order'
	XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled + 1
	XFG.Config.DataText.Guild.Order[orderLabel] = XFG.Cache.DTGuildTotalEnabled
end

local function SelectedMenuItem(inColumnName, inSelection)
	local oldNumber = XFG.Config.DataText.Guild.Order[inColumnName]
	local newNumber = tonumber(inSelection)
	XFG.Config.DataText.Guild.Order[inColumnName] = newNumber
	for columnName, orderNumber in pairs (XFG.Config.DataText.Guild.Order) do
		if(columnName ~= inColumnName) then
			if(oldNumber < newNumber and orderNumber > oldNumber and orderNumber <= newNumber) then
				XFG.Config.DataText.Guild.Order[columnName] = orderNumber - 1
			elseif(oldNumber > newNumber and orderNumber < oldNumber and orderNumber >= newNumber) then
				XFG.Config.DataText.Guild.Order[columnName] = orderNumber + 1
			end
		end
	end
end

XFG.Options.args.DataText = {
	name = XFG.Lib.Locale['DATATEXT'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		General = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['GENERAL'],
			args = {
				Header = {
					order = 1,
					type = 'group',
					name = XFG.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XFG.Lib.Locale['DTGENERAL_DESCRIPTION'],
						},
					}
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Font = {
					name = XFG.Lib.Locale['DT_CONFIG_FONT'],
					type = 'select',
					order = 3,
					dialogControl = 'LSM30_Font',
					values = XFG.Lib.LSM:HashTable('font'),
					get = function(info) return XFG.Config.DataText[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText[ info[#info] ] = value; 
						XFG.DataText.Guild:PostInitialize()
						XFG.DataText.Links:PostInitialize()
						XFG.DataText.Metrics:PostInitialize()
					end
				},
				FontSize = {
					order = 4,
					name = XFG.Lib.Locale['DT_CONFIG_FONT_SIZE'],
					desc = XFG.Lib.Locale['DT_CONFIG_FONT_SIZE_TOOLTIP'],
					type = 'range',
					min = 6, max = 22, step = 1,
					get = function(info) return XFG.Config.DataText[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText[ info[#info] ] = value; 
						XFG.DataText.Guild:PostInitialize()
						XFG.DataText.Links:PostInitialize()
						XFG.DataText.Metrics:PostInitialize()
					end
				},
			},
		},
		Guild = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['DTGUILD_NAME'],
			args = {
				Description = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DTGUILD_BROKER_HEADER']
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
				Size = {
					order = 4,
					type = 'range',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_SIZE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_SIZE_TOOLTIP'],
					min = 200, max = 1000, step = 5,
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
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
					name = XFG.Lib.Locale['DTGUILD_CONFIG_HEADER']
				},
				Space2 = {
					order = 10,
					type = 'description',
					name = '',
				},
				Confederate = {
					order = 11,
					type = 'toggle',
					name = XFG.Lib.Locale['CONFEDERATE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				GuildName = {
					order = 12,
					type = 'toggle',
					name = XFG.Lib.Locale['GUILD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				MOTD = {
					order = 13,
					type = 'toggle',
					name = XFG.Lib.Locale['MOTD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_MOTD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
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
					name = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_HEADER']
				},
				Space3 = {
					order = 16,
					type = 'description',
					name = '',
				},
				Sort = {
					order = 17,
					type = 'select',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_SORT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_SORT_TOOLTIP'],
					values = {
						Achievement = XFG.Lib.Locale['ACHIEVEMENT'],
						Guild = XFG.Lib.Locale['GUILD'],
						ItemLevel = XFG.Lib.Locale['ITEMLEVEL'],
						Level = XFG.Lib.Locale['LEVEL'],            
						Dungeon = XFG.Lib.Locale['DUNGEON'],
                        Name = XFG.Lib.Locale['NAME'],
						Note = 	XFG.Lib.Locale['NOTE'],
						Race = XFG.Lib.Locale['RACE'],
						Raid = XFG.Lib.Locale['RAID'],
						Rank = XFG.Lib.Locale['RANK'],
						Realm = XFG.Lib.Locale['REALM'],
						Team = XFG.Lib.Locale['TEAM'],
						Version = XFG.Lib.Locale['VERSION'],
						Zone = XFG.Lib.Locale['ZONE'],
                    },
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Line2 = {
					order = 18,
					type = 'header',
					name = ''
				},
				Column = {
					order = 19,
					type = 'select',
					name = XFG.Lib.Locale['DTGUILD_SELECT_COLUMN'],
					desc = XFG.Lib.Locale['DTGUILD_SELECT_COLUMN_TOOLTIP'],
					values = {
						Achievement = XFG.Lib.Locale['ACHIEVEMENT'],
						Faction = XFG.Lib.Locale['FACTION'],
						Guild = XFG.Lib.Locale['GUILD'],
						ItemLevel = XFG.Lib.Locale['ITEMLEVEL'],
						Level = XFG.Lib.Locale['LEVEL'],            
						Dungeon = XFG.Lib.Locale['DUNGEON'],
                        Name = XFG.Lib.Locale['NAME'],
						Note = 	XFG.Lib.Locale['NOTE'],
						Profession = XFG.Lib.Locale['PROFESSION'],
						PvP = XFG.Lib.Locale['PVP'],
						Race = XFG.Lib.Locale['RACE'],
						Raid = XFG.Lib.Locale['RAID'],
						Rank = XFG.Lib.Locale['RANK'],
						Realm = XFG.Lib.Locale['REALM'],
						Spec = XFG.Lib.Locale['SPEC'],
						Team = XFG.Lib.Locale['TEAM'],
						Version = XFG.Lib.Locale['VERSION'],
						Zone = XFG.Lib.Locale['ZONE'],
					},
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value end
				},
				Space4 = {
					order = 20,
					type = 'description',
					name = '',
					--hidden = function()	return XFG.Config.DataText.Guild.Enable.Achievement	end,
				},
				Achievement = {
					order = 21,
					type = 'toggle',
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'],
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Achievement' end,
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				AchievementOrder = {
					order = 22,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Achievement' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Achievement) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Achievement) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},				
				AchievementAlignment = {
					order = 23,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Achievement' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Achievement) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Faction = {
					order = 28,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Faction' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				FactionOrder = {
					order = 29,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Faction' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Faction) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Faction) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				FactionAlignment = {
					order = 30,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Faction' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Faction) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Guild = {
					order = 31,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Guild' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				GuildOrder = {
					order = 32,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Guild' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Guild) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Guild) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				GuildAlignment = {
					order = 33,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Guild' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Guild) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				ItemLevel = {
					order = 34,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ItemLevelOrder = {
					order = 35,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.ItemLevel) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.ItemLevel) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				ItemLevelAlignment = {
					order = 36,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.ItemLevel) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Level = {
					order = 37,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Level' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				LevelOrder = {
					order = 38,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Level' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Level) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Level) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				LevelAlignment = {
					order = 39,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Level' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Level) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},				
				Dungeon = {
					order = 40,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Dungeon' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				DungeonOrder = {
					order = 41,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Dungeon' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Dungeon) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Dungeon) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				DungeonAlignment = {
					order = 42,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Dungeon' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Dungeon) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Name = {
					order = 43,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					disabled = true,
					name = ENABLE,
					disabled = true,
					desc = '',
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				NameOrder = {
					order = 44,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				NameAlignment = {
					order = 45,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Main = {
					order = 46,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					name = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ENABLE_MAIN'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Note = {
					order = 47,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Note' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				NoteOrder = {
					order = 48,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Note' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Note) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Note) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				NoteAlignment = {
					order = 49,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Note' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Note) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Profession = {
					order = 50,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Profession' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ProfessionOrder = {
					order = 51,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Profession' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Profession) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Profession) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				ProfessionAlignment = {
					order = 52,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Profession' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Profession) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				PvP = {
					order = 53,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'PvP' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				PvPOrder = {
					order = 54,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'PvP' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.PvP) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.PvP) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				PvPAlignment = {
					order = 55,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'PvP' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.PvP) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Race = {
					order = 56,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Race' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RaceOrder = {
					order = 57,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Race' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Race) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Race) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RaceAlignment = {
					order = 58,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Race' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Race) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Raid = {
					order = 59,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Raid' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RaidOrder = {
					order = 60,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Raid' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Raid) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Raid) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RaidAlignment = {
					order = 61,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Raid' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Raid) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Rank = {
					order = 62,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Rank' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RankOrder = {
					order = 63,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Rank' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Rank) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Rank) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RankAlignment = {
					order = 64,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Rank' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Rank) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Realm = {
					order = 65,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Realm' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RealmOrder = {
					order = 66,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Realm' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Realm) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Realm) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RealmAlignment = {
					order = 67,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Realm' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Realm) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Spec = {
					order = 68,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Spec' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				SpecOrder = {
					order = 69,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Spec' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Spec) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Spec) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				SpecAlignment = {
					order = 70,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Spec' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Spec) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Team = {
					order = 71,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Team' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				TeamOrder = {
					order = 72,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Team' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Team) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Team) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				TeamAlignment = {
					order = 73,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Team' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Team) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Version = {
					order = 74,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Version' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				VersionOrder = {
					order = 75,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Version' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Version) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Version) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				VersionAlignment = {
					order = 76,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Version' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Version) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Zone = {
					order = 77,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Zone' end,
					name = ENABLE,
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ZoneOrder = {
					order = 78,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Zone' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Zone) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Zone) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				ZoneAlignment = {
					order = 79,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Zone' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Zone) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},				
            },
		},
		Link = {
			order = 2,
			type = 'group',
			name = XFG.Lib.Locale['DTLINKS_NAME'],
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
							name = XFG.Lib.Locale['DTLINKS_DESCRIPTION'],
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
					name = XFG.Lib.Locale['DT_CONFIG_BROKER'],
					inline = true,
					args = {
						Faction = {
							order = 1,
							type = 'toggle',
							name = FACTION,
							desc = XFG.Lib.Locale['DT_CONFIG_FACTION_TOOLTIP'],
							get = function(info) return XFG.Config.DataText.Link[ info[#info] ] end,
							set = function(info, value) 
								XFG.Config.DataText.Link[ info[#info] ] = value;
								XFG.DataText.Links:RefreshBroker()
							end
						},
						Label = {
							order = 2,
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
		},
		Metric = {
			order = 3,
			type = 'group',
			name = XFG.Lib.Locale['DTMETRICS_NAME'],
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
				Total = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['DTMETRICS_CONFIG_TOTAL'],
					desc = XFG.Lib.Locale['DTMETRICS_CONFIG_TOTAL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Metric[ info[#info] ] = value; 
						XFG.DataText.Metrics:RefreshBroker()
					end
				},
				Average = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['DTMETRICS_CONFIG_AVERAGE'],
					desc = XFG.Lib.Locale['DTMETRICS_CONFIG_AVERAGE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Metric[ info[#info] ] = value; 
						XFG.DataText.Metrics:RefreshBroker()
					end
				},
				Error = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['DTMETRICS_CONFIG_ERROR'],
					desc = XFG.Lib.Locale['DTMETRICS_CONFIG_ERROR_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Metric[ info[#info] ] = value; 
						XFG.DataText.Metrics:RefreshBroker()
					end
				},
				Warning = {
					order = 6,
					type = 'toggle',
					name = XFG.Lib.Locale['DTMETRICS_CONFIG_WARNING'],
					desc = XFG.Lib.Locale['DTMETRICS_CONFIG_WARNING_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Metric[ info[#info] ] = value; 
						XFG.DataText.Metrics:RefreshBroker()
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
					name = XFG.Lib.Locale['DTMETRICS_RATE'],
					desc = XFG.Lib.Locale['DTMETRICS_RATE_TOOLTIP'],
					min = 1, max = 60 * 60 * 24, step = 1,
					get = function(info) return XFG.Config.DataText.Metric[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Metric[ info[#info] ] = value; 
						XFG.DataText.Metrics:RefreshBroker()
					end
				},
			},
		},
	},	
}