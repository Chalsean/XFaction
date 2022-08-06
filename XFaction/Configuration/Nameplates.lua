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
				Enable = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['NAMEPLATE_CONFEDERATE'],
					desc = XFG.Lib.Locale['NAMEPLATE_CONFEDERATE_TOOLTIP'],
					hidden = function () return not IsAddOnLoaded('ElvUI') end,
					get = function(info) return XFG.Config.Nameplates.Confederate[ info[#info] ] end,
					set = function(info, value) XFG.Config.Nameplates.Confederate[ info[#info] ] = value; end
				},
			}
		},
	}
}