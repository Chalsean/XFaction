local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Quality = {
	name = XFG.Lib.Locale['QUALITY'],
	order = 1,
	type = 'group',
	args = {
		Life = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['QUALITY_EQUIP_DESCRIPTION'],
			guiInline = true,
			args = {
				Cloak = {
					order = 1,
					type = 'toggle',
					name = XFG.Lib.Locale['QUALITY_CLOAK_ENABLE'],
					desc = XFG.Lib.Locale['QUALITY_CLOAK_TOOLTIP'],
					get = function(info) return XFG.Config.Quality[ info[#info] ] end,
					set = function(info, value) XFG.Config.Quality[ info[#info] ] = value; end
				},
			}
		}
	}
}