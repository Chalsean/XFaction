local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function DefaultConfigs()
	if(XFG.Options == nil) then XFG.Options = {} end
	if(XFG.Config.Chat == nil) then XFG.Config.Chat = {} end
	if(XFG.Config.Chat.GChat == nil) then XFG.Config.Chat.GChat = {} end
	if(XFG.Config.Chat.GChat.Enable == nil) then XFG.Config.Chat.GChat.Enable = true end
	if(XFG.Config.Chat.GChat.Faction == nil) then XFG.Config.Chat.GChat.Faction = true end
	if(XFG.Config.Chat.GChat.Guild == nil) then XFG.Config.Chat.GChat.Guild = true end
	if(XFG.Config.Chat.GChat.Main == nil) then XFG.Config.Chat.GChat.Main = true end
	if(XFG.Config.Chat.GChat.Color == nil) then XFG.Config.Chat.GChat.Color = {} end
	if(XFG.Config.Chat.GChat.Color.Red == nil) then XFG.Config.Chat.GChat.Color.Red = 0 end
	if(XFG.Config.Chat.GChat.Color.Green == nil) then XFG.Config.Chat.GChat.Color.Green = 0 end
	if(XFG.Config.Chat.GChat.Color.Blue == nil) then XFG.Config.Chat.GChat.Color.Blue = 0 end
	
	if(XFG.Config.Chat.OChat == nil) then XFG.Config.Chat.OChat = false end

	if(XFG.Config.Chat.Achievement == nil) then XFG.Config.Chat.Achievement = {} end
	if(XFG.Config.Chat.Achievement.Enable == nil) then XFG.Config.Chat.Achievement.Enable = true end
	if(XFG.Config.Chat.Achievement.Faction == nil) then XFG.Config.Chat.Achievement.Faction = true end
	if(XFG.Config.Chat.Achievement.Guild == nil) then XFG.Config.Chat.Achievement.Guild = true end
	if(XFG.Config.Chat.Achievement.Main == nil) then XFG.Config.Chat.Achievement.Main = true end
	if(XFG.Config.Chat.Achievement.Color == nil) then XFG.Config.Chat.Achievement.Color = {} end
	if(XFG.Config.Chat.Achievement.Color.Red == nil) then XFG.Config.Chat.Achievement.Color.Red = 0 end
	if(XFG.Config.Chat.Achievement.Color.Green == nil) then XFG.Config.Chat.Achievement.Color.Green = 0 end
	if(XFG.Config.Chat.Achievement.Color.Blue == nil) then XFG.Config.Chat.Achievement.Color.Blue = 0 end

	if(XFG.Config.Chat.Login == nil) then XFG.Config.Chat.Login = {} end
	if(XFG.Config.Chat.Login.Enable == nil) then XFG.Config.Chat.Login.Enable = true end
end

function XFG:ChatConfig()
	DefaultConfigs()
	XFG.Options.Chat = {
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

	XFG.Lib.Config:RegisterOptionsTable('XFaction Chat', XFG.Options.Chat)
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction Chat', 'Chat', 'XFaction')
end