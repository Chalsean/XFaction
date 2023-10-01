local XF, G = unpack(select(2, ...))
local LogCategory = 'Config'

--#region DTGuild
local function GuildOrderMenu()
	if(XF.Cache.DTGuildTotalEnabled == nil) then XF.Cache.DTGuildTotalEnabled = 0 end
	if(XF.Cache.DTGuildTotalEnabled == 0) then
		for label, value in pairs (XF.Config.DataText.Guild.Enable) do
			if(value) then
				orderLabel = label .. 'Order'
				if(XF.Config.DataText.Guild.Order[orderLabel] ~= 0) then
					XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled + 1
				end
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
	local index = XF.Config.DataText.Guild.Order[inColumnName .. 'Order']
	XF.Config.DataText.Guild.Order[inColumnName .. 'Order'] = 0
	XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled - 1
	for columnName, orderNumber in pairs (XF.Config.DataText.Guild.Order) do
		if(orderNumber > index) then
			XF.Config.DataText.Guild.Order[columnName] = orderNumber - 1
		end
	end
end

local function GuildAddedMenuItem(inColumnName)
	local orderLabel = inColumnName .. 'Order'
	XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled + 1
	XF.Config.DataText.Guild.Order[orderLabel] = XF.Cache.DTGuildTotalEnabled
end

local function GuildSelectedMenuItem(inColumnName, inSelection)
	local oldNumber = XF.Config.DataText.Guild.Order[inColumnName]
	local newNumber = tonumber(inSelection)
	XF.Config.DataText.Guild.Order[inColumnName] = newNumber
	for columnName, orderNumber in pairs (XF.Config.DataText.Guild.Order) do
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

--#region DTOrder
local function OrdersOrderMenu()
	if(XF.Cache.DTOrdersTotalEnabled == nil) then XF.Cache.DTOrdersTotalEnabled = 0 end
	if(XF.Cache.DTOrdersTotalEnabled == 0) then
		for label, value in pairs (XF.Config.DataText.Orders.Enable) do
			if(value) then
				orderLabel = label .. 'Order'
				if(XF.Config.DataText.Orders.Order[orderLabel] ~= 0) then
					XF.Cache.DTOrdersTotalEnabled = XF.Cache.DTOrdersTotalEnabled + 1
				end
			end
		end
	end

	local menu = {}
	for i = 1, XF.Cache.DTOrdersTotalEnabled do
		menu[tostring(i)] = i
	end

	return menu
end

local function OrdersRemovedMenuItem(inColumnName)
	local index = XF.Config.DataText.Orders.Order[inColumnName .. 'Order']
	XF.Config.DataText.Orders.Order[inColumnName .. 'Order'] = 0
	XF.Cache.DTOrdersTotalEnabled = XF.Cache.DTOrdersTotalEnabled - 1
	for columnName, orderNumber in pairs (XF.Config.DataText.Orders.Order) do
		if(orderNumber > index) then
			XF.Config.DataText.Orders.Order[columnName] = orderNumber - 1
		end
	end
end

local function OrdersAddedMenuItem(inColumnName)
	local orderLabel = inColumnName .. 'Order'
	XF.Cache.DTOrdersTotalEnabled = XF.Cache.DTOrdersTotalEnabled + 1
	XF.Config.DataText.Guild.Order[orderLabel] = XF.Cache.DTOrdersTotalEnabled
end

