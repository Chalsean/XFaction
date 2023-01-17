local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Addons = {
	name = XFG.Lib.Locale['ADDONS'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
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
							get = function(info) return XFG.Config.Addons.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Addons.Kui[ info[#info] ] = value; end
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
									disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XFG.Config.Addons.Kui.Enable end,
									get = function(info) return XFG.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XFG.Config.Addons.Kui[ info[#info] ] = value end
								},
								MainName = {
									order = 2,
									type = 'toggle',
									name = XFG.Lib.Locale['NAMEPLATE_PLAYER_MAIN'],
									desc = XFG.Lib.Locale['NAMEPLATE_PLAYER_MAIN_TOOLTIP'],
									disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XFG.Config.Addons.Kui.Enable end,
									get = function(info) return XFG.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XFG.Config.Addons.Kui[ info[#info] ] = value end
								},
							},
						},
						Guild = {
							order = 3,
							type = 'group',
							name = XFG.Lib.Locale['GUILD'],
							inline = true,
							disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XFG.Config.Addons.Kui.Enable end,
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
									get = function(info) return XFG.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XFG.Config.Addons.Kui[ info[#info] ] = value; end
								},
								Hide = {
									order = 2,
									type = 'toggle',
									name = XFG.Lib.Locale['NAMEPLATE_GUILD_HIDE'],
									desc = XFG.Lib.Locale['NAMEPLATE_GUILD_HIDE_TOOLTIP'],
									get = function(info) return XFG.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XFG.Config.Addons.Kui[ info[#info] ] = value; end
								},
							},
						},
					},
				},			
			}
		},
	}
}