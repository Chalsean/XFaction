local XFG, G = unpack(select(2, ...))
local ObjectName = 'ConfigSetup'
local RealmXref = {}

function XFG:SetupMenus()
	XFG.Cache.Setup = {
		Confederate = {},
		Realms = {},
		Teams = {},
		Guilds = {},
		GuildsRealms = {},
		Compress = true,
	}

	--#region Confederate Menu
	XFG.Cache.Setup.Confederate.Initials = XFG.Confederate:GetInitials()
	XFG.Cache.Setup.Confederate.Name = XFG.Confederate:GetName()
	if(XFG.Channels:HasLocalChannel()) then
		XFG.Cache.Setup.Confederate.ChannelName = XFG.Channels:GetLocalChannel():GetName()
		XFG.Cache.Setup.Confederate.Password = XFG.Channels:GetLocalChannel():GetPassword()
	end
	--#endregion

	--#region Realm Menu
	XFG.Options.args.Setup.args.Realms.args.Bar.name = format("|cffffffff%s %s|r", XFG.Lib.Locale['REGION'], XFG.Regions:GetCurrent():GetName())
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
		XFG.Options.args.Setup.args.Realms.args[tostring(i + 2)] = {
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
			XFG.Options.args.Setup.args.Realms.args[tostring(i + 2)].desc = 
			XFG.Options.args.Setup.args.Realms.args[tostring(i + 2)].desc .. 
			XFG.Lib.Locale['SETUP_REALMS_CONNECTED'] .. connectedRealm.name
			if(j ~= #XFG.Cache.Setup.Realms[i].connections) then 
				XFG.Options.args.Setup.args.Realms.args[tostring(i + 2)].desc = 
				XFG.Options.args.Setup.args.Realms.args[tostring(i + 2)].desc .. '\n'
			end
		end
	end
	--#endregion

	--#region Guild Menu
	for _, guild in XFG.Guilds:SortedIterator() do
		table.insert(XFG.Cache.Setup.Guilds, {
			realm = tostring(guild:GetRealm():GetID()),
			faction = guild:GetFaction():GetID(),
			initials = guild:GetInitials(),
			name = guild:GetName(),
		})
		XFG.Cache.Setup.GuildsRealms[tostring(guild:GetRealm():GetID())] = guild:GetRealm():GetName()
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
		XFG.Options.args.Setup.args.Guilds.args[tostring(4 * i)] = {
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
		XFG.Options.args.Setup.args.Guilds.args[tostring(4 * i + 1)] = {
			type = 'select',
			order = 4 * i + 1,
			name = XFG.Lib.Locale['REALM'],
			values = XFG.Cache.Setup.GuildsRealms,
			get = function(info) return XFG.Cache.Setup.Guilds[i].realm end,
			set = function(info, value) XFG.Cache.Setup.Guilds[i].realm = value	end
		}		
		XFG.Options.args.Setup.args.Guilds.args[tostring(4 * i + 2)] = {
			type = 'input',
			order = 4 * i + 2,
            name = XFG.Lib.Locale['INITIALS'],
			width = 'half',
            get = function(info) return XFG.Cache.Setup.Guilds[i].initials end,
            set = function(info, value)
				XFG.Cache.Setup.Guilds[i].initials = value
			end
		}
		XFG.Options.args.Setup.args.Guilds.args[tostring(4 * i + 3)] = {
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
	for _, team in XFG.Teams:SortedIterator() do
		if(team:GetInitials() ~= '?') then
			table.insert(XFG.Cache.Setup.Teams, {
				initials = team:GetInitials(),
				name = team:GetName(),
			})
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
		XFG.Options.args.Setup.args.Teams.args[tostring(2 * i)] = {
			type = 'input',
			order = 2 * i,
            name = 'Initials',
			width = "half",
            get = function(info) return XFG.Cache.Setup.Teams[i].initials end,
            set = function(info, value)
				XFG.Cache.Setup.Teams[i].initials = value
			end
		}
		XFG.Options.args.Setup.args.Teams.args[tostring(2 * i + 1)] = {
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

XFG.Options.args.Setup = {
	name = XFG.Lib.Locale['SETUP'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		Instructions = {
			order = 1,
			type = 'group',
			name = 'Instructions',
			args = {
                Config = {
                    type = "input",
					order = 1,
                    name = XFG.Lib.Locale['CONFEDERATE_CONFIG_BUILDER'],
                    width = "full",
                    multiline = 24,
                    get = function(info) return XFG.Cache.Confederate[ info[#info] ] end,
                    set = function(info, value) XFG.Cache.Confederate[ info[#info] ] = value; end
                },
                Load = {
                    type = "execute",
					order = 2,
                    name = XFG.Lib.Locale['CONFEDERATE_LOAD'],
                    width = "2",
                    func = function(info)
                        XFG.Cache.Confederate.Config = LoadConfig(XFG.Guilds:GetInfo())
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Config")
                    end
                },
                Generate = {
                    type = "execute",
					order = 3,
                    name = XFG.Lib.Locale['CONFEDERATE_GENERATE'],
                    width = "2",
                    func = function(info)
                        XFG.Cache.Confederate.Config = GenerateConfig(XFG.Cache.Confederate.Config)
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Config")
                    end
                }
			}
		},
		Confederate = {
			order = 2,
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
							name = 'Select the realms where your guilds are located. If another realm enables based on your selection, that is expected behaviour for connected realms.',
						},
					}
				},
				Initials = {
					order = 2,
					type = 'input',
					name = 'Initials',
					get = function(info) return XFG.Cache.Setup.Confederate.Initials end,
					set = function(info, value) XFG.Cache.Setup.Confederate.Initials = value end,
				},
				Name = {
					order = 3,
					type = 'input',
					name = 'Name',
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
					name = 'Channel',
					get = function(info) return XFG.Cache.Setup.Confederate.ChannelName end,
					set = function(info, value) XFG.Cache.Setup.Confederate.ChannelName = value end,
				},
				Password = {
					order = 6,
					type = 'input',
					name = 'Password',
					get = function(info) return XFG.Cache.Setup.Confederate.Password end,
					set = function(info, value) XFG.Cache.Setup.Confederate.Password = value end,
				},
			}
		},
		Realms = {
			order = 3,
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
			order = 4,
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
			order = 5,
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
		Generate = {
			order = 6,
			type = 'group',
			name = 'Generate',
			args = {
				Header = {
					order = 1,
					type = 'group',
					name = XFG.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = 'Mulitple raid teams are typically used by larger confederates spanning multiple guilds. It is not required setup for all guilds, only if you want to use the feature.\n\nNote the primary key is the team initials, so they need to be unique.\n\nWhen filling out player notes, use the tag [XFt:<Initials>] to associate that player to their raid team.',
						},
					}
				},
				Compress = {
					order = 3,
					type = 'toggle',
					name = 'Compress',
					desc = 'Compress and encode the configuration string to take up less room in guild info.',
					get = function(info) return XFG.Cache.Setup.Compress end,
					set = function(info, value) XFG.Cache.Setup.Compress = value end,
				},
				Generate = {
                    type = "execute",
					order = 2,
                    name = XFG.Lib.Locale['CONFEDERATE_GENERATE'],
                    width = "2",
                    func = function(info)
                        XFG.Cache.Setup.Output = GenerateConfig(XFG.Cache.Setup.Output)
                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Output")
						XFG.Options.args.Setup.args.Generate.args.Output.desc = string.len(XFG.Cache.Setup.Output) .. ' characters'
                    end
                },
				Output = {
                    type = "input",
					order = 4,
                    name = XFG.Lib.Locale['CONFEDERATE_CONFIG_BUILDER'],
                    width = "full",
                    multiline = 10,
                    get = function(info) return XFG.Cache.Setup[ info[#info] ] end,
                    set = function(info, value) XFG.Cache.Setup[ info[#info] ] = value; end
                },
			},
		},
	}
}