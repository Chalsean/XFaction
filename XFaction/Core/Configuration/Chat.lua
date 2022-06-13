local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

--function XFG:ChatConfig()
	XFG.Options.args.Chat = {
		name = 'XFaction - Chat',
		order = 1,
		type = 'group',
		args = {
			GChat = {
				order = 1,
				type = 'group',
				name = 'Guild Chat',
				guiInline = true,
				args = {
					Enable = {
						order = 1,
						type = 'toggle',
						name = 'Enable',
						desc = 'See cross realm/faction guild chat',
						get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
						set = function(info, value) 
							XFG.Config.Chat.GChat[ info[#info] ] = value; 
							local _Disabled = (value == false) and true or false
							XFG.Options.Chat.args.GChat.args.Faction.disabled = _Disabled
							XFG.Options.Chat.args.GChat.args.Guild.disabled = _Disabled
							XFG.Options.Chat.args.GChat.args.Main.disabled = _Disabled
							XFG.Options.Chat.args.GChat.args.Color.disabled = _Disabled
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
						name = 'Show Faction',
						desc = 'Show the faction icon for the player',
						get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
						set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
					},
					Guild = {
						order = 4,
						type = 'toggle',
						name = 'Show Guild Name',
						desc = 'Show the guild short name for the player',
						get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
						set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
					},
					Main = {
						order = 5,
						type = 'toggle',
						name = 'Show Main Name',
						desc = 'Show the players main name if it is an alt',
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
						name = 'Font Color',
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
				name = 'Officer Chat',
				guiInline = true,
				args = {
					Enable = {
						order = 1,
						type = 'toggle',
						name = 'Enable',
						disabled = true,
						desc = 'See cross realm/faction officer chat',
						get = function(info) return XFG.Config.Chat[ info[#info] ] end,
						set = function(info, value) XFG.Config.Chat[ info[#info] ] = value; end
					}
				}
			},
			Achievement = {
				order = 3,
				type = 'group',
				name = 'Achievement',
				guiInline = true,
				args = {
					Enable = {
						order = 1,
						type = 'toggle',
						name = 'Enable',
						desc = 'See cross realm/faction guild chat',
						get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
						set = function(info, value) 
							XFG.Config.Chat.Achievement[ info[#info] ] = value; 
							local _Disabled = (value == false) and true or false
							XFG.Options.Chat.args.Achievement.args.Faction.disabled = _Disabled
							XFG.Options.Chat.args.Achievement.args.Guild.disabled = _Disabled
							XFG.Options.Chat.args.Achievement.args.Main.disabled = _Disabled
							XFG.Options.Chat.args.Achievement.args.Color.disabled = _Disabled
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
						name = 'Show Faction',
						desc = 'Show the faction icon for the player',
						get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
						set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
					},
					Guild = {
						order = 4,
						type = 'toggle',
						name = 'Show Guild Name',
						desc = 'Show the guild short name for the player',
						get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
						set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
					},
					Main = {
						order = 5,
						type = 'toggle',
						name = 'Show Main Name',
						desc = 'Show the players main name if it is an alt',
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
						name = 'Font Color',
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
				name = 'Online/Offline',
				guiInline = true,
				args = {
					Enable = {
						order = 1,
						type = 'toggle',
						name = 'Enable',
						desc = 'Show message for players logging in/out on other realms/faction',
						get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
						set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
					}
				}
			}
		}
	}
--end