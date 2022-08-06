local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Nameplates = {
	name = XFG.Lib.Locale['NAMEPLATES'],
	order = 1,
	type = 'group',
	args = {
		Confederate = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['ELVUI'],
			guiInline = true,
			args = {
				DHeader = {
					order = 1,
					type = 'group',
					name = XFG.Lib.Locale['DESCRIPTION'],
					guiInline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_DESCRIPTION'],
						},
					}
				},
				Enable = {
					order = 2,
					type = 'toggle',
					name = XFG.Lib.Locale['ENABLE'],
					--desc = XFG.Lib.Locale['NAMEPLATE_CONFEDERATE_TOOLTIP'],
					hidden = function () return not XFG.ElvUI and true or false end,
					get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
				},
				Space1 = {
					order = 3,
					type = 'description',
					name = '',
					hidden = function () return not XFG.Config.Nameplates.Confederate.Enable end,
				},
				ConfederateTag = {
                    type = 'input',
					order = 4,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },
				ConfederateBracketsTag = {
                    type = 'input',
					order = 5,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_BRACKETS'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },
				TeamTag = {
                    type = 'input',
					order = 6,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_TEAM'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },
				TeamParenthesisTag = {
                    type = 'input',
					order = 7,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_TEAM_PARENTHESIS'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },
				ConfederateTeamTag = {
                    type = 'input',
					order = 8,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_TEAM'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },
				ConfederateTeamBracketsTag = {
                    type = 'input',
					order = 9,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_CONFEDERATE_TEAM_BRACKETS'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },				
				MainNameTag = {
                    type = 'input',
					order = 10,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MAIN_NAME'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },
				MainNameParenthesisTag = {
                    type = 'input',
					order = 11,
                    name = XFG.Lib.Locale['NAMEPLATE_ELVUI_MAIN_NAME_PARENTHESIS'],
					width = 'full',
					disabled = function () return not XFG.Config.Nameplates.Confederate.Enable end,
                    get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
                },				
			}
		},
	}
}