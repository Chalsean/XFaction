local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Chat = {
	name = XFG.Lib.Locale['CHAT'],
	order = 1,
	type = 'group',
	args = {
		GChat = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['CHAT_GUILD'],
			guiInline = true,
			args = {
				Enable = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['CHAT_GUILD_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.Chat.GChat[ info[#info] ] = value; 
						local _Disabled = (value == false) and true or false
						XFG.Options.args.Chat.args.GChat.args.Faction.disabled = _Disabled
						XFG.Options.args.Chat.args.GChat.args.Guild.disabled = _Disabled
						XFG.Options.args.Chat.args.GChat.args.Main.disabled = _Disabled
						XFG.Options.args.Chat.args.GChat.args.Color.disabled = _Disabled
					end
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Faction = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FACTION'],
					desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Guild = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
					desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Main = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_MAIN'],
					desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Space2 = {
					order = 6,
					type = 'description',
					name = '',
				},
				Color = {
					order = 7,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_COLOR'],
					get = function()
						return XFG.Config.Chat.GChat.Color.Red, XFG.Config.Chat.GChat.Color.Green, XFG.Config.Chat.GChat.Color.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.GChat.Color.Red = inRed
						XFG.Config.Chat.GChat.Color.Green = inGreen
						XFG.Config.Chat.GChat.Color.Blue = inBlue
					end,
				},
			}
		},
		OChat = {
			order = 2,
			type = 'group',
			name = XFG.Lib.Locale['CHAT_OFFICER'],
			guiInline = true,
			args = {
				Enable = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					disabled = true,
					desc = XFG.Lib.Locale['CHAT_OFFICER_TOOLTIP'],
					get = function(info) return XFG.Config.Chat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat[ info[#info] ] = value; end
				}
			}
		},
		Achievement = {
			order = 3,
			type = 'group',
			name = XFG.Lib.Locale['ACHIEVEMENT'],
			guiInline = true,
			args = {
				Enable = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					desc = 'See cross realm/faction individual achievements',
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.Chat.Achievement[ info[#info] ] = value; 
						local _Disabled = (value == false) and true or false
						XFG.Options.args.Chat.args.Achievement.args.Faction.disabled = _Disabled
						XFG.Options.args.Chat.args.Achievement.args.Guild.disabled = _Disabled
						XFG.Options.args.Chat.args.Achievement.args.Main.disabled = _Disabled
						XFG.Options.args.Chat.args.Achievement.args.Color.disabled = _Disabled
					end
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Faction = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FACTION'],
					desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Guild = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
					desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Main = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_MAIN'],
					desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Space2 = {
					order = 6,
					type = 'description',
					name = '',
				},
				Color = {
					order = 7,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_COLOR'],
					get = function()
						return XFG.Config.Chat.Achievement.Color.Red, XFG.Config.Chat.Achievement.Color.Green, XFG.Config.Chat.Achievement.Color.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.Achievement.Color.Red = inRed
						XFG.Config.Chat.Achievement.Color.Green = inGreen
						XFG.Config.Chat.Achievement.Color.Blue = inBlue
					end,
				},
				
			}
		},
		Login = {
			order = 4,
			type = 'group',
			name = XFG.Lib.Locale['CHAT_ONLINE'],
			guiInline = true,
			args = {
				Enable = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					desc = XFG.Lib.Locale['CHAT_ONLINE_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
					set = function(info, value) 
						XFG.Config.Chat.Login[ info[#info] ] = value; 
						local _Disabled = (value == false) and true or false
						XFG.Options.args.Chat.args.Login.args.Sound.disabled = _Disabled
					end
				},
				Sound = {
					order = 2,
					type = 'toggle',
					disabled = false,
					name = XFG.Lib.Locale['CHAT_ONLINE_SOUND'],
					desc = XFG.Lib.Locale['CHAT_ONLINE_SOUND_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
				}
			}
		}
	}
}