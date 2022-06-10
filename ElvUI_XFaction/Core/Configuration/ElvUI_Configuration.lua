local XFG, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')

StaticPopupDialogs["CREDITS"] = {
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
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

function XFG:InitializeConfig()
	E.Options.args.xfaction = {
		name = XFG.Title,
		order = 6,
		type = 'group',
		childGroups = 'tree',
		args = {
			title = {
				order = 1,
				name = format("%s (|cffffffff%s|r)", XFG.Title, XFG.Version),
				type = 'header'
			},
			General = {
				order = 1,
				name = 'General',
				type = 'group',
				get = function(info) return XFG.Config[ info[#info] ] end,
				set = function(info, value) XFG.Config[ info[#info] ] = value; end,
				childGroups = 'tab',
				args = {
					Confederate = {
						order = 1,
						name = 'Confederate',
						type = 'group',
						guiInline = true,
						args = {
							CName = {
								order = 1,
								type = "input",
								width = "full",
								name = "Name",
								desc = "Name of the confederate",
								get = function(info) return XFG.Config.General[ info[#info] ] end,
								set = function(info, value) XFG.Config.General[ info[#info] ] = value; XFG.Confederate:SetName(value); end
							},
							CName = {
								order = 1,
								type = 'toggle',
								name = 'Alternal Kingdom',
								desc = "Include guild in confederate communication",
								get = function(info) return XFG.Config.General[ info[#info] ] end,
								set = function(info, value) XFG.Config.General[ info[#info] ] = value; end
							}
						}
					}
				}
			},
			Communications = {
				order = 2,
				name = 'Communications',
				type = 'group',				
				get = function(info) return XFG.Config[ info[#info] ] end,
				set = function(info, value) XFG.Config[ info[#info] ] = value; end,
				args = {
					Network = {
						order = 1,
						type = 'group',
						name = 'Network',
						guiInline = true,
						args = {
							BNet = {
								order = 1,
								type = 'toggle',
								name = 'Battle.Net',
								desc = 'Allow addon to communicate cross realm/faction',
								get = function(info) return XFG.Config.Network[ info[#info] ] end,
								set = function(info, value) XFG.Config.Network[ info[#info] ] = value; if(value == true) then XFG.Network.BNet.Comm:PingFriends() end; end
							},
							Channel = {
								order = 2,
								type = 'toggle',
								name = 'Channel',
								desc = 'Allow addon to communicate on your realm/faction',
								get = function(info) return XFG.Config.Network[ info[#info] ] end,
								set = function(info, value) XFG.Config.Network[ info[#info] ] = value; end
							}
						}
					},
					Chat = {
						order = 2,
						type = 'group',
						name = 'Chat',
						guiInline = true,
						args = {
							GChat = {
								order = 1,
								type = 'toggle',
								name = 'Guild',
								desc = 'See cross realm/faction guild chat',
								get = function(info) return XFG.Config[ info[#info] ] end,
								set = function(info, value) XFG.Config[ info[#info] ] = value; end
							},
							OChat = {
								order = 2,
								type = 'toggle',
								name = 'Officer',
								disabled = true,
								desc = 'See cross realm/faction officer chat',
								get = function(info) return XFG.Config[ info[#info] ] end,
								set = function(info, value) XFG.Config[ info[#info] ] = value; end
							}
						}
					},
					System = {
						order = 2,
						type = 'group',
						name = 'System',
						guiInline = true,
						args = {
							Achievement = {
								order = 1,
								type = 'toggle',
								name = 'Achievement',
								desc = 'See cross realm/faction achievements',
								get = function(info) return XFG.Config.System[ info[#info] ] end,
								set = function(info, value) XFG.Config.System[ info[#info] ] = value; end
							},
							Login = {
								order = 2,
								type = 'toggle',
								name = 'Login/Logout',
								desc = 'See system message for players logging in/out on other realms/faction',
								get = function(info) return XFG.Config.System[ info[#info] ] end,
								set = function(info, value) XFG.Config.System[ info[#info] ] = value; end
							}
						}
					},
				}
			},
			DataText = {
				order = 3,
				name = 'DataText',
				type = 'group',				
				args = {
					XGuild = {
						order = 1,
						type = 'group',
						name = 'Guild (X)',
						guiInline = true,
						args = {
							Confederate = {
								order = 1,
								type = 'toggle',
								name = 'Confederate',
								desc = 'Show name of the confederate',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							GuildName = {
								order = 1,
								type = 'toggle',
								name = 'Guild',
								desc = 'Show name of the current guild',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							MOTD = {
								order = 1,
								type = 'toggle',
								name = 'MOTD',
								desc = 'Show guild message-of-the-day',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Space = {
								order = 2,
								type = 'header',
								name = ''
							},
							Covenant = {
								order = 3,
								type = 'toggle',
								name = 'Covenant',
								desc = 'Show players covenant icon',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Faction = {
								order = 4,
								type = 'toggle',
								name = 'Faction',
								desc = 'Show players faction icon',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Guild = {
								order = 5,
								type = 'toggle',
								name = 'Guild',
								desc = 'Show players guild name',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Level = {
								order = 6,
								type = 'toggle',
								name = 'Level',
								desc = 'Show players level',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Note = {
								order = 7,
								type = 'toggle',
								name = 'Note',
								desc = 'Show players note',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Profession = {
								order = 8,
								type = 'toggle',
								name = 'Profession',
								desc = 'Show players profession icons',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Race = {
								order = 9,
								type = 'toggle',
								name = 'Race',
								desc = 'Show players race',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Rank = {
								order = 10,
								type = 'toggle',
								name = 'Rank',
								desc = 'Show players guild rank',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Realm = {
								order = 11,
								type = 'toggle',
								name = 'Realm',
								desc = 'Show players realm name',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Spec = {
								order = 12,
								type = 'toggle',
								name = 'Spec',
								desc = 'Show players spec icon',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Team = {
								order = 13,
								type = 'toggle',
								name = 'Team',
								desc = 'Show players team name',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
							Zone = {
								order = 14,
								type = 'toggle',
								name = 'Zone',
								desc = 'Show players current zone',
								get = function(info) return XFG.Config.DataText.Guild[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Guild[ info[#info] ] = value; end
							},
						}
					},				
					XLinks = {
						order = 2,
						type = 'group',
						name = 'Links (X)',
						guiInline = true,
						args = {
							Area52 = {
								order = 1,
								type = 'toggle',
								name = 'Area 52',
								desc = 'Show active links to Area 52',
								get = function(info) return XFG.Config.DataText.Links[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Links[ info[#info] ] = value; XFG.Lib.DT:ForceUpdate_DataText(XFG.DataText.Links.Name); end
							},
							OnlyMine = {
								order = 2,
								type = 'toggle',
								name = 'Only Mine',
								desc = 'Show only your active links',
								get = function(info) return XFG.Config.DataText.Links[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Links[ info[#info] ] = value; end
							},						
						}
					},
					XShard = {
						order = 2,
						type = 'group',
						name = 'Shard (X)',
						guiInline = true,
						args = {
							Timer = {
								order = 1,
								type = 'range',
								name = 'Force Check',
								min = 15, max = 300, step = 1,
								desc = 'Seconds until forced to check shard',
								get = function(info) return XFG.Config.DataText.Shard[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Shard[ info[#info] ] = value; XFG.Lib.DT:ForceUpdate_DataText(XFG.DataText.Shard.Name); end
							},						
						}
					},
					XSoulbind = {
						order = 2,
						type = 'group',
						name = 'Soulbind (X)',
						guiInline = true,
						args = {
							Timer = {
								order = 1,
								type = 'toggle',
								name = 'Conduits',
								disabled = true,
								desc = 'Show active conduit icons',
								get = function(info) return XFG.Config.DataText.Soulbind[ info[#info] ] end,
								set = function(info, value) XFG.Config.DataText.Soulbind[ info[#info] ] = value; end
							},						
						}
					}
				}
			},
			Support = {
				order = 4,
				name = 'Support',
				type = 'group',				
				get = function(info) return XFG.Config[ info[#info] ] end,
				set = function(info, value) XFG.Config[ info[#info] ] = value; end,
				args = {
					Resources = {
						order = 1,
						type = 'group',
						name = 'Resources',
						guiInline = true,
						args = {
							Git = {
								order = 1,
								type = 'execute',
								name = L['Git Ticket tracker'],
								func = function() StaticPopup_Show("CREDITS", nil, nil, 'https://github.com/Chalsean/XFaction/issues') end,
							},
							Discord = {
								order = 2,
								type = 'execute',
								name = 'Discord',
								func = function() StaticPopup_Show("CREDITS", nil, nil, 'https://discord.gg/eternalkingdom') end,
							},
						}
					},
					Development = {
						order = 2,
						type = 'group',
						name = 'Development',
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
					Testing = {
						order = 3,
						type = 'group',
						name = 'User Acceptance Testing',
						guiInline = true,
						args = {
							UAT = {
								order = 1,
								type = 'description',
								fontSize = 'medium',
								name = 'Bicc, Branis, FrankyV, Hantevirus, Madrigosa, Nyssa, Rysal',
							}
						}
					},
				}
			}
		}
	}	
end

function XFG:DefaultConfigs()
	if(XFG.Config.DataText == nil) then XFG.Config.DataText = {} end

	if(XFG.Config.General == nil) then XFG.Config.General = {} end
	if(XFG.Config.General.CName == nil) then XFG.Config.General.CName = 'Eternal Kingdom' end

	if(XFG.Config.Network == nil) then XFG.Config.Network = {} end
	if(XFG.Config.Network.BNet == nil) then XFG.Config.Network.BNet = true end
	if(XFG.Config.Network.Channel == nil) then XFG.Config.Network.Channel = true end

	if(XFG.Config.Chat == nil) then XFG.Config.Chat = {} end
	if(XFG.Config.Chat.GChat == nil) then XFG.Config.Chat.GChat = true end
	if(XFG.Config.Chat.OChat == nil) then XFG.Config.Chat.OChat = false end

	if(XFG.Config.System == nil) then XFG.Config.System = {} end
	if(XFG.Config.System.Achievement == nil) then XFG.Config.System.Achievement = true end
	if(XFG.Config.System.Login == nil) then XFG.Config.System.Login = true end

	if(XFG.Config.DataText.Guild == nil) then XFG.Config.DataText.Guild = {} end
	if(XFG.Config.DataText.Guild.GuildName == nil) then XFG.Config.DataText.Guild.GuildName = true end
	if(XFG.Config.DataText.Guild.Confederate == nil) then XFG.Config.DataText.Guild.Confederate = true end
	if(XFG.Config.DataText.Guild.MOTD == nil) then XFG.Config.DataText.Guild.MOTD = true end

	if(XFG.Config.DataText.Guild.Covenant == nil) then XFG.Config.DataText.Guild.Covenant = true end
	if(XFG.Config.DataText.Guild.Faction == nil) then XFG.Config.DataText.Guild.Faction = true end
	if(XFG.Config.DataText.Guild.Guild == nil) then XFG.Config.DataText.Guild.Guild = true end
	if(XFG.Config.DataText.Guild.Level == nil) then XFG.Config.DataText.Guild.Level = true end
	if(XFG.Config.DataText.Guild.Note == nil) then XFG.Config.DataText.Guild.Note = false end
	if(XFG.Config.DataText.Guild.Profession == nil) then XFG.Config.DataText.Guild.Profession = true end
	if(XFG.Config.DataText.Guild.Race == nil) then XFG.Config.DataText.Guild.Race = true end
	if(XFG.Config.DataText.Guild.Rank == nil) then XFG.Config.DataText.Guild.Rank = true end
	if(XFG.Config.DataText.Guild.Realm == nil) then XFG.Config.DataText.Guild.Realm = false end
	if(XFG.Config.DataText.Guild.Spec == nil) then XFG.Config.DataText.Guild.Spec = true end
	if(XFG.Config.DataText.Guild.Team == nil) then XFG.Config.DataText.Guild.Team = true end
	if(XFG.Config.DataText.Guild.Zone == nil) then XFG.Config.DataText.Guild.Zone = true end

	if(XFG.Config.DataText.Links == nil) then XFG.Config.DataText.Links = {} end
	if(XFG.Config.DataText.Links.Area52 == nil) then XFG.Config.DataText.Links.Area52 = true end
	if(XFG.Config.DataText.Links.OnlyMine == nil) then XFG.Config.DataText.Links.OnlyMine = false end

	if(XFG.Config.DataText.Shard == nil) then XFG.Config.DataText.Shard = {} end
	if(XFG.Config.DataText.Shard.Timer == nil) then XFG.Config.DataText.Shard.Timer = 60 end

	if(XFG.Config.DataText.Soulbind == nil) then XFG.Config.DataText.Soulbind = {} end
	if(XFG.Config.DataText.Soulbind.Conduits == nil) then XFG.Config.DataText.Soulbind.Conduits = true end
end