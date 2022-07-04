local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local _TotalEnabled = 0

local function OrderMenu()
	if(_TotalEnabled == 0) then
		for _Label, _Value in pairs (XFG.Config.DataText.Guild.Enable) do
			if(_Value) then
				_OrderLabel = _Label .. 'Order'
				if(XFG.Config.DataText.Guild.Order[_OrderLabel] ~= 0) then
					_TotalEnabled = _TotalEnabled + 1
				end
			end
		end
	end

	local _Menu = {}
	for i = 1, _TotalEnabled do
		_Menu[tostring(i)] = i
	end

	return _Menu
end

local function RemovedMenuItem(inColumnName)
	local _Index = XFG.Config.DataText.Guild.Order[inColumnName .. 'Order']
	XFG.Config.DataText.Guild.Order[_Index] = 0
	_TotalEnabled = _TotalEnabled - 1
	for _ColumnName, _OrderNumber in pairs (XFG.Config.DataText.Guild.Order) do
		if(_OrderNumber > _Index) then
			XFG.Config.DataText.Guild.Order[_ColumnName] = _OrderNumber - 1
		end
	end
end

local function AddedMenuItem(inColumnName)
	local _OrderLabel = inColumnName .. 'Order'
	_TotalEnabled = _TotalEnabled + 1
	XFG.Config.DataText.Guild.Order[_OrderLabel] = _TotalEnabled
end

