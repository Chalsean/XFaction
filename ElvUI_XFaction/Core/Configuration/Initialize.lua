local XFG, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')

function XFG:InitializeConfig()
	E.Options.args.xfaction = {
		name = XFG.Title,
		order = 6,
		type = 'group',
		childGroups = 'tree',
		args = {
			title = {
				order = 1,
				name = XFG.Title,
				type = 'header'
			},
			general = {
				order = 2,
				name = 'General',
				type = 'group',
				get = function(info) return XFG.Config[ info[#info] ] end,
				set = function(info, value) XFG.Config[ info[#info] ] = value; end,
				childGroups = 'tab',
				args = {
					realms = {
						order = 2,
						name = 'Realms',
						type = 'group',
						guiInline = true,
						args = {}
					}
				}
			},
			communications = {
				order = 3,
				name = 'Communications',
				type = 'group',				
				get = function(info) return XFG.Config[ info[#info] ] end,
				set = function(info, value) XFG.Config[ info[#info] ] = value; end,
				args = {
					bnet = {
						order = 2,
						type = 'group',
						name = 'Battle.Net',
						guiInline = true,
						args = {
							enable = {
								order = 1,
								type = 'toggle',
								name = 'Enable',
								desc = 'Enable/Disable BNet bridging to communicate with other servers/faction',
								get = function(info) return XFG.Config[ info[#info] ] end,
								set = function(info, value) XFG.Config[ info[#info] ] = value; end
							}
						}
					}
				}
			},
			datatexts = {
				order = 4,
				name = 'DataTexts',
				type = 'group',
				get = function(info) return XFG.Config[ info[#info] ] end,
				set = function(info, value) XFG.Config[ info[#info] ] = value; end,
				childGroups = 'tab',
				args = {}
			}
		}
	}
end
--tinsert(XFG.Config, Core)