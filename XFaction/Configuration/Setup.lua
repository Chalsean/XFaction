local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

local function AddGuild()
	
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
		--inline = true,
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
	--LibStub("AceConfigRegistry-3.0"):NotifyChange("Config")
end

local function SaveGuild()
	try(function ()
		if(XFG.Cache.SetupGuild.Count ~= nil) then		
			-- need to repoint					
			local _NewGuild = Guild:new()
			_NewGuild:Initialize()
			_NewGuild:SetKey(XFG.Cache.SetupGuild.Initials)
			_NewGuild:SetName(XFG.Cache.SetupGuild.Name)
			_NewGuild:SetInitials(XFG.Cache.SetupGuild.Initials)
			_NewGuild:SetFaction(XFG.Factions:GetFaction(XFG.Cache.SetupGuild.Faction))
			_NewGuild:SetRealm(XFG.Realms:GetObject(XFG.Cache.SetupGuild.Realm))							
			XFG.Guilds:AddObject(_NewGuild)
			XFG:InitializeSetup()
		end
		XFG.Confederate:SaveGuildInfo() 
		XFG.Options.args.Setup.args.Confederate.args.Save.disabled = true
	end).
	catch(function (inErrorMessage)
		XFG:Error(LogCategory, 'Failed to save guild information: ' .. inErrorMessage)
	end)	
end

local function LoadConfig(inValue)
    -- If data is not XFaction return
    local val = string.match(inValue, '^XF:(.-):XF$')
    if val == nil  then
        return inValue
    end
    
    -- Decompress and deserialize XFaction data
	local _Decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(val))
    local _, _Deserialized = XFG:Deserialize(_Decompressed)
    
    return _Deserialized
end

local function GenerateConfig(inValue)
    -- If data is not XFaction return
    for _, _Line in ipairs(string.Split(inValue, '\n')) do
        if not string.find(_Line, 'XF.:') then
            return inValue
        end
    end
    return 'XF:' .. XFG.Lib.Deflate:EncodeForPrint(XFG.Lib.Deflate:CompressDeflate(inValue, {level = 9})) .. ':XF'
