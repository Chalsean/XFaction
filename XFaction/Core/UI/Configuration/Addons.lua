local XF, G = unpack(select(2, ...))
local LogCategory = 'Config'

XF.Options.args.Addons = {
	name = XF.Lib.Locale['ADDONS'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		Kui = {
			order = 2,
			type = 'group',
			name = XF.Lib.Locale['KUI'],
			args = {
				DHeader = {
					order = 1,
					type = 'group',
					name = XF.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XF.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION'],
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
							name = XF.Lib.Locale['ENABLE'],							
							get = function(info) return XF.Config.Addons.Kui[ info[#info] ] end,
							set = function(info, value) XF.Config.Addons.Kui[ info[#info] ] = value; end
						},
						Player = {
							order = 2,
							type = 'group',
							name = XF.Lib.Locale['PLAYER'],
							inline = true,
							args = {
								Icon = {
									order = 1,
									type = 'toggle',
									name = XF.Lib.Locale['NAMEPLATE_ICON'],
									desc = XF.Lib.Locale['NAMEPLATE_ICON_TOOLTIP'],
									disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XF.Config.Addons.Kui.Enable end,
									get = function(info) return XF.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XF.Config.Addons.Kui[ info[#info] ] = value end
								},
								MainName = {
									order = 2,
									type = 'toggle',
									name = XF.Lib.Locale['NAMEPLATE_PLAYER_MAIN'],
									desc = XF.Lib.Locale['NAMEPLATE_PLAYER_MAIN_TOOLTIP'],
									disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XF.Config.Addons.Kui.Enable end,
									get = function(info) return XF.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XF.Config.Addons.Kui[ info[#info] ] = value end
								},
							},
						},
						Guild = {
							order = 3,
							type = 'group',
							name = XF.Lib.Locale['GUILD'],
							inline = true,
							disabled = function () return not IsAddOnLoaded('Kui_Nameplates') or not XF.Config.Addons.Kui.Enable end,
							args = {					
								GuildName = {
									order = 1,
									type = 'select',
									name = XF.Lib.Locale['GUILD_NAME'],
									desc = XF.Lib.Locale['NAMEPLATE_GUILD_NAME_TOOLTIP'],
									values = {
										Confederate = XF.Lib.Locale['CONFEDERATE_NAME'],
										ConfederateInitials = XF.Lib.Locale['CONFEDERATE_INITIALS'],
										Guild = XF.Lib.Locale['GUILD_NAME'],
										GuildInitials = XF.Lib.Locale['GUILD_INITIALS'],
										Team = XF.Lib.Locale['TEAM'],
									},									
									get = function(info) return XF.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XF.Config.Addons.Kui[ info[#info] ] = value; end
								},
								Hide = {
									order = 2,
									type = 'toggle',
									name = XF.Lib.Locale['NAMEPLATE_GUILD_HIDE'],
									desc = XF.Lib.Locale['NAMEPLATE_GUILD_HIDE_TOOLTIP'],
									get = function(info) return XF.Config.Addons.Kui[ info[#info] ] end,
									set = function(info, value) XF.Config.Addons.Kui[ info[#info] ] = value; end
								},
							},
						},
					},
				},			
			}
		},
	}
}