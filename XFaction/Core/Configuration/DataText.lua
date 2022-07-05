local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function OrderMenu()
	if(XFG.Cache.DTGuildTotalEnabled == nil) then XFG.Cache.DTGuildTotalEnabled = 0 end
	if(XFG.Cache.DTGuildTotalEnabled == 0) then
		for _Label, _Value in pairs (XFG.Config.DataText.Guild.Enable) do
			if(_Value) then
				_OrderLabel = _Label .. 'Order'
				if(XFG.Config.DataText.Guild.Order[_OrderLabel] ~= 0) then
					XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled + 1
				end
			end
		end
	end

	local _Menu = {}
	for i = 1, XFG.Cache.DTGuildTotalEnabled do
		_Menu[tostring(i)] = i
	end

	return _Menu
end

local function RemovedMenuItem(inColumnName)
	local _Index = XFG.Config.DataText.Guild.Order[inColumnName .. 'Order']
	XFG.Config.DataText.Guild.Order[_Index] = 0
	XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled - 1
	for _ColumnName, _OrderNumber in pairs (XFG.Config.DataText.Guild.Order) do
		if(_OrderNumber > _Index) then
			XFG.Config.DataText.Guild.Order[_ColumnName] = _OrderNumber - 1
		end
	end
end

local function AddedMenuItem(inColumnName)
	local _OrderLabel = inColumnName .. 'Order'
	XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled + 1
	XFG.Config.DataText.Guild.Order[_OrderLabel] = XFG.Cache.DTGuildTotalEnabled
end

local function SelectedMenuItem(inColumnName, inSelection)
	local _OldNumber = XFG.Config.DataText.Guild.Order[inColumnName]
	local _NewNumber = tonumber(inSelection)
	XFG.Config.DataText.Guild.Order[inColumnName] = _NewNumber
	for _ColumnName, _OrderNumber in pairs (XFG.Config.DataText.Guild.Order) do
		if(_ColumnName ~= inColumnName) then
			if(_OldNumber < _NewNumber and _OrderNumber > _OldNumber and _OrderNumber <= _NewNumber) then
				XFG.Config.DataText.Guild.Order[_ColumnName] = _OrderNumber - 1
			elseif(_OldNumber > _NewNumber and _OrderNumber < _OldNumber and _OrderNumber >= _NewNumber) then
				XFG.Config.DataText.Guild.Order[_ColumnName] = _OrderNumber + 1
			end
		end
	end
end

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
					name = XFG.Lib.Locale['DTGUILD_BROKER_HEADER']
				},
				Space1 = {
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
					order = 5,
					type = 'header',
					name = ''
				},
				Description1 = {
					order = 6,
					type = 'description',
					fontSize = 'medium',
					name = XFG.Lib.Locale['DTGUILD_CONFIG_HEADER']
				},
				Space2 = {
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
				Space3 = {
					order = 12,
					type = 'description',
					name = '',
				},
				Sort = {
					order = 13,
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
						Note = XFG.Lib.Locale['NOTE'],
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
					order = 14,
					type = 'header',
					name = ''
				},
				Column = {
					order = 15,
					type = 'select',
					name = XFG.Lib.Locale['DTGUILD_SELECT_COLUMN'],
					desc = XFG.Lib.Locale['DTGUILD_SELECT_COLUMN_TOOLTIP'],
					values = {
						Achievement = XFG.Lib.Locale['ACHIEVEMENT'],
						Covenant = XFG.Lib.Locale['COVENANT'],
						Faction = XFG.Lib.Locale['FACTION'],
						Guild = XFG.Lib.Locale['GUILD'],
						ItemLevel = XFG.Lib.Locale['ITEMLEVEL'],
						Level = XFG.Lib.Locale['LEVEL'],
						Dungeon = XFG.Lib.Locale['DUNGEON'],
						Name = XFG.Lib.Locale['NAME'],
						Note = XFG.Lib.Locale['NOTE'],
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
					order = 16,
					type = 'description',
					name = '',
					--hidden = function()	return XFG.Config.DataText.Guild.Enable.Achievement	end,
				},
				Achievement = {
					order = 17,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'],
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Achievement' end,
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				AchievementOrder = {
					order = 18,
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
					order = 19,
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
				Covenant = {
					order = 17,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_TOOLTIP'],
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Covenant' end,
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				CovenantOrder = {
					order = 18,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Covenant' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Covenant) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Covenant) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				CovenantAlignment = {
					order = 19,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Covenant' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Covenant) end,
					name = XFG.Lib.Locale['ALIGNMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_ALIGNMENT_TOOLTIP'],
					values = {
						Center = XFG.Lib.Locale['CENTER'],
						Left = XFG.Lib.Locale['LEFT'],
						Right = XFG.Lib.Locale['RIGHT'],
                    },
					get = function(info) return XFG.Config.DataText.Guild.Alignment[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild.Alignment[ info[#info] ] = value; end
				},
				Faction = {
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Faction' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				FactionOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Guild' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				GuildOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'ItemLevel' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ItemLevelOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Level' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				LevelOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Dungeon' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				DungeonOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					disabled = true,
					name = XFG.Lib.Locale['ENABLE'],
					disabled = true,
					desc = '',
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				NameOrder = {
					order = 18,
					type = 'select',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				NameAlignment = {
					order = 19,
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
					order = 20,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Name' end,
					name = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ENABLE_MAIN'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Note = {
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Note' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				NoteOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Profession' end,
					disabled = function () return (not XFG.Config.DataText.Guild.Enable.Profession) end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ProfessionOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'PvP' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PVP_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				PvPOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Race' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RaceOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Raid' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RaidOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Rank' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RankOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Realm' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RealmOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Spec' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				SpecOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Team' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				TeamOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Version' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				VersionOrder = {
					order = 18,
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
					order = 19,
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
					order = 17,
					type = 'toggle',
					hidden = function () return XFG.Config.DataText.Guild.Column ~= 'Zone' end,
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ZoneOrder = {
					order = 18,
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
					order = 19,
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