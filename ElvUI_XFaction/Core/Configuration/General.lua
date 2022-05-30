local XFG, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS');
local tinsert = table.insert

-- local colorValues = {
-- 	[1] = L.CLASS_COLORS,
-- 	[2] = CUSTOM,
-- 	[3] = L['Value Color'],
-- 	[4] = DEFAULT,
-- 	[5] = L['Covenant Color']
-- }

local function BuildBaseDTOption(name)
	return {
		order = 1,
		name = L[name],
		type = 'group',
		inline = false,
		get = function(info) return E.db.xfaction.datatexts[strlower(name)][info[#info]] end,
		set = function(info, value) E.db.xfaction.datatexts[strlower(name)][info[#info]] = value DT:ForceUpdate_DataText(name) end,
		args = {}
	}
end

function XFG:GeneralSetup()
	local ACH = E.Libs.ACH
	local version = 'v0.1'--format('|cff1784d1v%s|r', GetAddOnMetadata(XFG.Addon, 'Version'))

	E.Options.args.xfaction = {
		name = XFG.Title,
		order = 6,
		type = 'group',
		childGroups = "tab",
		args = {
			title = {
				order = 1,
				name = format('|cff1784d1ElvUI|r_|cffFF4700X|rcFFffffffFaction|r [%s] by |cfffc7f03Chalsean (US-Proudmoore)|r', version),
				type = 'header'
			},
			datatexts = {
				order = 2,
				name = L["DataText Customization"],
				type = 'group',
				childGroups = 'tree',
				args = {}
			}
		}
	}

	local opts = E.Options.args.xfaction.args.datatexts.args

	opts.guild = BuildBaseDTOption('Guild')

	opts.guild.args = {
				showContinent = {
					order = 1,
					name = 'Show Continent',
					type = 'toggle'
				},
				showZone = {
					order = 2,
					name = 'Show Zone',
					type = 'toggle'
				},
				showSubZone = {
					order = 3,
					name = 'Show Sub Zone',
					type = 'toggle'
				},
				space1 = ACH:Spacer(5),
				color = {
					order = 6,
					name = 'Text Coloring',
					type = 'select',
					sortByValue = false,
					values = {
						['REACTION'] = 'Reaction',
						['CLASS'] = 'Class',
						['CUSTOM'] = 'Custom'
					}
				},
				space1 = ACH:Spacer(10),
				disableBlizzZoneText = {
					order = 11,
					name = 'Disable Blizzard Zone Text',
					type = 'toggle',
					set = function(_, value) E.db.xfaction.datatexts.location.disableBlizzZoneText = value E:StaticPopup_Show('CONFIG_RL') end
				}
	}
end
--tinsert(XFG.Config, Core)