local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.General'
local RealmXref = {}
local Initialized = false

--#region Popup Window
StaticPopupDialogs["LINKS"] = {
	text = XFG.Title,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}
--#endregion

--#region Initialization
function XFG:SetupRealms()

	XFG.Cache.Setup = {
		Confederate = {},
		Realms = {},
		Teams = {},
		Guilds = {},
		GuildsRealms = {},
		Compress = true,
	}
	
	XFG.Options.args.General.args.Setup.args.Realms.args.Bar.name = format("|cffffffff%s %s|r", XFG.Lib.Locale['REGION'], XFG.Regions:GetCurrent():GetName())
	for _, realm in XFG.Realms:SortedIterator() do
		table.insert(XFG.Cache.Setup.Realms, {
			id = realm:GetID(),
			name = realm:GetName(),
			connections = {},
			enabled = realm:IsTargeted() or realm:IsCurrent(),
		})
		RealmXref[realm:GetName()] = #XFG.Cache.Setup.Realms
		for _, connectedRealm in realm:ConnectedIterator() do
			table.insert(XFG.Cache.Setup.Realms[#XFG.Cache.Setup.Realms].connections, connectedRealm:GetName())
		end
	end

	for i, realm in ipairs(XFG.Cache.Setup.Realms) do
		XFG.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)] = {
			type = 'toggle',
			order = i + 2,
            name = realm.name,
			desc = '',
            get = function(info) return XFG.Cache.Setup.Realms[i].enabled end,
            set = function(info, value)
				XFG.Cache.Setup.Realms[i].enabled = value
				if(XFG.Cache.Setup.Realms[i].enabled) then
					XFG.Cache.Setup.GuildsRealms[tostring(realm.id)] = realm.name
				else
					XFG.Cache.Setup.GuildsRealms[tostring(realm.id)] = nil
				end
				for _, connectedRealm in ipairs(XFG.Cache.Setup.Realms[i].connections) do
					connectedRealm = XFG.Cache.Setup.Realms[RealmXref[connectedRealm]]
					connectedRealm.enabled = value
					if(connectedRealm.enabled) then
						XFG.Cache.Setup.GuildsRealms[tostring(connectedRealm.id)] = connectedRealm.name
					else
						XFG.Cache.Setup.GuildsRealms[tostring(connectedRealm.id)] = nil
					end
				end
			end
		}
		for j, connectedRealm in ipairs(XFG.Cache.Setup.Realms[i].connections) do
			connectedRealm = XFG.Cache.Setup.Realms[RealmXref[connectedRealm]]
			XFG.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc = 
			XFG.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc .. 
			XFG.Lib.Locale['SETUP_REALMS_CONNECTED'] .. connectedRealm.name
			if(j ~= #XFG.Cache.Setup.Realms[i].connections) then 
				XFG.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc = 
				XFG.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc .. '\n'
			end
		end
	end
end

function XFG:SetupMenus()
	
	if(not Initialized) then
		if(XFG.Versions:GetCurrent():IsAlpha()) then
			XFG.Options.args.General.args.Bar.name = XFG.Options.args.General.args.Bar.name .. ' |cffFF4700Alpha|r'
		elseif(XFG.Versions:GetCurrent():IsBeta()) then
			XFG.Options.args.General.args.Bar.name = XFG.Options.args.General.args.Bar.name .. ' |cffFF7C0ABeta|r'
		end

		--#region Confederate Menu
		XFG.Cache.Setup.Confederate.Initials = XFG.Confederate:GetInitials()
		XFG.Cache.Setup.Confederate.Name = XFG.Confederate:GetName()
		XFG.Cache.Setup.Confederate.ChannelName = XFG.Cache.Channel.Name
		XFG.Cache.Setup.Confederate.Password = XFG.Cache.Channel.Password
		--#endregion

		--#region Guild Menu
		if(XFG.Guilds:GetCount() > 0) then
			for _, guild in XFG.Guilds:SortedIterator() do
				table.insert(XFG.Cache.Setup.Guilds, {
					realm = tostring(guild:GetRealm():GetID()),
					faction = guild:GetFaction():GetID(),
					initials = guild:GetInitials(),
					name = guild:GetName(),
				})
				XFG.Cache.Setup.GuildsRealms[tostring(guild:GetRealm():GetID())] = guild:GetRealm():GetName()
			end
		end

		local i = #XFG.Cache.Setup.Guilds
		while i < XFG.Settings.Setup.MaxGuilds do
			table.insert(XFG.Cache.Setup.Guilds, {
				realm = nil,
				faction = nil,
				initials = nil,
				name = nil,
			})
			i = i + 1
		end

		for i, guild in ipairs(XFG.Cache.Setup.Guilds) do
			XFG.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i)] = {
				type = 'select',
				order = 4 * i,
				name = XFG.Lib.Locale['FACTION'],
				width = 'half',
				values = {
					A = XFG.Lib.Locale['ALLIANCE'],
					H = XFG.Lib.Locale['HORDE'],
				},
				get = function(info) return XFG.Cache.Setup.Guilds[i].faction end,
				set = function(info, value) XFG.Cache.Setup.Guilds[i].faction = value	end
			}
			XFG.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i + 1)] = {
				type = 'select',
				order = 4 * i + 1,
				name = XFG.Lib.Locale['REALM'],
				values = XFG.Cache.Setup.GuildsRealms,
				get = function(info) return XFG.Cache.Setup.Guilds[i].realm end,
				set = function(info, value) XFG.Cache.Setup.Guilds[i].realm = value	end
			}		
			XFG.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i + 2)] = {
				type = 'input',
				order = 4 * i + 2,
				name = XFG.Lib.Locale['INITIALS'],
				width = 'half',
				get = function(info) return XFG.Cache.Setup.Guilds[i].initials end,
				set = function(info, value)
					XFG.Cache.Setup.Guilds[i].initials = value
				end
			}
			XFG.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i + 3)] = {
				type = 'input',
				order = 4 * i + 3,
				name = XFG.Lib.Locale['NAME'],
				width = 'fill',
				get = function(info) return XFG.Cache.Setup.Guilds[i].name end,
				set = function(info, value)
					XFG.Cache.Setup.Guilds[i].name = value
				end
			}
		end
		--#endregion

		--#region Team Menu
		if(XFG.Teams:GetCount() > 0) then
			for _, team in XFG.Teams:SortedIterator() do
				if(team:GetInitials() ~= '?') then
					table.insert(XFG.Cache.Setup.Teams, {
						initials = team:GetInitials(),
						name = team:GetName(),
					})
				end
			end
		end

		local i = #XFG.Cache.Setup.Teams
		while i < XFG.Settings.Setup.MaxTeams do
			table.insert(XFG.Cache.Setup.Teams, {
				initials = nil,
				name = nil,
			})
			i = i + 1
		end

		for i, team in ipairs(XFG.Cache.Setup.Teams) do
			XFG.Options.args.General.args.Setup.args.Teams.args[tostring(2 * i)] = {
				type = 'input',
				order = 2 * i,
				name = 'Initials',
				width = "half",
				get = function(info) return XFG.Cache.Setup.Teams[i].initials end,
				set = function(info, value)
					XFG.Cache.Setup.Teams[i].initials = value
				end
			}
			XFG.Options.args.General.args.Setup.args.Teams.args[tostring(2 * i + 1)] = {
				type = 'input',
				order = 2 * i + 1,
				name = 'Name',
				width = "fill",
				get = function(info) return XFG.Cache.Setup.Teams[i].name end,
				set = function(info, value)
					XFG.Cache.Setup.Teams[i].name = value
				end
			}
		end
		--#endregion
		Initialized = true
	end
