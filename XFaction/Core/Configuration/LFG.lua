local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.LFG = {
	name = XFG.Lib.Locale['LFG'],
	order = 1,
	type = 'group',
	args = {
		LFG = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['LFG'],
			guiInline = true,
			args = {
				Role = {
					type = "multiselect",
					order = 1,
					name = XFG.Lib.Locale['LFG_ROLE'],
					values = {
						Tank = XFG.Icons.Tank,
						Healer = XFG.Icons.Healer,
						DPS = XFG.Icons.DPS
                    },
					get = function(info, k) return XFG.Config.LFG.Role[k] end,
					set = function(info, k, v)                      
						XFG.Config.LFG.Role[k] = v
					end,
				},
				Activity = {
					type = "multiselect",
					order = 2,
					name = XFG.Lib.Locale['LFG_ACTIVITY'],
					values = {
                    --Ace spits out order based on property name descending, these are in desired order
						RA = XFG.Lib.Locale['LFG_RAID_NORMAL'],
						RH = XFG.Lib.Locale['LFG_RAID_HEROIC'],
						RM = XFG.Lib.Locale['LFG_RAID_MYTHIC'],
						SM = XFG.Lib.Locale['LFG_MYTHIC_PLUS'], 
                        SP = XFG.Lib.Locale['LFG_PVP'],
						SS = XFG.Lib.Locale['LFG_SOCIAL'],
						TW = XFG.Lib.Locale['LFG_TIMEWALKING'],
                    },
					get = function(info, k) return XFG.Config.LFG.Activity[k] end,
					set = function(info, k, v)
						XFG.Config.LFG.Activity[k] = v
					end,
				},
			}
		}
	}
}