local function OrdersSelectedMenuItem(inColumnName, inSelection)
	local oldNumber = XF.Config.DataText.Orders.Order[inColumnName]
	local newNumber = tonumber(inSelection)
	XF.Config.DataText.Orders.Order[inColumnName] = newNumber
	for columnName, orderNumber in pairs (XF.Config.DataText.Orders.Order) do
		if(columnName ~= inColumnName) then
			if(oldNumber < newNumber and orderNumber > oldNumber and orderNumber <= newNumber) then
				XF.Config.DataText.Orders.Order[columnName] = orderNumber - 1
			elseif(oldNumber > newNumber and orderNumber < oldNumber and orderNumber >= newNumber) then
				XF.Config.DataText.Orders.Order[columnName] = orderNumber + 1
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
						XF.DataText.Guild:PostInitialize()
						XF.DataText.Links:PostInitialize()
						XF.DataText.Metrics:PostInitialize()
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
						XF.DataText.Guild:PostInitialize()
						XF.DataText.Links:PostInitialize()
						XF.DataText.Metrics:PostInitialize()
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
				Label = {
					order = 3,
					type = 'toggle',
					name = XF.Lib.Locale['LABEL'],
					desc = XF.Lib.Locale['DT_CONFIG_LABEL_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild[ info[#info] ] = value;
						XF.DataText.Guild:RefreshBroker()
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
						Dungeon = XF.Lib.Locale['DUNGEON'],
                        Name = XF.Lib.Locale['NAME'],
						Note = 	XF.Lib.Locale['NOTE'],
						Race = XF.Lib.Locale['RACE'],
						Raid = XF.Lib.Locale['RAID'],
						Rank = XF.Lib.Locale['RANK'],
						Realm = XF.Lib.Locale['REALM'],
						Team = XF.Lib.Locale['TEAM'],
						Version = XF.Lib.Locale['VERSION'],
						Zone = XF.Lib.Locale['ZONE'],
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
						Zone = XF.Lib.Locale['ZONE'],
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
					get = function(info) if(XF.Config.DataText.Guild.Enable.Achievement) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
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
					get = function(info) if(XF.Config.DataText.Guild.Enable.Faction) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
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
					get = function(info) if(XF.Config.DataText.Guild.Enable.Guild) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				ItemLevel = {
					order = 34,
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
					order = 35,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.ItemLevel) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.ItemLevel) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				ItemLevelAlignment = {
					order = 36,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Level = {
					order = 37,
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
					order = 38,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Level' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Level) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Level) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				LevelAlignment = {
					order = 39,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},				
				Dungeon = {
					order = 40,
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
					order = 41,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Dungeon' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Dungeon) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Dungeon) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				DungeonAlignment = {
					order = 42,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Name = {
					order = 43,
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
					order = 44,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				NameAlignment = {
					order = 45,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Main = {
					order = 46,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Name' end,
					name = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ENABLE_MAIN'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Note = {
					order = 47,
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
					order = 48,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Note' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Note) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Note) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				NoteAlignment = {
					order = 49,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Profession = {
					order = 50,
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
					order = 51,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Profession' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Profession) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Profession) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				ProfessionAlignment = {
					order = 52,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				PvP = {
					order = 53,
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
					order = 54,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'PvP' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.PvP) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.PvP) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				PvPAlignment = {
					order = 55,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Race = {
					order = 56,
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
					order = 57,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Race' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Race) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Race) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				RaceAlignment = {
					order = 58,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Raid = {
					order = 59,
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
					order = 60,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Raid' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Raid) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Raid) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				RaidAlignment = {
					order = 61,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Rank = {
					order = 62,
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
					order = 63,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Rank' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Rank) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Rank) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				RankAlignment = {
					order = 64,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Realm = {
					order = 65,
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
					order = 66,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Realm' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Realm) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Realm) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				RealmAlignment = {
					order = 67,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Spec = {
					order = 68,
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
					order = 69,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Spec' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Spec) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Spec) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				SpecAlignment = {
					order = 70,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Team = {
					order = 71,
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
					order = 72,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Team' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Team) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Team) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				TeamAlignment = {
					order = 73,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Version = {
					order = 74,
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
					order = 75,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Version' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Version) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Version) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				VersionAlignment = {
					order = 76,
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
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Zone = {
					order = 77,
					type = 'toggle',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Zone' end,
					name = ENABLE,
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
					get = function(info) return XF.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XF.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then GuildAddedMenuItem(info[#info]) else GuildRemovedMenuItem(info[#info]) end
					end
				},
				ZoneOrder = {
					order = 78,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Zone' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Zone) end,
					name = XF.Lib.Locale['ORDER'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_ORDER_TOOLTIP'],
					values = function () return GuildOrderMenu() end,
					get = function(info) if(XF.Config.DataText.Guild.Enable.Zone) then return tostring(XF.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) GuildSelectedMenuItem(info[#info], value) end
				},
				ZoneAlignment = {
					order = 79,
					type = 'select',
					hidden = function () return XF.Config.DataText.Guild.Column ~= 'Zone' end,
					disabled = function () return (not XF.Config.DataText.Guild.Enable.Zone) end,
					name = XF.Lib.Locale['ALIGNMENT'],
					desc = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XF.Lib.Locale['CENTER'],
						Left = XF.Lib.Locale['LEFT'],
						Right = XF.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XF.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XF.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
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
								XF.DataText.Links:RefreshBroker()
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
								XF.DataText.Links:RefreshBroker()
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
						XF.DataText.Metrics:RefreshBroker()
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
						XF.DataText.Metrics:RefreshBroker()
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
						XF.DataText.Metrics:RefreshBroker()
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
						XF.DataText.Metrics:RefreshBroker()
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
						XF.DataText.Metrics:RefreshBroker()
					end
				},
			},
		},
		-- Order = {
		-- 	order = 4,
		-- 	type = 'group',
		-- 	name = XF.Lib.Locale['DTORDERS_NAME'],
		-- 	args = {
		-- 		Description = {
		-- 			order = 1,
		-- 			type = 'description',
		-- 			fontSize = 'medium',
		-- 			name = XF.Lib.Locale['DTORDERS_BROKER_HEADER']
		-- 		},
		-- 		Space = {
		-- 			order = 2,
		-- 			type = 'description',
		-- 			name = '',
		-- 		},
		-- 		Label = {
		-- 			order = 3,
		-- 			type = 'toggle',
		-- 			name = XF.Lib.Locale['LABEL'],
		-- 			desc = XF.Lib.Locale['DT_CONFIG_LABEL_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders[ info[#info] ] end,
		-- 			set = function(info, value) 
		-- 				XF.Config.DataText.Orders[ info[#info] ] = value;
		-- 				XF.DataText.Orders:RefreshBroker()
		-- 			end
		-- 		},
		-- 		Size = {
		-- 			order = 4,
		-- 			type = 'range',
		-- 			name = XF.Lib.Locale['DTORDERS_CONFIG_SIZE'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_SIZE_TOOLTIP'],
		-- 			min = 200, max = 1000, step = 5,
		-- 			get = function(info) return XF.Config.DataText.Orders[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders[ info[#info] ] = value; end
		-- 		},
		-- 		Line = {
		-- 			order = 8,
		-- 			type = 'header',
		-- 			name = ''
		-- 		},
		-- 		Description1 = {
		-- 			order = 9,
		-- 			type = 'description',
		-- 			fontSize = 'medium',
		-- 			name = XF.Lib.Locale['DTORDERS_CONFIG_HEADER']
		-- 		},
		-- 		Space2 = {
		-- 			order = 10,
		-- 			type = 'description',
		-- 			name = '',
		-- 		},
		-- 		Confederate = {
		-- 			order = 11,
		-- 			type = 'toggle',
		-- 			name = XF.Lib.Locale['CONFEDERATE'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_CONFEDERATE_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders[ info[#info] ] = value; end
		-- 		},
		-- 		GuildName = {
		-- 			order = 12,
		-- 			type = 'toggle',
		-- 			name = XF.Lib.Locale['GUILD'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_GUILD_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders[ info[#info] ] = value; end
		-- 		},
		-- 		Line1 = {
		-- 			order = 14,
		-- 			type = 'header',
		-- 			name = ''
		-- 		},
		-- 		Description2 = {
		-- 			order = 15,
		-- 			type = 'description',
		-- 			fontSize = 'medium',
		-- 			name = XF.Lib.Locale['DTGUILD_CONFIG_COLUMN_HEADER']
		-- 		},
		-- 		Space3 = {
		-- 			order = 16,
		-- 			type = 'description',
		-- 			name = '',
		-- 		},
		-- 		Sort = {
		-- 			order = 17,
		-- 			type = 'select',
		-- 			name = XF.Lib.Locale['DTORDERS_CONFIG_SORT'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_SORT_TOOLTIP'],
		-- 			values = {
		-- 				CUstomer = XF.Lib.Locale['CUSTOMER'],
		-- 				Guild = XF.Lib.Locale['GUILD'],
		-- 				Item = XF.Lib.Locale['ITEM'],
        --             },
		-- 			get = function(info) return XF.Config.DataText.Orders[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders[ info[#info] ] = value; end
		-- 		},
		-- 		Line2 = {
		-- 			order = 18,
		-- 			type = 'header',
		-- 			name = ''
		-- 		},
		-- 		Column = {
		-- 			order = 19,
		-- 			type = 'select',
		-- 			name = XF.Lib.Locale['DTORDERS_SELECT_COLUMN'],
		-- 			desc = XF.Lib.Locale['DTORDERS_SELECT_COLUMN_TOOLTIP'],
		-- 			values = {
		-- 				Customer = XF.Lib.Locale['CUSTOMER'],
		-- 				Guild = XF.Lib.Locale['GUILD'],
		-- 				Item = XF.Lib.Locale['ITEM'],
		-- 				Profession = XF.Lib.Locale['PROFESSION'],
		-- 			},
		-- 			get = function(info) return XF.Config.DataText.Orders[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders[ info[#info] ] = value end
		-- 		},
		-- 		Space4 = {
		-- 			order = 20,
		-- 			type = 'description',
		-- 			name = '',
		-- 			--hidden = function()	return XF.Config.DataText.Orders.Enable.Achievement	end,
		-- 		},
		-- 		Customer = {
		-- 			order = 21,
		-- 			type = 'toggle',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Customer' end,
		-- 			name = ENABLE,
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_CUSTOMER_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders.Enable[ info[#info] ] end,
		-- 			set = function(info, value) 
		-- 				XF.Config.DataText.Orders.Enable[ info[#info] ] = value
		-- 				if(value) then OrdersAddedMenuItem(info[#info]) else OrdersRemovedMenuItem(info[#info]) end
		-- 			end
		-- 		},
		-- 		CustomerOrder = {
		-- 			order = 22,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Customer' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Customer) end,
		-- 			name = XF.Lib.Locale['ORDER'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_CUSTOMER_ORDER_TOOLTIP'],
		-- 			values = function () return OrdersOrderMenu() end,
		-- 			get = function(info) if(XF.Config.DataText.Orders.Enable.Customer) then return tostring(XF.Config.DataText.Orders.Order[ info[#info] ]) end end,
		-- 			set = function(info, value) OrdersSelectedMenuItem(info[#info], value) end
		-- 		},
		-- 		CustomerAlignment = {
		-- 			order = 23,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Customer' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Customer) end,
		-- 			name = XF.Lib.Locale['ALIGNMENT'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_CUSTOMER_ALIGNMENT_TOOLTIP'],
		-- 			values = {
		-- 				Center = XF.Lib.Locale['CENTER'],
		-- 				Left = XF.Lib.Locale['LEFT'],
		-- 				Right = XF.Lib.Locale['RIGHT'],
        --             },
		-- 			get = function(info) return XF.Config.DataText.Orders.Alignment[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders.Alignment[ info[#info] ] = value; end
		-- 		},
		-- 		Guild = {
		-- 			order = 31,
		-- 			type = 'toggle',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Guild' end,
		-- 			name = ENABLE,
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_GUILD_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders.Enable[ info[#info] ] end,
		-- 			set = function(info, value) 
		-- 				XF.Config.DataText.Orders.Enable[ info[#info] ] = value
		-- 				if(value) then OrdersAddedMenuItem(info[#info]) else OrdersRemovedMenuItem(info[#info]) end
		-- 			end
		-- 		},
		-- 		GuildOrder = {
		-- 			order = 32,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Guild' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Guild) end,
		-- 			name = XF.Lib.Locale['ORDER'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_GUILD_ORDER_TOOLTIP'],
		-- 			values = function () return OrdersOrderMenu() end,
		-- 			get = function(info) if(XF.Config.DataText.Orders.Enable.Guild) then return tostring(XF.Config.DataText.Orders.Order[ info[#info] ]) end end,
		-- 			set = function(info, value) OrdersSelectedMenuItem(info[#info], value) end
		-- 		},
		-- 		GuildAlignment = {
		-- 			order = 33,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Guild' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Guild) end,
		-- 			name = XF.Lib.Locale['ALIGNMENT'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_GUILD_ALIGNMENT_TOOLTIP'],
		-- 			values = {
		-- 				Center = XF.Lib.Locale['CENTER'],
		-- 				Left = XF.Lib.Locale['LEFT'],
		-- 				Right = XF.Lib.Locale['RIGHT'],
        --             },
		-- 			get = function(info) return XF.Config.DataText.Orders.Alignment[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders.Alignment[ info[#info] ] = value; end
		-- 		},
		-- 		Item = {
		-- 			order = 41,
		-- 			type = 'toggle',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Item' end,
		-- 			name = ENABLE,
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_GUILD_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders.Enable[ info[#info] ] end,
		-- 			set = function(info, value) 
		-- 				XF.Config.DataText.Orders.Enable[ info[#info] ] = value
		-- 				if(value) then OrdersAddedMenuItem(info[#info]) else OrdersRemovedMenuItem(info[#info]) end
		-- 			end
		-- 		},
		-- 		ItemOrder = {
		-- 			order = 42,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Item' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Item) end,
		-- 			name = XF.Lib.Locale['ORDER'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_GUILD_ORDER_TOOLTIP'],
		-- 			values = function () return OrdersOrderMenu() end,
		-- 			get = function(info) if(XF.Config.DataText.Orders.Enable.Guild) then return tostring(XF.Config.DataText.Orders.Order[ info[#info] ]) end end,
		-- 			set = function(info, value) OrdersSelectedMenuItem(info[#info], value) end
		-- 		},
		-- 		ItemAlignment = {
		-- 			order = 43,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Item' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Item) end,
		-- 			name = XF.Lib.Locale['ALIGNMENT'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_GUILD_ALIGNMENT_TOOLTIP'],
		-- 			values = {
		-- 				Center = XF.Lib.Locale['CENTER'],
		-- 				Left = XF.Lib.Locale['LEFT'],
		-- 				Right = XF.Lib.Locale['RIGHT'],
        --             },
		-- 			get = function(info) return XF.Config.DataText.Orders.Alignment[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders.Alignment[ info[#info] ] = value; end
		-- 		},
		-- 		Profession = {
		-- 			order = 50,
		-- 			type = 'toggle',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Profession' end,
		-- 			name = ENABLE,
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
		-- 			get = function(info) return XF.Config.DataText.Orders.Enable[ info[#info] ] end,
		-- 			set = function(info, value) 
		-- 				XF.Config.DataText.Orders.Enable[ info[#info] ] = value
		-- 				if(value) then OrdersAddedMenuItem(info[#info]) else OrdersRemovedMenuItem(info[#info]) end
		-- 			end
		-- 		},
		-- 		ProfessionOrder = {
		-- 			order = 51,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Profession' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Profession) end,
		-- 			name = XF.Lib.Locale['ORDER'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_PROFESSION_ORDER_TOOLTIP'],
		-- 			values = function () return OrdersOrderMenu() end,
		-- 			get = function(info) if(XF.Config.DataText.Orders.Enable.Profession) then return tostring(XF.Config.DataText.Orders.Order[ info[#info] ]) end end,
		-- 			set = function(info, value) OrdersSelectedMenuItem(info[#info], value) end
		-- 		},
		-- 		ProfessionAlignment = {
		-- 			order = 52,
		-- 			type = 'select',
		-- 			hidden = function () return XF.Config.DataText.Orders.Column ~= 'Profession' end,
		-- 			disabled = function () return (not XF.Config.DataText.Orders.Enable.Profession) end,
		-- 			name = XF.Lib.Locale['ALIGNMENT'],
		-- 			desc = XF.Lib.Locale['DTORDERS_CONFIG_COLUMN_PROFESSION_ALIGNMENT_TOOLTIP'],
		-- 			values = {
		-- 				Center = XF.Lib.Locale['CENTER'],
		-- 				Left = XF.Lib.Locale['LEFT'],
		-- 				Right = XF.Lib.Locale['RIGHT'],
        --             },
		-- 			get = function(info) return XF.Config.DataText.Orders.Alignment[ info[#info] ] end,
		-- 			set = function(info, value) XF.Config.DataText.Orders.Alignment[ info[#info] ] = value; end
		-- 		},			
        --     },
		-- },
	},	
}