end

local function GenerateConfig()
	local config = 'XFn:' .. XFG.Cache.Setup.Confederate.Name .. ':' .. XFG.Cache.Setup.Confederate.Initials .. '\n' ..
				   'XFc:' .. XFG.Cache.Setup.Confederate.ChannelName .. ':' .. XFG.Cache.Setup.Confederate.Password .. '\n'

	for i, guild in ipairs(XFG.Cache.Setup.Guilds) do
		if(guild.name ~= nil and guild.initials ~= nil) then
			config = config .. 'XFg:' .. guild.realm .. ':' .. guild.faction .. ':' .. guild.name .. ':' .. guild.initials .. '\n'
		end
	end
	for i, team in ipairs(XFG.Cache.Setup.Teams) do
		if(team.name ~= nil and team.initials ~= nil) then
			config = config .. 'XFt:' .. team.initials .. ':' .. team.name .. '\n'
		end
	end
	if(XFG.Cache.Setup.Compress) then
		return 'XF:' .. XFG.Lib.Deflate:EncodeForPrint(XFG.Lib.Deflate:CompressDeflate(config, {level = 9})) .. ':XF'
	end
	return config
end

local function MultipleGuildsOnTarget()
	local targets = {}
	for i, guild in ipairs(XFG.Cache.Setup.Guilds) do
		if(guild.realm ~= nil and guild.faction ~= nil) then
			local target = guild.realm .. guild.faction
			if(targets[target]) then
				return true
			else
				targets[target] = true
			end
		end
	end
	return false