end

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
		-- Guilds = {
		-- 	order = 2,
		-- 	type = 'group',
		-- 	name = XFG.Lib.Locale['GUILD'],
		-- 	disabled = true,
		-- 	args = {
		-- 	-- 	Header = {
		-- 	-- 		order = 1,
		-- 	-- 		type = 'group',
		-- 	-- 		name = XFG.Lib.Locale['DESCRIPTION'],
		-- 	-- 		inline = true,
		-- 	-- 		args = {
		-- 	-- 			Description = {
		-- 	-- 				order = 1,
		-- 	-- 				type = 'description',
		-- 	-- 				fontSize = 'medium',
		-- 	-- 				name = XFG.Lib.Locale['SETUP_GUILD_DESCRIPTION'],
		-- 	-- 			},
		-- 	-- 		}
		-- 	-- 	},
		-- 	-- 	Add = {
		-- 	-- 		order = 2,
		-- 	-- 		type = 'execute',
		-- 	-- 		name = XFG.Lib.Locale['SETUP_ADD_GUILD'],
		-- 	-- 		disabled = function () return XFG.Cache.SetupGuild.Count ~= nil or not XFG.Confederate:CanModifyGuildInfo() end,
		-- 	-- 		func = function() AddGuild() end,
		-- 	-- 	},
		-- 	-- 	Save = {
		-- 	-- 		order = 3,
		-- 	-- 		type = 'execute',
		-- 	-- 		name = XFG.Lib.Locale['SAVE'],
		-- 	-- 		disabled = function () return XFG.Options.args.Setup.args.Confederate.args.Save.disabled end,
		-- 	-- 		func = function() SaveGuild() end,
		-- 	-- 	},				
		-- 	-- 	Space = {
		-- 	-- 		order = 4,
		-- 	-- 		type = 'description',
		-- 	-- 		name = '',
		-- 	-- 	},
		-- 	-- 	Options = {
		-- 	-- 		order = 5,
		-- 	-- 		type = 'group',
		-- 	-- 		childGroups = 'tree',
		-- 	-- 		name = XFG.Lib.Locale['SETUP_GUILD_MENU_TITLE'],
		-- 	-- 		disabled = function () return not XFG.Confederate:CanModifyGuildInfo() end,
		-- 	-- 		args = {},
		-- 	-- 	},			
		-- 	}
		-- },
		-- Teams = {
		-- 	order = 3,
		-- 	type = 'group',
		-- 	name = XFG.Lib.Locale['TEAM'],
		-- 	disabled = true,
		-- 	args = {
		-- 	-- 	DHeader = {
		-- 	-- 		order = 1,
		-- 	-- 		type = 'group',
		-- 	-- 		name = XFG.Lib.Locale['DESCRIPTION'],
		-- 	-- 		inline = true,
		-- 	-- 		args = {
		-- 	-- 			Description = {
		-- 	-- 				order = 1,
		-- 	-- 				type = 'description',
		-- 	-- 				fontSize = 'medium',
		-- 	-- 				name = XFG.Lib.Locale['NAMEPLATE_KUI_DESCRIPTION'],
		-- 	-- 			},
		-- 	-- 		}
		-- 	-- 	},
		-- 	-- 	Options = {
		-- 	-- 		order = 2,
		-- 	-- 		type = 'group',
		-- 	-- 		name = '',
		-- 	-- 		inline = true,
		-- 	-- 		disabled = function () return not IsAddOnLoaded('Kui_Nameplates') end,
		-- 	-- 		args = {
		-- 	-- 			Enable = {
		-- 	-- 				order = 1,
		-- 	-- 				type = 'toggle',
		-- 	-- 				name = XFG.Lib.Locale['ENABLE'],
		-- 	-- 				get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
		-- 	-- 				set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
		-- 	-- 			},
		-- 	-- 			Icon = {
		-- 	-- 				order = 2,
		-- 	-- 				type = 'toggle',
		-- 	-- 				name = XFG.Lib.Locale['NAMEPLATE_KUI_ICON'],
		-- 	-- 				desc = XFG.Lib.Locale['NAMEPLATE_KUI_ICON_TOOLTIP'],
		-- 	-- 				disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
		-- 	-- 				get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
		-- 	-- 				set = function(info, value) 
		-- 	-- 					XFG.Config.Nameplates.Kui[ info[#info] ] = value
		-- 	-- 					if(not value) then
		-- 	-- 						XFG.Nameplates.Kui:StripIcons()
		-- 	-- 					end
		-- 	-- 				end
		-- 	-- 			},
		-- 	-- 			Bar = {
		-- 	-- 				order = 3,
		-- 	-- 				name = format("|cffffffff%s|r", XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_TEXT']),
		-- 	-- 				type = 'header'
		-- 	-- 			},						
		-- 	-- 			GuildName = {
		-- 	-- 				order = 4,
		-- 	-- 				type = 'select',
		-- 	-- 				name = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_NAME'],
		-- 	-- 				desc = XFG.Lib.Locale['NAMEPLATE_KUI_GUILD_INITIALS_TOOLTIP'],
		-- 	-- 				values = {
		-- 	-- 					Confederate = XFG.Lib.Locale['CONFEDERATE'],
		-- 	-- 					ConfederateInitials = XFG.Lib.Locale['CONFEDERATE_INITIALS'],
		-- 	-- 					Guild = XFG.Lib.Locale['GUILD'],
		-- 	-- 					GuildInitials = XFG.Lib.Locale['GUILD_INITIALS'],
		-- 	-- 					Team = XFG.Lib.Locale['TEAM'],
		-- 	-- 				},
		-- 	-- 				disabled = function () return not XFG.Config.Nameplates.Kui.Enable end,
		-- 	-- 				get = function(info) return XFG.Config.Nameplates.Kui[ info[#info] ] end,
		-- 	-- 				set = function(info, value) XFG.Config.Nameplates.Kui[ info[#info] ] = value; end
		-- 	-- 			},
		-- 	-- 		},
		-- 	-- 	},			
		-- 	}
		-- },
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
	XFG.Cache.SetupGuild = {}

	local i = 1	
	for _, _Guild in XFG.Guilds:SortedIterator() do
		XFG.Options.args.Setup.args.Guilds.args.Options.args['Guild' .. i] = {
			order = i,
			type = 'group',
			name = 'Guild ' .. tostring(i),
			--inline = true,
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
						_Guild:SetRealm(XFG.Realms:GetObject(value))
						XFG.Options.args.Setup.args.Confederate.args.Save.disabled = false
					end,
				},
			}
		}
		i = i + 1
	end
end

