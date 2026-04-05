local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Config.Chat'

XF.Options.args.Chat = {
	name = XF.Lib.Locale['CHAT'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		GChat = {
			order = 1,
			type = 'group',
			name = 	XF.Lib.Locale['CHAT_GUILD'],
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
							name = XF.Lib.Locale['CHAT_GUILD_DESCRIPTION'],
						},
					}
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Options = {
					order = 3,
					type = 'group',
					name = '',
					inline = true,
					args = {
						Enable = {
							order = 3,
							type = 'toggle',
							name = XF.Lib.Locale['ENABLE'],
							desc = XF.Lib.Locale['CHAT_GUILD_TOOLTIP'],
							get = function(info) return XF.Config.Chat.GChat[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.GChat[ info[#info] ] = value; end
						},
						Space1 = {
							order = 4,
							type = 'description',
							name = '',
						},
						Faction = {
							order = 5,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_FACTION'],
							desc = XF.Lib.Locale['CHAT_FACTION_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.GChat.Enable)
							end,
							get = function(info) return XF.Config.Chat.GChat[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.GChat[ info[#info] ] = value; end
						},
						Guild = {
							order = 6,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_GUILD_NAME'],
							desc = XF.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.GChat.Enable)
							end,
							get = function(info) return XF.Config.Chat.GChat[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.GChat[ info[#info] ] = value; end
						},
						Main = {
							order = 7,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_MAIN'],
							desc = XF.Lib.Locale['CHAT_MAIN_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.GChat.Enable)
							end,
							get = function(info) return XF.Config.Chat.GChat[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.GChat[ info[#info] ] = value; end
						},
						Space2 = {
							order = 8,
							type = 'description',
							name = '',
						},
						CColor = {
							order = 9,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_CCOLOR'],
							desc = XF.Lib.Locale['CHAT_CCOLOR_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.GChat.Enable)
							end,
							get = function(info) return XF.Config.Chat.GChat[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.GChat[ info[#info] ] = value; end
						},
						Space3 = {
							order = 11,
							type = 'description',
							name = '',
						},
						Color = {
							order = 12,
							type = 'color',
							name = XF.Lib.Locale['CHAT_FONT_COLOR'],
							hidden = function()
								return (not XF.Config.Chat.GChat.Enable or not XF.Config.Chat.GChat.CColor)
							end,
							get = function()
								return XF.Config.Chat.GChat.Color.Red, XF.Config.Chat.GChat.Color.Green, XF.Config.Chat.GChat.Color.Blue
							end,
							set = function(_, inRed, inGreen, inBlue)
								XF.Config.Chat.GChat.Color.Red = inRed
								XF.Config.Chat.GChat.Color.Green = inGreen
								XF.Config.Chat.GChat.Color.Blue = inBlue
							end,
						},
					}
				},
			},
		},
		Login = {
			order = 3,
			type = 'group',
			name = XF.Lib.Locale['CHAT_ONLINE'],
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
							name = XF.Lib.Locale['CHAT_ONLINE_DESCRIPTION'],
						},
					}
				},
				Space1 = {
					order = 2,
					type = 'description',
					name = '',
				},
				Options = {
					order = 3,
					type = 'group',
					name = '',
					inline = true,
					args = {
						Enable = {
							order = 3,
							type = 'toggle',
							name = XF.Lib.Locale['ENABLE'],
							desc = XF.Lib.Locale['CHAT_ONLINE_TOOLTIP'],
							get = function(info) return XF.Config.Chat.Login[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Login[ info[#info] ] = value; end
						},
						Sound = {
							order = 4,
							type = 'toggle',
							disabled = function()
								return not XF.Config.Chat.Login.Enable
							end,
							name = XF.Lib.Locale['CHAT_ONLINE_SOUND'],
							desc = XF.Lib.Locale['CHAT_ONLINE_SOUND_TOOLTIP'],
							get = function(info) return XF.Config.Chat.Login[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Login[ info[#info] ] = value; end
						},
						Space1 = {
							order = 5,
							type = 'description',
							name = '',
						},
						Faction = {
							order = 6,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_FACTION'],
							desc = XF.Lib.Locale['CHAT_FACTION_TOOLTIP'],
							disabled = function()
								return not XF.Config.Chat.Login.Enable
							end,
							get = function(info) return XF.Config.Chat.Login[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Login[ info[#info] ] = value; end
						},
						Guild = {
							order = 7,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_GUILD_NAME'],
							desc = XF.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
							disabled = function()
								return not XF.Config.Chat.Login.Enable
							end,
							get = function(info) return XF.Config.Chat.Login[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Login[ info[#info] ] = value; end
						},
						Main = {
							order = 8,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_MAIN'],
							desc = XF.Lib.Locale['CHAT_MAIN_TOOLTIP'],
							disabled = function()
								return not XF.Config.Chat.Login.Enable
							end,
							get = function(info) return XF.Config.Chat.Login[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Login[ info[#info] ] = value; end
						},						
					},
				},
			}
		},		
		Crafting = {
			order = 5,
			type = 'group',
			name = XF.Lib.Locale['CRAFTING'],
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
							name = XF.Lib.Locale['CHAT_CRAFTING_DESCRIPTION'],
						},
					}
				},
				Space = {
					order = 2,
					type = 'description',
					name = '',
				},
				Options = {
					order = 3,
					type = 'group',
					name = '',
					inline = true,
					args = {
						Enable = {
							order = 1,
							type = 'toggle',
							name = XF.Lib.Locale['ENABLE'],
							desc = XF.Lib.Locale['CHAT_CRAFTING_TOOLTIP'],
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
						GuildOrder = {
							order = 2,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_CRAFTING_GUILD'],
							desc = XF.Lib.Locale['CHAT_CRAFTING_GUILD_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.Crafting.Enable)
							end,
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
						PersonalOrder = {
							order = 3,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_CRAFTING_PERSONAL'],
							desc = XF.Lib.Locale['CHAT_CRAFTING_PERSONAL_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.Crafting.Enable)
							end,
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
						Line = {
							order = 4,
							type = 'header',
							name = ''
						},
						Faction = {
							order = 5,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_FACTION'],
							desc = XF.Lib.Locale['CHAT_FACTION_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.Crafting.Enable)
							end,
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
						Main = {
							order = 6,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_MAIN'],
							desc = XF.Lib.Locale['CHAT_MAIN_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.Crafting.Enable)
							end,
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
						Guild = {
							order = 7,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_GUILD_NAME'],
							desc = XF.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
							disabled = function()
								return (not XF.Config.Chat.Crafting.Enable)
							end,
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
						Professions = {
							order = 8,
							type = 'toggle',
							name = XF.Lib.Locale['CHAT_CRAFTING_PROFESSION'],
							desc = XF.Lib.Locale['CHAT_CRAFTING_PROFESSION_TOOLTIP'],
							disabled = function()
								return not XF.Config.Chat.Crafting.Enable
							end,
							get = function(info) return XF.Config.Chat.Crafting[ info[#info] ] end,
							set = function(info, value) XF.Config.Chat.Crafting[ info[#info] ] = value; end
						},
					},
				},
			}
		},
	}
}