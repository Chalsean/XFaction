local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Config.General'
local RealmXref = {}
local Initialized = false

--#region Popup Window
StaticPopupDialogs["LINKS"] = {
	text = XF.Title,
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
function XF:SetupRealms()

	XF.Cache.Setup = {
		Confederate = {},
		Realms = {},
		Teams = {},
		Guilds = {},
		GuildsRealms = {},
		Compress = true,
	}
	
	XF.Options.args.General.args.Setup.args.Realms.args.Bar.name = format("|cffffffff%s %s|r", XF.Lib.Locale['REGION'], XFO.Regions:GetCurrent():GetName())
	for _, realm in XFO.Realms:SortedIterator() do
		table.insert(XF.Cache.Setup.Realms, {
			id = realm:GetID(),
			name = realm:GetName(),
			connections = {},
			enabled = realm:IsTargeted() or realm:IsCurrent(),
		})
		RealmXref[realm:GetName()] = XF.Cache.Setup.Realms[#XF.Cache.Setup.Realms]
		RealmXref[realm:GetID()] = XF.Cache.Setup.Realms[#XF.Cache.Setup.Realms]
		for _, connectedRealm in realm:ConnectedIterator() do
			table.insert(XF.Cache.Setup.Realms[#XF.Cache.Setup.Realms].connections, connectedRealm:GetName())
		end
	end

	for i, realm in ipairs(XF.Cache.Setup.Realms) do
		XF.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)] = {
			type = 'toggle',
			order = i + 2,
            name = realm.name,
			desc = '',
            get = function(info) return XF.Cache.Setup.Realms[i].enabled end,
            set = function(info, value)
				XF.Cache.Setup.Realms[i].enabled = value
				if(XF.Cache.Setup.Realms[i].enabled) then
					XF.Cache.Setup.GuildsRealms[tostring(realm.id)] = realm.name
				else
					XF.Cache.Setup.GuildsRealms[tostring(realm.id)] = nil
				end
				for _, connectedRealm in ipairs(XF.Cache.Setup.Realms[i].connections) do
					connectedRealm = RealmXref[connectedRealm]
					connectedRealm.enabled = value
					if(connectedRealm.enabled) then
						XF.Cache.Setup.GuildsRealms[tostring(connectedRealm.id)] = connectedRealm.name
					else
						XF.Cache.Setup.GuildsRealms[tostring(connectedRealm.id)] = nil
					end
				end
			end
		}
		for j, connectedRealm in ipairs(XF.Cache.Setup.Realms[i].connections) do
			connectedRealm = RealmXref[connectedRealm]
			XF.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc = 
			XF.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc .. 
			XF.Lib.Locale['SETUP_REALMS_CONNECTED'] .. connectedRealm.name
			if(j ~= #XF.Cache.Setup.Realms[i].connections) then 
				XF.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc = 
				XF.Options.args.General.args.Setup.args.Realms.args[tostring(i + 2)].desc .. '\n'
			end
		end
	end
end

function XF:SetupMenus()
	
	if(not Initialized) then
		if(XFO.Versions:GetCurrent():IsAlpha()) then
			XF.Options.args.General.args.Bar.name = XF.Options.args.General.args.Bar.name .. ' |cffFF4700Alpha|r'
		elseif(XFO.Versions:GetCurrent():IsBeta()) then
			XF.Options.args.General.args.Bar.name = XF.Options.args.General.args.Bar.name .. ' |cffFF7C0ABeta|r'
		end

		--#region Confederate Menu
		XF.Cache.Setup.Confederate.Initials = XFO.Confederate:GetInitials()
		XF.Cache.Setup.Confederate.Name = XFO.Confederate:GetName()
		XF.Cache.Setup.Confederate.ChannelName = XF.Cache.Channel.Name
		XF.Cache.Setup.Confederate.Password = XF.Cache.Channel.Password
		--#endregion

		--#region Guild Menu
		if(XFO.Guilds:GetCount() > 0) then
			for _, guild in XFO.Guilds:SortedIterator() do
				table.insert(XF.Cache.Setup.Guilds, {
					realm = tostring(guild:GetRealm():GetID()),
					--faction = guild:GetFaction():GetID(),
					initials = guild:GetInitials(),
					name = guild:GetName(),
				})
				XF.Cache.Setup.GuildsRealms[tostring(guild:GetRealm():GetID())] = guild:GetRealm():GetName()
			end
		end

		local i = #XF.Cache.Setup.Guilds
		while i < XF.Settings.Setup.MaxGuilds do
			table.insert(XF.Cache.Setup.Guilds, {
				realm = nil,
				--faction = nil,
				initials = nil,
				name = nil,
			})
			i = i + 1
		end

		for i, guild in ipairs(XF.Cache.Setup.Guilds) do
			XF.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i)] = {
				type = 'select',
				order = 4 * i,
				name = XF.Lib.Locale['FACTION'],
				width = 'half',
				values = {
					A = XF.Lib.Locale['ALLIANCE'],
					H = XF.Lib.Locale['HORDE'],
				},
				get = function(info) return XF.Cache.Setup.Guilds[i].faction end,
				set = function(info, value) XF.Cache.Setup.Guilds[i].faction = value end,
			}
			XF.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i + 1)] = {
				type = 'select',
				order = 4 * i + 1,
				name = XF.Lib.Locale['REALM'],
				values = XF.Cache.Setup.GuildsRealms,
				get = function(info) return XF.Cache.Setup.Guilds[i].realm end,
				set = function(info, value) XF.Cache.Setup.Guilds[i].realm = value	end,
			}		
			XF.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i + 2)] = {
				type = 'input',
				order = 4 * i + 2,
				name = XF.Lib.Locale['INITIALS'],
				width = 'half',
				get = function(info) return XF.Cache.Setup.Guilds[i].initials end,
				set = function(info, value)
					if(string.len(value) > 0) then 
						XF.Cache.Setup.Guilds[i].initials = value
					else
						XF.Cache.Setup.Guilds[i].initials = nil
					end
				end,
			}
			XF.Options.args.General.args.Setup.args.Guilds.args[tostring(4 * i + 3)] = {
				type = 'input',
				order = 4 * i + 3,
				name = XF.Lib.Locale['NAME'],
				width = 'fill',
				get = function(info) return XF.Cache.Setup.Guilds[i].name end,
				set = function(info, value)
					if(string.len(value) > 0) then
						XF.Cache.Setup.Guilds[i].name = value
					else
						XF.Cache.Setup.Guilds[i].name = nil
					end
				end,
			}
		end
		--#endregion

		--#region Team Menu
		if(XFO.Teams:GetCount() > 0) then
			for _, team in XFO.Teams:SortedIterator() do
				if(team:GetInitials() ~= '?') then
					table.insert(XF.Cache.Setup.Teams, {
						initials = team:GetInitials(),
						name = team:GetName(),
					})
				end
			end
		end

		local i = #XF.Cache.Setup.Teams
		while i < XF.Settings.Setup.MaxTeams do
			table.insert(XF.Cache.Setup.Teams, {
				initials = nil,
				name = nil,
			})
			i = i + 1
		end

		for i, team in ipairs(XF.Cache.Setup.Teams) do
			XF.Options.args.General.args.Setup.args.Teams.args[tostring(2 * i)] = {
				type = 'input',
				order = 2 * i,
				name = 'Initials',
				width = "half",
				get = function(info) return XF.Cache.Setup.Teams[i].initials end,
				set = function(info, value)
					if(string.len(value)) then
						XF.Cache.Setup.Teams[i].initials = value
					else
						XF.Cache.Setup.Teams[i].initials = nil
					end
				end,
			}
			XF.Options.args.General.args.Setup.args.Teams.args[tostring(2 * i + 1)] = {
				type = 'input',
				order = 2 * i + 1,
				name = 'Name',
				width = "fill",
				get = function(info) return XF.Cache.Setup.Teams[i].name end,
				set = function(info, value)
					if(string.len(value)) then
						XF.Cache.Setup.Teams[i].name = value
					else
						XF.Cache.Setup.Teams[i].name = nil
					end
				end,
			}
		end
		--#endregion
		Initialized = true
	end
