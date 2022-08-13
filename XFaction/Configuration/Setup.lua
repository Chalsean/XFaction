local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Options.args.Setup = {
	name = XFG.Lib.Locale['SETUP'],
	order = 1,
	type = 'group',
	childGroups = 'tab',
	args = {
		Confederate = {
			order = 1,
			type = 'group',
			name = XFG.Lib.Locale['CONFEDERATE'],
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
							name = XFG.Lib.Locale['NAMEPLATE_ELVUI_DESCRIPTION'],
						},
					}
				},
				Save = {
					order = 2,
					type = 'execute',
					name = XFG.Lib.Locale['SAVE'],
					disabled = true,
					func = function() 
						XFG.Confederate:SaveGuildInfo() 
						XFG.Options.args.Setup.args.Confederate.args.Save.disabled = true
					end,
				},
				Options = {
					order = 3,
					type = 'group',
					name = '',
					inline = true,
					disabled = function () return not XFG.Confederate:CanModifyGuildInfo() end,
					args = {
						Compression = {
							order = 1,
							type = 'toggle',
							name = XFG.Lib.Locale['COMPRESSION'],
							desc = XFG.Lib.Locale['SETUP_COMPRESSION_TOOLTIP'],
							get = function(info) return XFG.Config.Setup.Confederate[ info[#info] ] end,
							set = function(info, value) XFG.Config.Setup.Confederate[ info[#info] ] = value; end
						},
						Space = {
							order = 2,
							type = 'description',
							name = '',
						},
						ConfederateName = {
							type = 'input',
							order = 3,
							name = XFG.Lib.Locale['SETUP_CONFEDERATE_NAME'],
							desc = XFG.Lib.Locale['SETUP_CONFEDERATE_NAME_TOOLTIP'],
							width = 'full',
							validate = function (info, value) 
								value = strtrim(value)
								return strlen(value) > 0 
							end,
							get = function(info) return XFG.Confederate:GetName() end,
							set = function(info, value) 
								value = strtrim(value)
								XFG.Confederate:SetName(value)
								XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
							end
						},
						ConfederateInitials = {
							type = 'input',
							order = 4,
							name = XFG.Lib.Locale['SETUP_CONFEDERATE_INITIALS'],
							desc = XFG.Lib.Locale['SETUP_CONFEDERATE_INITIALS_TOOLTIP'],
							width = 'full',
							validate = function (info, value) 
								value = strtrim(value)
								return strlen(value) > 0 
							end,
							get = function(info) return XFG.Confederate:GetKey() end,
							set = function(info, value) 
								value = strtrim(value)
								XFG.Confederate:SetKey(value)
								XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
							end
						},
						ChannelName = {
							type = 'input',
							order = 5,
							name = XFG.Lib.Locale['SETUP_CHANNEL_NAME'],
							desc = XFG.Lib.Locale['SETUP_CHANNEL_NAME_TOOLTIP'],
							width = 'full',
							validate = function (info, value) 
								value = strtrim(value)
								return strlen(value) > 0 
							end,
							get = function(info)
								if(XFG.Outbox and XFG.Outbox:HasLocalChannel()) then
									return XFG.Outbox:GetLocalChannel():GetName()
								end
							end,
							set = function(info, value) 
							end
						},
						ChannelPassword = {
							type = 'input',
							order = 6,
							name = XFG.Lib.Locale['SETUP_CHANNEL_PASSWORD'],
							desc = XFG.Lib.Locale['SETUP_CHANNEL_PASSWORD_TOOLTIP'],
							width = 'full',
							get = function(info)
								if(XFG.Confederate:CanModifyGuildInfo() and XFG.Outbox and XFG.Outbox:HasLocalChannel()) then
									return XFG.Outbox:GetLocalChannel():GetPassword()
								end
							end,
							set = function(info, value) end
						},
					},	
				},		
			}
		},
		Guilds = {
			order = 2,
			type = 'group',
			name = XFG.Lib.Locale['GUILD'],
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
							name = XFG.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION'],
						},
					}
				},
				Save = {
					order = 2,
					type = 'execute',
					name = XFG.Lib.Locale['SAVE'],
					disabled = function () return XFG.Options.args.Setup.args.Confederate.args.Save.disabled end,
					func = function()
						try(function ()
							if(XFG.Cache.SetupGuild.Count ~= nil) then							
								local _NewGuild = Guild:new()
								_NewGuild:Initialize()
								_NewGuild:SetKey(XFG.Cache.SetupGuild.Initials)
								_NewGuild:SetName(XFG.Cache.SetupGuild.Name)
								_NewGuild:SetInitials(XFG.Cache.SetupGuild.Initials)
								_NewGuild:SetFaction(XFG.Factions:GetFaction(XFG.Cache.SetupGuild.Faction))
								_NewGuild:SetRealm(XFG.Realms:GetRealm(XFG.Cache.SetupGuild.Realm))							
								XFG.Guilds:AddGuild(_NewGuild)
								XFG.Cache.SetupGuild = {}
							end
							XFG.Confederate:SaveGuildInfo() 
							XFG.Options.args.Setup.args.Confederate.args.Save.disabled = true
						end).
						catch(function (inErrorMessage)
							XFG:Error(LogCategory, 'Failed to save guild information: ' .. inErrorMessage)
						end)						
					end,
				},
				Add = {
					order = 3,
					type = 'execute',
					name = XFG.Lib.Locale['SETUP_ADD_GUILD'],
					disabled = true,
					func = function() XFG:AddGuild() end,
				},
				Space = {
					order = 4,
					type = 'description',
					name = '',
				},
				Options = {
					order = 5,
					type = 'group',
					name = '',
					inline = true,
					disabled = function () return not XFG.Confederate:CanModifyGuildInfo() end,
					args = {},
				},			
			}
		},
		Teams = {
			order = 3,
			type = 'group',
			name = XFG.Lib.Locale['TEAM'],
			args = {
				DHeader = {
					order = 1,
					type = 'group',
					name = XFG.Lib.Locale['DESCRIPTION'],
					inline = true,
					args = {
						Description = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION'],
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
							name = XFG.Lib.Locale['ENABLE'],
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
						Icon = {
							order = 2,
							type = 'toggle',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_ICON'],
							desc = XFG.Lib.Locale['NAMEPLATE_KUI_ICON_TOOLTIP'],
							disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) 
								XFG.Config.Nameplates.Kui[ info[#info] ] = value
								if(not value) then
									XFG.Nameplates.Kui:StripIcons()
								end
							end
						},
						Bar = {
							order = 3,
							name = format("|cffffffff%s|r", XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_TEXT']),
							type = 'header'
						},						
						GuildName = {
							order = 4,
							type = 'select',
							name = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_NAME'],
							desc = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_INITIALS_TOOLTIP'],
							values = {
								Confederate = XFG.Lib.Locale['CONFEDERATE'],
								ConfederateInitials = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
								Guild = XFG.Lib.Locale['GUILD'],
								GuildInitials = XFG.Lib.Locale['GUILD_INITIALS'],
								Team = XFG.Lib.Locale['TEAM'],
							},
							disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
							get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
							set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
						},
					},
				},			
			}
		},
	}
}

