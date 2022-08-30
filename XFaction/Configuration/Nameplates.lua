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
						},
						ConfederateTag = {
							type = 'input',
							order = 4,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) end
						},
						ConfederateInitialsTag = {
							type = 'input',
							order = 5,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_INITIALS'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) end
						},
						GuildInitialsTag = {
							type = 'input',
							order = 6,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_GUILD_INITIALS'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) end
						},
						MainTag = {
							type = 'input',
							order = 7,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MAIN'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) end
						},
						MainParenthesisTag = {
							type = 'input',
							order = 8,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MAIN_PARENTHESIS'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) end
						},
						TeamTag = {
							type = 'input',
							order = 9,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_TEAM'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
							get = function(info) return XFG.Config.Nameplates.ElvUI[ info[#info] ] end,
							set = function(info, value) end
						},
						MemberIcon = {
							type = 'input',
							order = 10,
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MEMBER_ICON'],
							width = 'full',
							disabled = function () return not XFG.ElvUI or not XFG.ElvUI.private.nameplates.enable or not XFG.Config.Nameplates.ElvUI.Enable end,
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
						Player = {
							order = 2,
							type = 'group',
							name = XFG.Lib.Locale['PLAYER'],
							inline = true,
							args = {
								Icon = {
									order = 1,
									type = 'toggle',
									name = XFG.Lib.Locale['NAMEPLATE_ICON'],
									desc = XFG.Lib.Locale['NAMEPLATE_ICON_TOOLTIP'],
									disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XFG.Config.Nameplates.Kui.Enable end,
									get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
									set = function(info, value) 
										XFG.Config.Nameplates.Kui[ info[#info] ] = value
									end
								},
							},
						},
						Guild = {
							order = 3,
							type = 'group',
							name = XFG.Lib.Locale['GUILD'],
							inline = true,
							disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XFG.Config.Nameplates.Kui.Enable end,
							args = {					
								GuildName = {
									order = 1,
									type = 'select',
									name = XFG.Lib.Locale['GUILD_NAME'],
									desc = XFG.Lib.Locale['NAMEPLATE_GUILD_NAME_TOOLTIP'],
									values = {
										Confederate = XFG.Lib.Locale['CONFEDERATE_NAME'],
										ConfederateInitials = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
										Guild = XFG.Lib.Locale['GUILD_NAME'],
										GuildInitials = XFG.Lib.Locale['GUILD_INITIALS'],
										Team = XFG.Lib.Locale['TEAM'],
									},									
									get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
									set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
								},
								Hide = {
									order = 2,
									type = 'toggle',
									name = XFG.Lib.Locale['NAMEPLATE_GUILD_HIDE'],
									desc = XFG.Lib.Locale['NAMEPLATE_GUILD_HIDE_TOOLTIP'],
									get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
									set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
								},
							},
						},
					},
				},			
			}
		},
	}
}