end

local function IsMultipleOnTarget()
	local targets = {}
	for i, guild in ipairs(XF.Cache.Setup.Guilds) do
		if(guild.initials ~= nil and guild.name ~= nil and guild.realm ~= nil and guild.faction ~= nil) then
			local target = guild.realm .. guild.faction
			if(targets[target]) then
				return true
			else
				targets[target] = true
			end
			if(RealmXref[tonumber(guild.realm)] ~= nil) then				
				for j, connection in ipairs(RealmXref[tonumber(guild.realm)].connections) do
					local target = RealmXref[connection].id .. guild.faction
					if(targets[target]) then
						return true
					else
						targets[target] = true
					end
				end
			end			
		end
	end
	return false
end

local function GenerateConfig()
	local config = 'XFn:' .. XF.Cache.Setup.Confederate.Name .. ':' .. XF.Cache.Setup.Confederate.Initials .. '\n' 
	if(IsMultipleOnTarget()) then
		config = config .. 'XFc:' .. XF.Cache.Setup.Confederate.ChannelName .. ':' .. XF.Cache.Setup.Confederate.Password .. '\n'
	end

	for i, guild in ipairs(XF.Cache.Setup.Guilds) do
		if(guild.initials ~= nil and string.len(guild.initials) and guild.name ~= nil and string.len(guild.name)) then
			config = config .. 'XFg:' .. guild.realm .. ':' .. guild.faction .. ':' .. guild.name .. ':' .. guild.initials .. '\n'
		end
	end
	for i, team in ipairs(XF.Cache.Setup.Teams) do
		if(team.name ~= nil and team.initials ~= nil) then
			config = config .. 'XFt:' .. team.initials .. ':' .. team.name .. '\n'
		end
	end
	if(XF.Cache.Setup.Compress) then
		return 'XF:' .. XF.Lib.Deflate:EncodeForPrint(XF.Lib.Deflate:CompressDeflate(config, {level = 9})) .. ':XF'
	end
	return config