function XFG:InitializeSetup()
	
	for _, _Faction in XFG.Factions:Iterator() do
		XFG.Cache.Factions[_Faction:GetKey()] = _Faction:GetName()
	end	
	for _, _Realm in XFG.Realms:Iterator() do
		XFG.Cache.Realms[_Realm:GetKey()] = _Realm:GetName()
	end

	sort(XFG.Cache.Factions)
	sort(XFG.Cache.Realms)

	local i = 1	
	for _, _Guild in XFG.Guilds:Iterator() do
		XFG.Options.args.Setup.args.Guilds.args.Options.args['Guild' .. i] = {
			order = i,
			type = 'group',
			name = 'Guild ' .. tostring(i),
			inline = true,
			args = {
				Name = {
					order = 1,
					type = 'input',
					name = 'Name',
					get = function(info) return _Guild:GetName() end,
					set = function(info, value) 
						_Guild:SetName(value) 
						XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
					end,
				},
				Initials = {
					order = 2,
					type = 'input',
					name = 'Initials',
					get = function(info) return _Guild:GetInitials() end,
					set = function(info, value) 
						_Guild:SetInitials(value) 
						XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
					end,
				},
				Space = {
					order = 3,
					type = 'description',
					name = '',
				},
				Faction = {
					order = 4,
					type = 'select',
					name = 'Faction',
					values = XFG.Cache.Factions,
					get = function(info) return _Guild:GetFaction():GetKey() end,
					set = function(info, value) 
						_Guild:SetFaction(XFG.Factions:GetFaction(value))
						XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
					end,
				},
				Realm = {
					order = 5,
					type = 'select',
					name = 'Realm',
					values = XFG.Cache.Realms,
					get = function(info) return _Guild:GetRealm():GetKey() end,
					set = function(info, value) 
						_Guild:SetRealm(XFG.Realms:GetRealm(value))
						XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
					end,
				},
			}
		}
		i = i + 1
	end
end

function XFG:AddGuild()
	
	for _, _Faction in XFG.Factions:Iterator() do
		XFG.Cache.Factions[_Faction:GetKey()] = _Faction:GetName()
	end	
	for _, _Realm in XFG.Realms:Iterator() do
		XFG.Cache.Realms[_Realm:GetKey()] = _Realm:GetName()
	end

	sort(XFG.Cache.Factions)
	sort(XFG.Cache.Realms)

	local i = XFG.Guilds:GetCount() + 1
	XFG.Cache.SetupGuild.Count = i

	XFG.Options.args.Setup.args.Guilds.args.Options.args['Guild' .. i] = {
		order = i,
		type = 'group',
		name = 'Guild ' .. tostring(i),
		inline = true,
		args = {
			Name = {
				order = 1,
				type = 'input',
				name = 'Name',
				get = function(info) return XFG.Cache.SetupGuild.Name end,
				set = function(info, value) 
					XFG.Cache.SetupGuild.Name = value 
					XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
				end,
			},
			Initials = {
				order = 2,
				type = 'input',
				name = 'Initials',
				get = function(info) return XFG.Cache.SetupGuild.Initials end,
				set = function(info, value) 
					XFG.Cache.SetupGuild.Initials = value
					XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
				end,
			},
			Space = {
				order = 3,
				type = 'description',
				name = '',
			},
			Faction = {
				order = 4,
				type = 'select',
				name = 'Faction',
				values = XFG.Cache.Factions,
				get = function(info) return XFG.Cache.SetupGuild.Faction end,
				set = function(info, value)
					XFG.Cache.SetupGuild.Faction = value
					XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
				end,
			},
			Realm = {
				order = 5,
				type = 'select',
				name = 'Realm',
				values = XFG.Cache.Realms,
				get = function(info) return XFG.Cache.SetupGuild.Realm end,
				set = function(info, value) 
					XFG.Cache.SetupGuild.Realm = value
					XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
				end,
			},
		}
	}
end