end
--#endregion

XFG.Options = {
	name = XFG.Name,
	order = 1,
	type = 'group',
	args = {
		General = {
			name = XFG.Lib.Locale['GENERAL'],
			order = 3,
			type = 'group',
			childGroups = 'tab',
			args = {
				Logo = {
					order = 1,
					type = 'description',
					name = '',
					fontSize = 'medium',
					image = function() return 'Interface\\AddOns\\XFaction\\Media\\Images\\XFACTION-Logo.tga', 384, 96 end,
				},
				Bar = {
					order = 2,
					name = format("|cffffffff%s|r", type(XFG.Version) == 'string' and XFG.Version or XFG.Version:GetKey()),
					type = 'header'
				},
				About = {
					order = 3,
					type = 'group',
					name = XFG.Lib.Locale['ABOUT'],
					childGroups = 'tab',
					args = {							
						Header = {
							order = 1,
							type = 'group',
							name = XFG.Lib.Locale['DESCRIPTION'],
							guiInline = true,
							args = {
								Description = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DESCRIPTION'],
								},
							}
						},
						FeaturesHeader = {
							order = 2,
							type = 'header',
							name = XFG.Lib.Locale['GENERAL_CONFIGURATION'],
						},
						Communication = {
							order = 3,
							type = 'group',
							name = XFG.Lib.Locale['COMMUNICATION'],
							args = {
								Chat = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_GUILD_CHAT']
								},
								Achievements = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_GUILD_CHAT_ACHIEVEMENT']
								},
								Login = {
									order = 3,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_SYSTEM_LOGIN']
								},
							},
						},
						Roster = {
							order = 4,
							type = 'group',
							name = XFG.Lib.Locale['ROSTER'],
							args = {
								GuildX = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTGUILD']
								},
							},
						},
						Addons = {
							order = 5,
							type = 'group',
							name = XFG.Lib.Locale['ADDONS'],
							args = {
								ElvUI = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['ADDON_ELVUI_DESCRIPTION']
								},
								Kui = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION']
								},
								RaiderIO = {
									order = 3,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['ADDON_RAIDERIO']
								},	
								WIM = {
									order = 4,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['ADDON_WIM_DESCRIPTION']
								},
							},
						},
						Metrics = {
							order = 6,
							type = 'group',
							name = XFG.Lib.Locale['METRICS'],
							args = {
								LinksX = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTLINKS']
								},
								MetricsX = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTMETRICS']
								},
							},
						},
					},
				},
				Setup = {
					name = XFG.Lib.Locale['SETUP'],
					order = 4,
					type = 'group',
					childGroups = 'tab',
					args = {
						Instructions = {
							order = 1,
							type = 'group',
							name = XFG.Lib.Locale['HOW_TO'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XFG.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XFG.Lib.Locale['SETUP_HOW_TO_INSTRUCTIONS'],
										},
									}
								},
							}
						},						
						Realms = {
							order = 2,
							type = 'group',
							name = XFG.Lib.Locale['REALMS'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XFG.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XFG.Lib.Locale['SETUP_REALMS_INSTRUCTIONS'],
										},
									}
								},
								Bar = {
									order = 2,
									name = '',
									type = 'header'
								},
							},
						},
						Guilds = {
							order = 3,
							type = 'group',
							name = XFG.Lib.Locale['GUILDS'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XFG.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XFG.Lib.Locale['SETUP_GUILDS_INSTRUCTIONS'],
										},
									}
								},
							},
						},
						Teams = {
							order = 4,
							type = 'group',
							name = XFG.Lib.Locale['TEAMS'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XFG.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XFG.Lib.Locale['SETUP_TEAMS_INSTRUCTIONS'],
										},
									}
								},				
							},
						},
						Confederate = {
							order = 5,
							type = 'group',
							name = XFG.Lib.Locale['CONFEDERATE'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XFG.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XFG.Lib.Locale['SETUP_CONFEDERATE_INSTRUCTIONS'],
										},
									}
								},
								Initials = {
									order = 2,
									type = 'input',
									name = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
									get = function(info) return XFG.Cache.Setup.Confederate.Initials end,
									set = function(info, value) XFG.Cache.Setup.Confederate.Initials = value end,
								},
								Name = {
									order = 3,
									type = 'input',
									name = XFG.Lib.Locale['CONFEDERATE_NAME'],
									get = function(info) return XFG.Cache.Setup.Confederate.Name end,
									set = function(info, value) XFG.Cache.Setup.Confederate.Name = value end,
								},
								Space = {
									order = 4,
									type = 'description',
									name = '',
								},
								Channel = {
									order = 5,
									type = 'input',
									name = XFG.Lib.Locale['CHANNEL_NAME'],
									get = function(info) return XFG.Cache.Setup.Confederate.ChannelName end,
									set = function(info, value) XFG.Cache.Setup.Confederate.ChannelName = value end,
									hidden = function () return not MultipleGuildsOnTarget() end,
								},
								Password = {
									order = 6,
									type = 'input',
									name = XFG.Lib.Locale['CHANNEL_PASSWORD'],
									get = function(info) return XFG.Cache.Setup.Confederate.Password end,
									set = function(info, value) XFG.Cache.Setup.Confederate.Password = value end,
									hidden = function () return not MultipleGuildsOnTarget() end,
								},
							}
						},
						Generate = {
							order = 6,
							type = 'group',
							name = 'Generate',
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XFG.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XFG.Lib.Locale['SETUP_GENERATE_INSTRUCTIONS'],
										},
									}
								},
								Compress = {
									order = 3,
									type = 'toggle',
									name = XFG.Lib.Locale['COMPRESS'],
									desc = XFG.Lib.Locale['SETUP_GENERATE_TOOLTIP'],
									get = function(info) return XFG.Cache.Setup.Compress end,
									set = function(info, value) XFG.Cache.Setup.Compress = value end,
								},
								Generate = {
									type = 'execute',
									order = 2,
									name = XFG.Lib.Locale['CONFEDERATE_GENERATE'],
									width = '2',
									func = function(info)
										XFG.Cache.Setup.Output = GenerateConfig(XFG.Cache.Setup.Output)
										LibStub('AceConfigRegistry-3.0'):NotifyChange('Output')
										XFG.Options.args.General.args.Setup.args.Generate.args.Output.desc = string.len(XFG.Cache.Setup.Output) .. XFG.Lib.Locale['SETUP_CHARACTERS']
									end
								},
								Output = {
									type = 'input',
									order = 4,
									name = XFG.Lib.Locale['GUILD_INFO'],
									width = 'full',
									multiline = 10,
									get = function(info) return XFG.Cache.Setup[ info[#info] ] end,
									set = function(info, value) XFG.Cache.Setup[ info[#info] ] = value; end
								},
							},
						},
					}
				},
				Support = {
					order = 5,
					type = 'group',
					name = XFG.Lib.Locale['SUPPORT'],
					args = {
						Resources = {
							order = 2,
							type = 'group',
							name = XFG.Lib.Locale['RESOURCES'],
							guiInline = true,
							args = {
								FAQ = {
									order = 1,
									type = 'execute',
									name = XFG.Lib.Locale['FAQ'],
									func = function() StaticPopup_Show("LINKS", nil, nil, 'https://github.com/Chalsean/XFaction/wiki/FAQ') end,
								},
								Discord = {
									order = 2,
									type = 'execute',
									name = XFG.Lib.Locale['DISCORD'],
									func = function() StaticPopup_Show("LINKS", nil, nil, 'https://discord.gg/eternalkingdom') end,
								},
								Git = {
									order = 3,
									type = 'execute',
									name = XFG.Lib.Locale['GITHUB'],
									func = function() StaticPopup_Show("LINKS", nil, nil, 'https://github.com/Chalsean/XFaction') end,
								},					
							}
						},
						Development = {
							order = 3,
							type = 'group',
							name = XFG.Lib.Locale['DEV'],
							guiInline = true,
							args = {
								Development = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = 'Chalsean (US-Proudmoore)',
								},
							}
						},		
						Graphics = {
							order = 4,
							type = 'group',
							name = XFG.Lib.Locale['GRAPHICS'],
							guiInline = true,
							args = {
								PM = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = 'Purpformance (US-Proudmoore)',
								},
							}
						},
						PM = {
							order = 5,
							type = 'group',
							name = XFG.Lib.Locale['PM'],
							guiInline = true,
							args = {
								PM = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = 'Rysal (US-Proudmoore)',
								},
							}
						},
					},
				},
				Debug = {
					name = XFG.Lib.Locale['DEBUG'],
					order = 6,
					type = 'group',
					args = {
						Logging = {
							order = 1,
							type = 'group',
							name = XFG.Lib.Locale['DEBUG_LOG'],
							guiInline = true,
							args = {
								Verbosity = {
									order = 1,
									type = 'range',
									name = XFG.Lib.Locale['VERBOSITY'],
									desc = XFG.Lib.Locale['DEBUG_VERBOSITY_TOOLTIP'],
									min = 0, max = 5, step = 1,
									get = function(info) return XFG.Config.Debug.Verbosity end,
									set = function(info, value) 
										XFG.Config.Debug.Verbosity = value
										XFG.Verbosity = value
									end,
								},
							},
						},
						Print = {
							order = 2,
							type = 'group',
							name = XFG.Lib.Locale['DEBUG_PRINT'],
							guiInline = true,
							args = {
								Channel = {
									order = 1,
									name = XFG.Lib.Locale['CHANNEL'],
									type = 'execute',
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function() XFG.Channels:Print() end,
								},
								Class = {
									order = 2,
									type = 'execute',
									name = XFG.Lib.Locale['CLASS'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function() XFG.Classes:Print() end,
								},
								Confederate = {
									order = 3,
									type = 'execute',
									name = XFG.Lib.Locale['CONFEDERATE'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Confederate:Print() end,
								},
								Continent = {
									order = 4,
									type = 'execute',
									name = XFG.Lib.Locale['CONTINENT'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Continents:Print() end,
								},
								Event = {
									order = 6,
									type = 'execute',
									name = XFG.Lib.Locale['EVENT'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Events:Print() end,
								},
								Faction = {
									order = 7,
									type = 'execute',
									name = XFG.Lib.Locale['FACTION'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Factions:Print() end,
								},
								Friend = {
									order = 14,
									type = 'execute',
									name = XFG.Lib.Locale['FRIEND'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Friends:Print() end,
								},
								Guild = {
									order = 15,
									type = 'execute',
									name = XFG.Lib.Locale['GUILD'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Guilds:Print() end,
								},
								Link = {
									order = 16,
									type = 'execute',
									name = XFG.Lib.Locale['LINK'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Links:Print() end,
								},
								Node = {
									order = 17,
									type = 'execute',
									name = XFG.Lib.Locale['NODE'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Nodes:Print() end,
								},
								Player = {
									order = 18,
									type = 'execute',
									name = XFG.Lib.Locale['PLAYER'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Player.Unit:Print() end,
								},
								Profession = {
									order = 19,
									type = 'execute',
									name = 	XFG.Lib.Locale['PROFESSION'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Professions:Print() end,
								},
								Race = {
									order = 20,
									type = 'execute',
									name = XFG.Lib.Locale['RACE'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Races:Print() end,
								},
								RaiderIO = {
									order = 21,
									type = 'execute',
									name = XFG.Lib.Locale['RAIDERIO'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Addons.RaiderIO:Print() end,					
								},
								Realm = {
									order = 22,
									type = 'execute',
									name = XFG.Lib.Locale['REALM'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Realms:Print() end,
								},				
								Spec = {
									order = 24,
									type = 'execute',
									name = XFG.Lib.Locale['SPEC'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Specs:Print() end,
								},
								Target = {
									order = 25,
									type = 'execute',
									name = XFG.Lib.Locale['TARGET'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Targets:Print() end,
								},
								Team = {
									order = 26,
									type = 'execute',
									name = XFG.Lib.Locale['TEAM'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Teams:Print() end,
								},
								Timer = {
									order = 27,
									type = 'execute',
									name = XFG.Lib.Locale['TIMER'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Timers:Print() end,
								},
								Zone = {
									order = 28,
									type = 'execute',
									name = XFG.Lib.Locale['ZONE'],
									disabled = function () return XFG.Config.Debug.Verbosity == 0 end,
									func = function(info) XFG.Zones:Print() end,
								},
							},
						},
					},
				},
				ChangeLog = {
					order = 7,
					type = 'group',
					childGroups = 'tree',
					name = XFG.Lib.Locale['CHANGE_LOG'],
					args = {	

					},
				},
			}
		},
	}
}

function XFG:ConfigInitialize()
	-- Get AceDB up and running as early as possible, its not available until addon is loaded
	XFG.ConfigDB = LibStub('AceDB-3.0'):New('XFactionDB', XFG.Defaults, true)
	XFG.Config = XFG.ConfigDB.profile

	-- Cache it because on shutdown, XFG.Config gets unloaded while we're still logging
	XFG.Verbosity = XFG.Config.Debug.Verbosity

	XFG.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XFG.ConfigDB)
	XFG.Lib.Config:RegisterOptionsTable(XFG.Name, XFG.Options, nil)
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, XFG.Name, nil, 'General')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Addons', XFG.Name, 'Addons')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Chat', XFG.Name, 'Chat')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'DataText', XFG.Name, 'DataText')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Profile', XFG.Name, 'Profile')

	XFG.ConfigDB.RegisterCallback(XFG, 'OnProfileChanged', 'InitProfile')
	XFG.ConfigDB.RegisterCallback(XFG, 'OnProfileCopied', 'InitProfile')
	XFG.ConfigDB.RegisterCallback(XFG, 'OnProfileReset', 'InitProfile')

	XFG:SetupRealms()

	--#region Changelog
	try(function ()
		for versionKey, config in pairs(XFG.ChangeLog) do
			XFG.Versions:AddVersion(versionKey)
			XFG.Versions:Get(versionKey):IsInChangeLog(true)
		end

		local minorOrder = 0
		local patchOrder = 0
		for _, version in XFG.Versions:ReverseSortedIterator() do
			if(version:IsInChangeLog()) then
				local minorVersion = version:GetMajor() .. '.' .. version:GetMinor()
				if(XFG.Options.args.General.args.ChangeLog.args[minorVersion] == nil) then
					minorOrder = minorOrder + 1
					patchOrder = 0
					XFG.Options.args.General.args.ChangeLog.args[minorVersion] = {
						order = minorOrder,
						type = 'group',
						childGroups = 'tree',
						name = minorVersion,
						args = {},
					}
				end
				patchOrder = patchOrder + 1
				XFG.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()] = {
					order = patchOrder,
					type = 'group',
					name = version:GetKey(),
					desc = 'Major: ' .. version:GetMajor() .. '\nMinor: ' .. version:GetMinor() .. '\nPatch: ' .. version:GetPatch(),
					args = XFG.ChangeLog[version:GetKey()],
				}
				if(version:IsAlpha()) then
					XFG.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()].name = version:GetKey() .. ' |cffFF4700Alpha|r'
				elseif(version:IsBeta()) then
					XFG.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()].name = version:GetKey() .. ' |cffFF7C0ABeta|r'
				end
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Debug(ObjectName, inErrorMessage)
	end)
	--#endregion

	XFG:Info(ObjectName, 'Configs loaded')
end

function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.ConfigDB.profile
end