end
--#endregion

XF.Options = {
	name = XF.Name,
	order = 1,
	type = 'group',
	args = {
		General = {
			name = XF.Lib.Locale['GENERAL'],
			order = 3,
			type = 'group',
			childGroups = 'tab',
			args = {
				Logo = {
					order = 1,
					type = 'description',
					name = '',
					fontSize = 'medium',
					image = function() return 'Interface\\AddOns\\XFaction\\Core\\System\\Media\\Images\\XFACTION-Logo.tga', 384, 96 end,
				},
				Bar = {
					order = 2,
					name = format("|cffffffff%s|r", XFO.Version and XFO.Version:GetKey() or XF.Version),
					type = 'header'
				},
				About = {
					order = 3,
					type = 'group',
					name = XF.Lib.Locale['ABOUT'],
					args = {							
						Header = {
							order = 1,
							type = 'group',
							name = XF.Lib.Locale['DESCRIPTION'],
							guiInline = true,
							args = {
								Description = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_DESCRIPTION'],
								},
							}
						},
						FeaturesHeader = {
							order = 2,
							type = 'header',
							name = XF.Lib.Locale['GENERAL_CONFIGURATION'],
						},
						Communication = {
							order = 3,
							type = 'group',
							name = XF.Lib.Locale['COMMUNICATION'],
							guiInline = true,
							args = {
								Chat = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_GUILD_CHAT']
								},
								Achievements = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_GUILD_CHAT_ACHIEVEMENT']
								},
								Login = {
									order = 3,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_SYSTEM_LOGIN']
								},
							},
						},
						Roster = {
							order = 4,
							type = 'group',
							name = XF.Lib.Locale['ROSTER'],
							guiInline = true,
							args = {
								GuildX = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_DTGUILD']
								},
							},
						},
						Addons = {
							order = 5,
							type = 'group',
							name = XF.Lib.Locale['ADDONS'],
							guiInline = true,
							args = {
								ElvUI = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['ADDON_ELVUI_DESCRIPTION']
								},
								Kui = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION']
								},
								RaiderIO = {
									order = 3,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['ADDON_RAIDERIO']
								},	
								WIM = {
									order = 4,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['ADDON_WIM_DESCRIPTION']
								},
							},
						},
						Metrics = {
							order = 6,
							type = 'group',
							name = XF.Lib.Locale['METRICS'],
							guiInline = true,
							args = {
								LinksX = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_DTLINKS']
								},
								MetricsX = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XF.Lib.Locale['GENERAL_DTMETRICS']
								},
							},
						},
					},
				},
				Setup = {
					name = XF.Lib.Locale['SETUP'],
					order = 4,
					type = 'group',
					childGroups = 'tab',
					args = {
						Instructions = {
							order = 1,
							type = 'group',
							name = XF.Lib.Locale['HOW_TO'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XF.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XF.Lib.Locale['SETUP_HOW_TO_INSTRUCTIONS'],
										},
									}
								},
							}
						},						
						Realms = {
							order = 2,
							type = 'group',
							name = XF.Lib.Locale['REALMS'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XF.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XF.Lib.Locale['SETUP_REALMS_INSTRUCTIONS'],
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
							name = XF.Lib.Locale['GUILDS'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XF.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XF.Lib.Locale['SETUP_GUILDS_INSTRUCTIONS'],
										},
									}
								},
							},
						},
						Teams = {
							order = 4,
							type = 'group',
							name = XF.Lib.Locale['TEAMS'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XF.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XF.Lib.Locale['SETUP_TEAMS_INSTRUCTIONS'],
										},
									}
								},				
							},
						},
						Confederate = {
							order = 5,
							type = 'group',
							name = XF.Lib.Locale['CONFEDERATE'],
							args = {
								Header = {
									order = 1,
									type = 'group',
									name = XF.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XF.Lib.Locale['SETUP_CONFEDERATE_INSTRUCTIONS'],
										},
									}
								},
								Initials = {
									order = 2,
									type = 'input',
									name = XF.Lib.Locale['CONFEDERATE_INITIALS'],
									get = function(info) return XF.Cache.Setup.Confederate.Initials end,
									set = function(info, value) XF.Cache.Setup.Confederate.Initials = value end,
								},
								Name = {
									order = 3,
									type = 'input',
									name = XF.Lib.Locale['CONFEDERATE_NAME'],
									get = function(info) return XF.Cache.Setup.Confederate.Name end,
									set = function(info, value) XF.Cache.Setup.Confederate.Name = value end,
								},
								Space = {
									order = 4,
									type = 'description',
									name = '',
								},
								Channel = {
									order = 5,
									type = 'input',
									name = XF.Lib.Locale['CHANNEL_NAME'],
									get = function(info) return XF.Cache.Setup.Confederate.ChannelName end,
									set = function(info, value) XF.Cache.Setup.Confederate.ChannelName = value end,
									hidden = function () return not IsMultipleOnTarget() end,
								},
								Password = {
									order = 6,
									type = 'input',
									name = XF.Lib.Locale['CHANNEL_PASSWORD'],
									get = function(info) return XF.Cache.Setup.Confederate.Password end,
									set = function(info, value) XF.Cache.Setup.Confederate.Password = value end,
									hidden = function () return not IsMultipleOnTarget() end,
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
									name = XF.Lib.Locale['INSTRUCTIONS'],
									inline = true,
									args = {
										Description = {
											order = 1,
											type = 'description',
											fontSize = 'medium',
											name = XF.Lib.Locale['SETUP_GENERATE_INSTRUCTIONS'],
										},
									}
								},
								Compress = {
									order = 3,
									type = 'toggle',
									name = XF.Lib.Locale['COMPRESS'],
									desc = XF.Lib.Locale['SETUP_GENERATE_TOOLTIP'],
									get = function(info) return XF.Cache.Setup.Compress end,
									set = function(info, value) XF.Cache.Setup.Compress = value end,
								},
								Generate = {
									type = 'execute',
									order = 2,
									name = XF.Lib.Locale['CONFEDERATE_GENERATE'],
									width = '2',
									func = function(info)
										XF.Cache.Setup.Output = GenerateConfig(XF.Cache.Setup.Output)
										LibStub('AceConfigRegistry-3.0'):NotifyChange('Output')
										XF.Options.args.General.args.Setup.args.Generate.args.Output.desc = string.len(XF.Cache.Setup.Output) .. XF.Lib.Locale['SETUP_CHARACTERS']
									end
								},
								Output = {
									type = 'input',
									order = 4,
									name = XF.Lib.Locale['GUILD_INFO'],
									width = 'full',
									multiline = 10,
									get = function(info) return XF.Cache.Setup[ info[#info] ] end,
									set = function(info, value) XF.Cache.Setup[ info[#info] ] = value; end
								},
							},
						},
					}
				},
				Support = {
					order = 5,
					type = 'group',
					name = XF.Lib.Locale['SUPPORT'],
					args = {
						Resources = {
							order = 2,
							type = 'group',
							name = XF.Lib.Locale['RESOURCES'],
							guiInline = true,
							args = {
								FAQ = {
									order = 1,
									type = 'execute',
									name = XF.Lib.Locale['FAQ'],
									func = function() StaticPopup_Show("LINKS", nil, nil, 'https://github.com/Chalsean/XFaction/wiki/FAQ') end,
								},
								Discord = {
									order = 2,
									type = 'execute',
									name = XF.Lib.Locale['DISCORD'],
									func = function() StaticPopup_Show("LINKS", nil, nil, 'https://discord.gg/eternalkingdom') end,
								},
								Git = {
									order = 3,
									type = 'execute',
									name = XF.Lib.Locale['GITHUB'],
									func = function() StaticPopup_Show("LINKS", nil, nil, 'https://github.com/Chalsean/XFaction') end,
								},					
							}
						},
						Development = {
							order = 3,
							type = 'group',
							name = XF.Lib.Locale['DEV'],
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
							name = XF.Lib.Locale['GRAPHICS'],
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
							name = XF.Lib.Locale['PM'],
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
					name = XF.Lib.Locale['DEBUG'],
					order = 6,
					type = 'group',
					args = {
						Logging = {
							order = 1,
							type = 'group',
							name = XF.Lib.Locale['DEBUG_LOG'],
							guiInline = true,
							args = {
								Verbosity = {
									order = 1,
									type = 'range',
									name = XF.Lib.Locale['VERBOSITY'],
									desc = XF.Lib.Locale['DEBUG_VERBOSITY_TOOLTIP'],
									min = 0, max = 5, step = 1,
									get = function(info) return XF.Config.Debug.Verbosity end,
									set = function(info, value) 
										XF.Config.Debug.Verbosity = value
										XF.Verbosity = value
									end,
								},
							},
						},
						Print = {
							order = 2,
							type = 'group',
							name = XF.Lib.Locale['DEBUG_PRINT'],
							guiInline = true,
							args = {
								Audit = {
									order = 1,
									name = XF.Lib.Locale['AUDIT'],
									type = 'execute',
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function() XF.Player.Unit:GetGuild():PrintAudit() end,
								},
								Channel = {
									order = 2,
									name = XF.Lib.Locale['CHANNEL'],
									type = 'execute',
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function() XFO.Channels:Print() end,
								},
								Class = {
									order = 3,
									type = 'execute',
									name = XF.Lib.Locale['CLASS'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function() XFO.Classes:Print() end,
								},
								Confederate = {
									order = 4,
									type = 'execute',
									name = XF.Lib.Locale['CONFEDERATE'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Confederate:Print() end,
								},
								Event = {
									order = 6,
									type = 'execute',
									name = XF.Lib.Locale['EVENT'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Events:Print() end,
								},
								Faction = {
									order = 7,
									type = 'execute',
									name = XF.Lib.Locale['FACTION'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Factions:Print() end,
								},
								Friend = {
									order = 14,
									type = 'execute',
									name = XF.Lib.Locale['FRIEND'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Friends:Print() end,
								},
								Guild = {
									order = 15,
									type = 'execute',
									name = XF.Lib.Locale['GUILD'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Guilds:Print() end,
								},
								Link = {
									order = 17,
									type = 'execute',
									name = XF.Lib.Locale['LINK'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Links:Print() end,
								},
								Node = {
									order = 18,
									type = 'execute',
									name = XF.Lib.Locale['NODE'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Nodes:Print() end,
								},
								Order = {
									order = 19,
									type = 'execute',
									name = XF.Lib.Locale['ORDER'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Orders:Print() end,
								},
								Player = {
									order = 20,
									type = 'execute',
									name = XF.Lib.Locale['PLAYER'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XF.Player.Unit:Print() end,
								},
								Profession = {
									order = 21,
									type = 'execute',
									name = 	XF.Lib.Locale['PROFESSION'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Professions:Print() end,
								},
								Race = {
									order = 22,
									type = 'execute',
									name = XF.Lib.Locale['RACE'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Races:Print() end,
								},
								RaiderIO = {
									order = 23,
									type = 'execute',
									name = XF.Lib.Locale['RAIDERIO'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XF.Addons.RaiderIO:Print() end,					
								},
								Realm = {
									order = 24,
									type = 'execute',
									name = XF.Lib.Locale['REALM'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Realms:Print() end,
								},				
								Spec = {
									order = 25,
									type = 'execute',
									name = XF.Lib.Locale['SPEC'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Specs:Print() end,
								},
								Target = {
									order = 26,
									type = 'execute',
									name = XF.Lib.Locale['TARGET'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Targets:Print() end,
								},
								Team = {
									order = 27,
									type = 'execute',
									name = XF.Lib.Locale['TEAM'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Teams:Print() end,
								},
								Timer = {
									order = 28,
									type = 'execute',
									name = XF.Lib.Locale['TIMER'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Timers:Print() end,
								},
								Zone = {
									order = 29,
									type = 'execute',
									name = XF.Lib.Locale['ZONE'],
									disabled = function () return XF.Config.Debug.Verbosity == 0 end,
									func = function(info) XFO.Zones:Print() end,
								},
							},
						},
					},
				},
				ChangeLog = {
					order = 7,
					type = 'group',
					childGroups = 'tree',
					name = XF.Lib.Locale['CHANGE_LOG'],
					args = {	

					},
				},
			}
		},
	}
}

function XF:ConfigInitialize()
	-- Get AceDB up and running as early as possible, its not available until addon is loaded
	XF.ConfigDB = LibStub('AceDB-3.0'):New('XFactionDB', XF.Defaults, true)
	XF.Config = XF.ConfigDB.profile

	-- Cache it because on shutdown, XF.Config gets unloaded while we're still logging
	XF.Verbosity = XF.Config.Debug.Verbosity

	XF.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XF.ConfigDB)
	XF.Lib.Config:RegisterOptionsTable(XF.Name, XF.Options, nil)
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, XF.Name, nil, 'General')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Addons', XF.Name, 'Addons')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Chat', XF.Name, 'Chat')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'DataText', XF.Name, 'DataText')
	XF.Lib.ConfigDialog:AddToBlizOptions(XF.Name, 'Profile', XF.Name, 'Profile')

	XF.ConfigDB.RegisterCallback(XF, 'OnProfileChanged', 'InitProfile')
	XF.ConfigDB.RegisterCallback(XF, 'OnProfileCopied', 'InitProfile')
	XF.ConfigDB.RegisterCallback(XF, 'OnProfileReset', 'InitProfile')

	XF:SetupRealms()

	--#region Changelog
	try(function ()
		for versionKey, config in pairs(XF.ChangeLog) do
			XFO.Versions:Add(versionKey)
			XFO.Versions:Get(versionKey):IsInChangeLog(true)
		end

		local minorOrder = 0
		local patchOrder = 0
		for _, version in XFO.Versions:ReverseSortedIterator() do
			if(version:IsInChangeLog()) then
				local minorVersion = version:GetMajor() .. '.' .. version:GetMinor()
				if(XF.Options.args.General.args.ChangeLog.args[minorVersion] == nil) then
					minorOrder = minorOrder + 1
					patchOrder = 0
					XF.Options.args.General.args.ChangeLog.args[minorVersion] = {
						order = minorOrder,
						type = 'group',
						childGroups = 'tree',
						name = minorVersion,
						args = {},
					}
				end
				patchOrder = patchOrder + 1
				XF.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()] = {
					order = patchOrder,
					type = 'group',
					name = version:GetKey(),
					desc = 'Major: ' .. version:GetMajor() .. '\nMinor: ' .. version:GetMinor() .. '\nPatch: ' .. version:GetPatch(),
					args = XF.ChangeLog[version:GetKey()],
				}
				if(version:IsAlpha()) then
					XF.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()].name = version:GetKey() .. ' |cffFF4700Alpha|r'
				elseif(version:IsBeta()) then
					XF.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()].name = version:GetKey() .. ' |cffFF7C0ABeta|r'
				end
			end
		end

		-- One time install logic
		local version = XFC.Version:new()
		if(XF.Config.InstallVersion ~= nil) then
			version:SetKey(XF.Config.InstallVersion)
		else
			version:SetKey('0.0.0')
		end
		if(version:IsNewer(XFO.Version, true)) then
			XF:Info(ObjectName, 'Performing new install')	
			XF:Install()
			XF.Config.InstallVersion = XFO.Version:GetKey()
		end
	end).
	catch(function (inErrorMessage)
		XF:Debug(ObjectName, inErrorMessage)
	end)
	--#endregion

	XF:Info(ObjectName, 'Configs loaded')
end

function XF:InitProfile()
    -- When DB changes namespace (profile) the XF.Config becomes invalid and needs to be reset
    XF.Config = XF.ConfigDB.profile
end

function XF_ToggleOptions()
	if XF.Lib.ConfigDialog.OpenFrames[XF.Name] ~= nil then
		XF.Lib.ConfigDialog:Close(XF.Name)
	else
		XF.Lib.ConfigDialog:Open(XF.Name)
		XF.Lib.ConfigDialog:SelectGroup(XF.Name, 'General', 'About')
	end
end

function XF:Install()
	for key, value in pairs (XF.Config.DataText.Guild.Order) do
		local newKey = key:gsub("Order", "")
		XF.Config.DataText.Guild.Order[key] = nil
		XF.Config.DataText.Guild.Order[newKey] = value			
	end

	for key, value in pairs (XF.Config.DataText.Guild.Alignment) do
		local newKey = key:gsub("Alignment", "")
		XF.Config.DataText.Guild.Alignment[key] = nil
		XF.Config.DataText.Guild.Alignment[newKey] = value
	end
end