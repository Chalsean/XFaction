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
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
					hidden = function()
					    return (not XFG.Config.Chat.GChat.Enable)
					end,
				},
				Faction = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FACTION'],
					desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
					hidden = function()
					    return (not XFG.Config.Chat.GChat.Enable)
					end,
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Guild = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
					desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
					hidden = function()
					    return (not XFG.Config.Chat.GChat.Enable)
					end,
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Main = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_MAIN'],
					desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
					hidden = function()
					    return (not XFG.Config.Chat.GChat.Enable)
					end,
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Space2 = {
					order = 6,
					type = 'description',
					name = '',
					hidden = function()
					    return (not XFG.Config.Chat.GChat.Enable)
					end,
				},
				CColor = {
					order = 7,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_CCOLOR'],
					desc = XFG.Lib.Locale['CHAT_CCOLOR_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.GChat.Enable)
					end,
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				FColor = {
					order = 8,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FCOLOR'],
					desc = XFG.Lib.Locale['CHAT_FCOLOR_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.GChat.Enable)
					end,
					get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
				},
				Space3 = {
					order = 9,
					type = 'description',
					name = '',
					hidden = function()
					    return (not XFG.Config.Chat.GChat.Enable)
					end,
				},
				Color = {
					order = 10,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_COLOR'],
					hidden = function()
						return (not XFG.Config.Chat.GChat.Enable or XFG.Config.Chat.GChat.FColor or not XFG.Config.Chat.GChat.CColor)
					end,
					get = function()
						return XFG.Config.Chat.GChat.Color.Red, XFG.Config.Chat.GChat.Color.Green, XFG.Config.Chat.GChat.Color.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.GChat.Color.Red = inRed
						XFG.Config.Chat.GChat.Color.Green = inGreen
						XFG.Config.Chat.GChat.Color.Blue = inBlue
					end,
				},
				AColor = {
					order = 11,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_ACOLOR'],
					hidden = function()
						return (not XFG.Config.Chat.GChat.Enable or not XFG.Config.Chat.GChat.FColor or not XFG.Config.Chat.GChat.CColor)
					end,
					get = function()
						return XFG.Config.Chat.GChat.AColor.Red, XFG.Config.Chat.GChat.AColor.Green, XFG.Config.Chat.GChat.AColor.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.GChat.AColor.Red = inRed
						XFG.Config.Chat.GChat.AColor.Green = inGreen
						XFG.Config.Chat.GChat.AColor.Blue = inBlue
					end,
				},
				HColor = {
					order = 12,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_HCOLOR'],
					hidden = function()
						return (not XFG.Config.Chat.GChat.Enable or not XFG.Config.Chat.GChat.FColor or not XFG.Config.Chat.GChat.CColor)
					end,
					get = function()
						return XFG.Config.Chat.GChat.HColor.Red, XFG.Config.Chat.GChat.HColor.Green, XFG.Config.Chat.GChat.HColor.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.GChat.HColor.Red = inRed
						XFG.Config.Chat.GChat.HColor.Green = inGreen
						XFG.Config.Chat.GChat.HColor.Blue = inBlue
					end,
				},
			}
		},
		Achievement = {
			order = 2,
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
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
				},
				Faction = {
					order = 3,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FACTION'],
					desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Guild = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
					desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Main = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_MAIN'],
					desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Space2 = {
					order = 6,
					type = 'description',
					name = '',
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
				},
				CColor = {
					order = 7,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_CCOLOR'],
					desc = XFG.Lib.Locale['CHAT_CCOLOR_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				FColor = {
					order = 8,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FCOLOR'],
					desc = XFG.Lib.Locale['CHAT_FCOLOR_TOOLTIP'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable)
					end,
					get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
				},
				Space3 = {
					order = 9,
					type = 'description',
					name = '',
					hidden = function()
					    return (not XFG.Config.Chat.Achievement.Enable)
					end,
				},
				Color = {
					order = 10,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_COLOR'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable or XFG.Config.Chat.Achievement.FColor or not XFG.Config.Chat.Achievement.CColor)
					end,
					get = function()
						return XFG.Config.Chat.Achievement.Color.Red, XFG.Config.Chat.Achievement.Color.Green, XFG.Config.Chat.Achievement.Color.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.Achievement.Color.Red = inRed
						XFG.Config.Chat.Achievement.Color.Green = inGreen
						XFG.Config.Chat.Achievement.Color.Blue = inBlue
					end,
				},
				AColor = {
					order = 11,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_ACOLOR'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable or not XFG.Config.Chat.Achievement.FColor or not XFG.Config.Chat.Achievement.CColor)
					end,
					get = function()
						return XFG.Config.Chat.Achievement.AColor.Red, XFG.Config.Chat.Achievement.AColor.Green, XFG.Config.Chat.Achievement.AColor.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.Achievement.AColor.Red = inRed
						XFG.Config.Chat.Achievement.AColor.Green = inGreen
						XFG.Config.Chat.Achievement.AColor.Blue = inBlue
					end,
				},
				HColor = {
					order = 12,
					type = 'color',
					name = XFG.Lib.Locale['CHAT_FONT_HCOLOR'],
					hidden = function()
						return (not XFG.Config.Chat.Achievement.Enable or not XFG.Config.Chat.Achievement.FColor or not XFG.Config.Chat.Achievement.CColor)
					end,
					get = function()
						return XFG.Config.Chat.Achievement.HColor.Red, XFG.Config.Chat.Achievement.HColor.Green, XFG.Config.Chat.Achievement.HColor.Blue
					end,
					set = function(_, inRed, inGreen, inBlue)
						XFG.Config.Chat.Achievement.HColor.Red = inRed
						XFG.Config.Chat.Achievement.HColor.Green = inGreen
						XFG.Config.Chat.Achievement.HColor.Blue = inBlue
					end,
				},
			}
		},
		Login = {
			order = 3,
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
					set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
				},
				Sound = {
					order = 2,
					type = 'toggle',
					hidden = function()
						return not XFG.Config.Chat.Login.Enable
					end,
					name = XFG.Lib.Locale['CHAT_ONLINE_SOUND'],
					desc = XFG.Lib.Locale['CHAT_ONLINE_SOUND_TOOLTIP'],
					get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
				},
				Space1 = {
					order = 3,
					type = 'description',
					name = '',
					hidden = function()
						return not XFG.Config.Chat.Login.Enable
					end,
				},
				Faction = {
					order = 4,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_FACTION'],
					desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
					hidden = function()
						return not XFG.Config.Chat.Login.Enable
					end,
					get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
				},
				Guild = {
					order = 5,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
					desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
					hidden = function()
						return not XFG.Config.Chat.Login.Enable
					end,
					get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
				},
				Main = {
					order = 6,
					type = 'toggle',
					name = XFG.Lib.Locale['CHAT_MAIN'],
					desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
					hidden = function()
						return not XFG.Config.Chat.Login.Enable
					end,
					get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
					set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
				},
			}
		}
	}
}