local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.General'

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
						Configuration = {
							order = 2,
							type = 'group',
							name = XFG.Lib.Locale['GENERAL_CONFIGURATION'],
							guiInline = true,
							args = {
								Chat = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_CHAT']
								},
								Datatext = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DATATEXT']
								},
								Nameplates = {
									order = 3,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_NAMEPLATES']
								},	
								Setup = {
									order = 4,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_SETUP']
								},		
								Support = {
									order = 5,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_SUPPORT']
								},			
								Debug = {
									order = 6,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DEBUG']
								},		
							}
						},
					},
				},
				Support = {
					order = 4,
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
				ChangeLog = {
					order = 5,
					type = 'group',
					childGroups = 'tree',
					name = XFG.Lib.Locale['CHANGE_LOG'],
					args = {	

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
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Chat', XFG.Name, 'Chat')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'DataText', XFG.Name, 'DataText')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Addons', XFG.Name, 'Addons')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Setup', XFG.Name, 'Setup')
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
					XFG.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()].name = version:GetKey() .. format(' |cffFF4700Alpha|r')
				elseif(version:IsBeta()) then
					XFG.Options.args.General.args.ChangeLog.args[minorVersion].args[version:GetKey()].name = version:GetKey() .. format(' |cffFF7C0ABeta|r')
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