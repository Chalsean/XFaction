local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Nameplates = {
	name = XFG.Lib.Locale['NAMEPLATES'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		ElvUI = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['ELVUI'],
			args = {
				DHeader = {
					order = 1,
					type = 'group',
					name = XFG.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_DESCRIPTION'],
						},
					}
				},
				Options = {
					order = 2,
					type = 'group',
					name = '',
					inline = true,
					disabled = function () 
						if(XFG.ElvUI and XFG.ElvUI.private.nameplates.enable) then
							return false
						end
						return true
					end,
					args = {
						Enable = {
							order = 2,
							type = 'toggle',
							name = XFG.Lib.Locale['ENABLE'],
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						Space1 = {
							order = 3,
							type = 'description',
							name = '',
							hidden = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
						},
						ConfederateTag = {
							type = 'input',
							order = 4,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						ConfederateBracketsTag = {
							type = 'input',
							order = 5,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_BRACKETS'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						TeamTag = {
							type = 'input',
							order = 6,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_TEAM'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						TeamParenthesisTag = {
							type = 'input',
							order = 7,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_TEAM_PARENTHESIS'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						ConfederateTeamTag = {
							type = 'input',
							order = 8,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_TEAM'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						ConfederateTeamBracketsTag = {
							type = 'input',
							order = 9,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_TEAM_BRACKETS'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},				
						MainNameTag = {
							type = 'input',
							order = 10,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MAIN_NAME'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},
						MainNameParenthesisTag = {
							type = 'input',
							order = 11,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MAIN_NAME_PARENTHESIS'],
							width = 'full',
							disabled = function () return not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.ElvUI[ info[#info] ] = value; end
						},	
					},	
				},		
			}
		},
		Kui = {
			order = 2,
			type = 'group',
			name = XFG.Lib.Locale['KUI'],
			args = {
				DHeader = {
					order = 1,
					type = 'group',
					name = XFG.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION'],
						},
					}
				},
				Options = {
					order = 2,
					type = 'group',
					name = '',
					inline = true,
					disabled = function () return not IsAddOnLoaded('Kui_Nameplates') end,
					args = {
						Enable = {
							order = 1,
							type = 'toggle',
							name = XFG.Lib.Locale['ENABLE'],
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
						Icon = {
							order = 2,
							type = 'toggle',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_ICON'],
							desc = XFG.Lib.Locale['NAMEPLATE_KUI_ICON_TOOLTIP'],
							disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
						Bar = {
							order = 3,
							name = format("|cffffffff%s|r", XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_TEXT']),
							type = 'header'
						},						
						Prepend = {
							order = 4,
							type = 'select',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_PREPEND'],
							desc = XFG.Lib.Locale['NAMEPLATE_KUI_CONFEDERATE_TOOLTIP'],
							values = {
								Confederate = XFG.Lib.Locale['CONFEDERATE'],
								ConfederateInitials = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
								Guild = XFG.Lib.Locale['GUILD'],
								GuildInitials = XFG.Lib.Locale['GUILD_INITIALS'],
								Team = XFG.Lib.Locale['TEAM'],
							},
							disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
						GuildName = {
							order = 5,
							type = 'select',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_NAME'],
							desc = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_INITIALS_TOOLTIP'],
							values = {
								Confederate = XFG.Lib.Locale['CONFEDERATE'],
								ConfederateInitials = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
								Guild = XFG.Lib.Locale['GUILD'],
								GuildInitials = XFG.Lib.Locale['GUILD_INITIALS'],
								Team = XFG.Lib.Locale['TEAM'],
							},
							disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
						Append = {
							order = 6,
							type = 'select',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_APPEND'],
							desc = XFG.Lib.Locale['NAMEPLATE_KUI_MAIN_TOOLTIP'],
							values = {
								Confederate = XFG.Lib.Locale['CONFEDERATE'],
								ConfederateInitials = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
								Guild = XFG.Lib.Locale['GUILD'],
								GuildInitials = XFG.Lib.Locale['GUILD_INITIALS'],
								Team = XFG.Lib.Locale['TEAM'],
							},
							disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
					},
				},			
			}
		},
	}
}