local function SelectedMenuItem(inColumnName, inSelection)
	XFG.Config.DataText.Guild.Order[inColumnName] = tonumber(inSelection)
	for _ColumnName, _OrderNumber in pairs (XFG.Config.DataText.Guild.Order) do
		if(_ColumnName ~= inColumnName and _OrderNumber >= tonumber(inSelection) and _OrderNumber < _TotalEnabled) then
			XFG.Config.DataText.Guild.Order[_ColumnName] = _OrderNumber + 1
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
					name = XFG.Lib.Locale['DT_CONFIG_BROKER']
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
				Achievement = {
					order = 13,
					type = 'toggle',
					name = XFG.Lib.Locale['ACHIEVEMENT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				AchievementOrder = {
					order = 14,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Achievement) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Achievement) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},				
				AchievementAlignment = {
					order = 15,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Achievement) end,
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
				Space4 = {
					order = 14,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Achievement	end,
				},
				Covenant = {
					order = 16,
					type = 'toggle',
					name = XFG.Lib.Locale['COVENANT'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				CovenantOrder = {
					order = 17,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Covenant) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_COVENANT_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Covenant) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				CovenantAlignment = {
					order = 18,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Covenant) end,
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
				Space5 = {
					order = 17,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Covenant end,
				},
				Faction = {
					order = 19,
					type = 'toggle',
					name = XFG.Lib.Locale['FACTION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				FactionOrder = {
					order = 20,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Faction) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_FACTION_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Faction) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				FactionAlignment = {
					order = 21,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Faction) end,
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
				Space6 = {
					order = 20,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Faction end,
				},
				Guild = {
					order = 22,
					type = 'toggle',
					name = XFG.Lib.Locale['GUILD'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				GuildOrder = {
					order = 23,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Guild) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_GUILD_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Guild) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				GuildAlignment = {
					order = 24,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Guild) end,
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
				Space7 = {
					order = 23,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Guild end,
				},
				ItemLevel = {
					order = 25,
					type = 'toggle',
					name = XFG.Lib.Locale['ITEMLEVEL'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ItemLevelOrder = {
					order = 26,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.ItemLevel) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.ItemLevel) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				ItemLevelAlignment = {
					order = 27,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.ItemLevel) end,
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
				Space8 = {
					order = 26,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.ItemLevel end,
				},
				Level = {
					order = 28,
					type = 'toggle',
					name = XFG.Lib.Locale['LEVEL'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				LevelOrder = {
					order = 29,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Level) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_LEVEL_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Level) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				LevelAlignment = {
					order = 30,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Level) end,
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
				Space9 = {
					order = 29,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Level end,
				},
				Main = {
					order = 30,
					type = 'toggle',
					name = XFG.Lib.Locale['MAIN'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Space10 = {
					order = 31,
					type = 'description',
					name = '',
				},
				Dungeon = {
					order = 34,
					type = 'toggle',
					name = XFG.Lib.Locale['DUNGEON'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				DungeonOrder = {
					order = 35,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Dungeon) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_DUNGEON_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Dungeon) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				DungeonAlignment = {
					order = 36,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Dungeon) end,
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
				Space11 = {
					order = 35,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Dungeon end,
				},
				Name = {
					order = 37,
					type = 'toggle',
					name = XFG.Lib.Locale['NAME'],
					disabled = true,
					desc = '',
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				NameOrder = {
					order = 38,
					type = 'select',
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NAME_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				NameAlignment = {
					order = 39,
					type = 'select',
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
				Note = {
					order = 40,
					type = 'toggle',
					name = XFG.Lib.Locale['NOTE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				NoteOrder = {
					order = 41,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Note) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_NOTE_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Note) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				NoteAlignment = {
					order = 42,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Note) end,
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
				Space12 = {
					order = 41,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Note end,
				},
				Profession = {
					order = 43,
					type = 'toggle',
					name = XFG.Lib.Locale['PROFESSION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ProfessionOrder = {
					order = 44,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Profession) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_PROFESSION_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Profession) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				ProfessionAlignment = {
					order = 45,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Profession) end,
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
				Space13 = {
					order = 44,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Profession end,
				},
				Race = {
					order = 46,
					type = 'toggle',
					name = XFG.Lib.Locale['RACE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RaceOrder = {
					order = 47,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Race) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RACE_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Race) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RaceAlignment = {
					order = 48,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Race) end,
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
				Space14 = {
					order = 47,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Race end,
				},
				Raid = {
					order = 49,
					type = 'toggle',
					name = XFG.Lib.Locale['RAID'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RaidOrder = {
					order = 50,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Raid) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RAID_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Raid) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RaidAlignment = {
					order = 51,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Raid) end,
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
				Space15 = {
					order = 50,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Rank end,
				},
				Rank = {
					order = 52,
					type = 'toggle',
					name = XFG.Lib.Locale['RANK'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RankOrder = {
					order = 53,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Rank) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_RANK_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Rank) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RankAlignment = {
					order = 54,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Rank) end,
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
				Space16 = {
					order = 53,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Rank end,
				},
				Realm = {
					order = 55,
					type = 'toggle',
					name = XFG.Lib.Locale['REALM'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				RealmOrder = {
					order = 56,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Realm) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_REALM_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Realm) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				RealmAlignment = {
					order = 57,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Realm) end,
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
				Space17 = {
					order = 56,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Realm end,
				},
				Spec = {
					order = 58,
					type = 'toggle',
					name = XFG.Lib.Locale['SPEC'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				SpecOrder = {
					order = 59,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Spec) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_SPEC_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Spec) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				SpecAlignment = {
					order = 60,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Spec) end,
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
				Space18 = {
					order = 59,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Spec end,
				},
				Team = {
					order = 61,
					type = 'toggle',
					name = XFG.Lib.Locale['TEAM'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				TeamOrder = {
					order = 62,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Team) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_TEAM_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Team) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				TeamAlignment = {
					order = 63,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Team) end,
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
				Space19 = {
					order = 62,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Team end,
				},
				Version = {
					order = 64,
					type = 'toggle',
					name = XFG.Lib.Locale['VERSION'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				VersionOrder = {
					order = 65,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Version) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_VERSION_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Version) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				VersionAlignment = {
					order = 66,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Version) end,
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
				Space20 = {
					order = 65,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Version end,
				},
				Zone = {
					order = 67,
					type = 'toggle',
					name = XFG.Lib.Locale['ZONE'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'],
					get = function(info) return XFG.Config.DataText.Guild.Enable[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.DataText.Guild.Enable[ info[#info] ] = value
						if(value) then AddedMenuItem(info[#info]) else RemovedMenuItem(info[#info]) end
					end
				},
				ZoneOrder = {
					order = 68,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Zone) end,
					name = XFG.Lib.Locale['ORDER'],
					desc = XFG.Lib.Locale['DTGUILD_CONFIG_COLUMN_ZONE_ORDER_TOOLTIP'],
					values = function () return OrderMenu() end,
					get = function(info) if(XFG.Config.DataText.Guild.Enable.Zone) then return tostring(XFG.Config.DataText.Guild.Order[ info[#info] ]) end end,
					set = function(info, value) SelectedMenuItem(info[#info], value) end
				},
				ZoneAlignment = {
					order = 69,
					type = 'select',
					hidden = function () return (not XFG.Config.DataText.Guild.Enable.Zone) end,
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
				Space21 = {
					order = 68,
					type = 'description',
					name = '',
					hidden = function()	return XFG.Config.DataText.Guild.Enable.Zone end,
				},
				Line2 = {
					order = 70,
					type = 'header',
					name = ''
				},
				Sort = {
					order = 71,
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
						Race = XFG.Lib.Locale['RACE'],
						Raid = XFG.Lib.Locale['RAID'],
						Realm = XFG.Lib.Locale['REALM'],
						Team = XFG.Lib.Locale['TEAM'],
						Version = XFG.Lib.Locale['VERSION'],
						Zone = XFG.Lib.Locale['ZONE'],
                    },
					get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
					set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
				},
				Size = {
					order = 72,
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