local XFG, G = unpack(select(2, ...))
local ObjectName = 'ChatConfig'

local _Frame = CreateFrame('Frame')
local _Background = _Frame:CreateTexture()
_Background:SetAllPoints(_Frame)
_Background:SetColorTexture(0, 0, 0, 0.25)
_Frame.name = XFG.Category

local _Category = Settings.RegisterCanvasLayoutCategory(_Frame, 'XFaction', 1)
Settings.RegisterAddOnCategory(_Category)

_Frame:SetScript('OnShow', function(inFrame) XFG:ShowChatFrame(inFrame) end)

function XFG:ShowChatFrame(inFrame)
    -- Title
    local _Title = inFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	_Title:SetPoint('TOPLEFT', 16, -16)
	_Title:SetText(XFG.Title .. ' - ' .. XFG.Lib.Locale['CHAT'])

    -- Line
    local _Line = inFrame:CreateLine()
    _Line:SetColorTexture(0.2, 0.8, 1, 1)
    _Line:SetStartPoint('TOPLEFT', 0, -50)
    _Line:SetEndPoint('TOPRIGHT', 0, -50)

    -- Guild Chat tab
    local _GuildChatTab = XFG.Widgets.NewTab(
        inFrame,
		XFG.Lib.Locale['CHAT_GUILD'],
		function(self, value) XFG.Configs:Get('Enable'):SetValue(value) end
    )
    _GuildChatTab:SetPoint('TOPLEFT', 0, -72, 'BOTTOMLEFT', 16, -16)
    local _DescText = _GuildChatTab.tabframe:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	_DescText:SetPoint('CENTER', _GuildChatTab.tabframe)
    _DescText:SetText('Guild Chat')

    -- Achievement tab
    local _AchTab = XFG.Widgets.NewTab(
        inFrame,
		XFG.Lib.Locale['ACHIEVEMENT'],
		function(self, value) XFG.Configs:Get('Enable'):SetValue(value) end
    )
    _AchTab:SetPoint('TOPLEFT', _GuildChatTab:GetWidth() + 20, -72, 'BOTTOMRIGHT', 16, -16)
    local _DescText = _AchTab.tabframe:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	_DescText:SetPoint('CENTER', _AchTab.tabframe)
    _DescText:SetText('Achievement')


    XFG.Widgets.TabClick(_GuildChatTab)


    -- -- Enable Checkbox
    -- local _EnableFrame = XFG.Widgets.NewCheckbox(
    --     inFrame,
	-- 	XFG.Lib.Locale['ENABLE'],
	-- 	'',
	-- 	function(self, value) XFG.Configs:Get('Enable'):SetValue(value) end
    -- )
    -- _EnableFrame:SetChecked(XFG.Configs:Get('Enable'):GetValue())
    -- _EnableFrame:SetPoint('TOPLEFT', _Desc, 'BOTTOMLEFT', 16, -16)

    inFrame:SetScript('OnShow', nil)
end

-- 					order = 3,
-- 					type = 'group',
-- 					name = '',
-- 					inline = true,
-- 					args = {
-- 						Enable = {
-- 							order = 3,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['ENABLE'],
-- 							desc = XFG.Lib.Locale['CHAT_GUILD_TOOLTIP'],
-- 							get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
-- 						},
-- 						Space1 = {
-- 							order = 4,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						Faction = {
-- 							order = 5,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_FACTION'],
-- 							desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.GChat.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
-- 						},
-- 						Guild = {
-- 							order = 6,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
-- 							desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.GChat.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
-- 						},
-- 						Main = {
-- 							order = 7,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_MAIN'],
-- 							desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.GChat.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
-- 						},
-- 						Space2 = {
-- 							order = 8,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						CColor = {
-- 							order = 9,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_CCOLOR'],
-- 							desc = XFG.Lib.Locale['CHAT_CCOLOR_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.GChat.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
-- 						},
-- 						FColor = {
-- 							order = 10,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_FCOLOR'],
-- 							desc = XFG.Lib.Locale['CHAT_FCOLOR_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.GChat.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.GChat[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.GChat[ info[#info] ] = value; end
-- 						},
-- 						Space3 = {
-- 							order = 11,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						Color = {
-- 							order = 12,
-- 							type = 'color',
-- 							name = XFG.Lib.Locale['CHAT_FONT_COLOR'],
-- 							hidden = function()
-- 								return (not XFG.Config.Chat.GChat.Enable or XFG.Config.Chat.GChat.FColor or not XFG.Config.Chat.GChat.CColor)
-- 							end,
-- 							get = function()
-- 								return XFG.Config.Chat.GChat.Color.Red, XFG.Config.Chat.GChat.Color.Green, XFG.Config.Chat.GChat.Color.Blue
-- 							end,
-- 							set = function(_, inRed, inGreen, inBlue)
-- 								XFG.Config.Chat.GChat.Color.Red = inRed
-- 								XFG.Config.Chat.GChat.Color.Green = inGreen
-- 								XFG.Config.Chat.GChat.Color.Blue = inBlue
-- 							end,
-- 						},
-- 						AColor = {
-- 							order = 13,
-- 							type = 'color',
-- 							name = XFG.Lib.Locale['CHAT_FONT_ACOLOR'],
-- 							hidden = function()
-- 								return (not XFG.Config.Chat.GChat.Enable or not XFG.Config.Chat.GChat.FColor or not XFG.Config.Chat.GChat.CColor)
-- 							end,
-- 							get = function()
-- 								return XFG.Config.Chat.GChat.AColor.Red, XFG.Config.Chat.GChat.AColor.Green, XFG.Config.Chat.GChat.AColor.Blue
-- 							end,
-- 							set = function(_, inRed, inGreen, inBlue)
-- 								XFG.Config.Chat.GChat.AColor.Red = inRed
-- 								XFG.Config.Chat.GChat.AColor.Green = inGreen
-- 								XFG.Config.Chat.GChat.AColor.Blue = inBlue
-- 							end,
-- 						},
-- 						HColor = {
-- 							order = 14,
-- 							type = 'color',
-- 							name = XFG.Lib.Locale['CHAT_FONT_HCOLOR'],
-- 							hidden = function()
-- 								return (not XFG.Config.Chat.GChat.Enable or not XFG.Config.Chat.GChat.FColor or not XFG.Config.Chat.GChat.CColor)
-- 							end,
-- 							get = function()
-- 								return XFG.Config.Chat.GChat.HColor.Red, XFG.Config.Chat.GChat.HColor.Green, XFG.Config.Chat.GChat.HColor.Blue
-- 							end,
-- 							set = function(_, inRed, inGreen, inBlue)
-- 								XFG.Config.Chat.GChat.HColor.Red = inRed
-- 								XFG.Config.Chat.GChat.HColor.Green = inGreen
-- 								XFG.Config.Chat.GChat.HColor.Blue = inBlue
-- 							end,
-- 						},
-- 					}
-- 				},
-- 			},
-- 		},
-- 		Achievement = {
-- 			order = 2,
-- 			type = 'group',
-- 			name = XFG.Lib.Locale['ACHIEVEMENT'],
-- 			args = {
-- 				Header = {
-- 					order = 1,
-- 					type = 'group',
-- 					name = XFG.Lib.Locale['DESCRIPTION'],
-- 					inline = true,
-- 					args = {
-- 						Description = {
-- 							order = 1,
-- 							type = 'description',
-- 							fontSize = 'medium',
-- 							name = XFG.Lib.Locale['CHAT_ACHIEVEMENT_DESCRIPTION'],
-- 						},
-- 					}
-- 				},
-- 				Space1 = {
-- 					order = 2,
-- 					type = 'description',
-- 					name = '',
-- 				},
-- 				Options = {
-- 					order = 3,
-- 					type = 'group',
-- 					name = '',
-- 					inline = true,
-- 					args = {
-- 						Enable = {
-- 							order = 3,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['ENABLE'],
-- 							desc = XFG.Lib.Locale['CHAT_ACHIEVEMENT_TOOLTIP'],
-- 							get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
-- 						},
-- 						Space1 = {
-- 							order = 4,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						Faction = {
-- 							order = 5,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_FACTION'],
-- 							desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
-- 						},
-- 						Guild = {
-- 							order = 6,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
-- 							desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
-- 						},
-- 						Main = {
-- 							order = 7,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_MAIN'],
-- 							desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
-- 						},
-- 						Space2 = {
-- 							order = 8,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						CColor = {
-- 							order = 9,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_CCOLOR'],
-- 							desc = XFG.Lib.Locale['CHAT_CCOLOR_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
-- 						},
-- 						FColor = {
-- 							order = 10,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_FCOLOR'],
-- 							desc = XFG.Lib.Locale['CHAT_FCOLOR_TOOLTIP'],
-- 							disabled = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable)
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Achievement[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Achievement[ info[#info] ] = value; end
-- 						},
-- 						Space3 = {
-- 							order = 11,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						Color = {
-- 							order = 12,
-- 							type = 'color',
-- 							name = XFG.Lib.Locale['CHAT_FONT_COLOR'],
-- 							hidden = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable or XFG.Config.Chat.Achievement.FColor or not XFG.Config.Chat.Achievement.CColor)
-- 							end,
-- 							get = function()
-- 								return XFG.Config.Chat.Achievement.Color.Red, XFG.Config.Chat.Achievement.Color.Green, XFG.Config.Chat.Achievement.Color.Blue
-- 							end,
-- 							set = function(_, inRed, inGreen, inBlue)
-- 								XFG.Config.Chat.Achievement.Color.Red = inRed
-- 								XFG.Config.Chat.Achievement.Color.Green = inGreen
-- 								XFG.Config.Chat.Achievement.Color.Blue = inBlue
-- 							end,
-- 						},
-- 						AColor = {
-- 							order = 13,
-- 							type = 'color',
-- 							name = XFG.Lib.Locale['CHAT_FONT_ACOLOR'],
-- 							hidden = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable or not XFG.Config.Chat.Achievement.FColor or not XFG.Config.Chat.Achievement.CColor)
-- 							end,
-- 							get = function()
-- 								return XFG.Config.Chat.Achievement.AColor.Red, XFG.Config.Chat.Achievement.AColor.Green, XFG.Config.Chat.Achievement.AColor.Blue
-- 							end,
-- 							set = function(_, inRed, inGreen, inBlue)
-- 								XFG.Config.Chat.Achievement.AColor.Red = inRed
-- 								XFG.Config.Chat.Achievement.AColor.Green = inGreen
-- 								XFG.Config.Chat.Achievement.AColor.Blue = inBlue
-- 							end,
-- 						},
-- 						HColor = {
-- 							order = 14,
-- 							type = 'color',
-- 							name = XFG.Lib.Locale['CHAT_FONT_HCOLOR'],
-- 							hidden = function()
-- 								return (not XFG.Config.Chat.Achievement.Enable or not XFG.Config.Chat.Achievement.FColor or not XFG.Config.Chat.Achievement.CColor)
-- 							end,
-- 							get = function()
-- 								return XFG.Config.Chat.Achievement.HColor.Red, XFG.Config.Chat.Achievement.HColor.Green, XFG.Config.Chat.Achievement.HColor.Blue
-- 							end,
-- 							set = function(_, inRed, inGreen, inBlue)
-- 								XFG.Config.Chat.Achievement.HColor.Red = inRed
-- 								XFG.Config.Chat.Achievement.HColor.Green = inGreen
-- 								XFG.Config.Chat.Achievement.HColor.Blue = inBlue
-- 							end,
-- 						},
-- 					},
-- 				},
-- 			}
-- 		},
-- 		Login = {
-- 			order = 3,
-- 			type = 'group',
-- 			name = XFG.Lib.Locale['CHAT_ONLINE'],
-- 			args = {
-- 				Header = {
-- 					order = 1,
-- 					type = 'group',
-- 					name = XFG.Lib.Locale['DESCRIPTION'],
-- 					inline = true,
-- 					args = {
-- 						Description = {
-- 							order = 1,
-- 							type = 'description',
-- 							fontSize = 'medium',
-- 							name = XFG.Lib.Locale['CHAT_ONLINE_DESCRIPTION'],
-- 						},
-- 					}
-- 				},
-- 				Space1 = {
-- 					order = 2,
-- 					type = 'description',
-- 					name = '',
-- 				},
-- 				Options = {
-- 					order = 3,
-- 					type = 'group',
-- 					name = '',
-- 					inline = true,
-- 					args = {
-- 						Enable = {
-- 							order = 3,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['ENABLE'],
-- 							desc = XFG.Lib.Locale['CHAT_ONLINE_TOOLTIP'],
-- 							get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
-- 						},
-- 						Sound = {
-- 							order = 4,
-- 							type = 'toggle',
-- 							disabled = function()
-- 								return not XFG.Config.Chat.Login.Enable
-- 							end,
-- 							name = XFG.Lib.Locale['CHAT_ONLINE_SOUND'],
-- 							desc = XFG.Lib.Locale['CHAT_ONLINE_SOUND_TOOLTIP'],
-- 							get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
-- 						},
-- 						Space1 = {
-- 							order = 5,
-- 							type = 'description',
-- 							name = '',
-- 						},
-- 						Faction = {
-- 							order = 6,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_FACTION'],
-- 							desc = XFG.Lib.Locale['CHAT_FACTION_TOOLTIP'],
-- 							disabled = function()
-- 								return not XFG.Config.Chat.Login.Enable
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
-- 						},
-- 						Guild = {
-- 							order = 7,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_GUILD_NAME'],
-- 							desc = XFG.Lib.Locale['CHAT_GUILD_NAME_TOOLTIP'],
-- 							disabled = function()
-- 								return not XFG.Config.Chat.Login.Enable
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
-- 						},
-- 						Main = {
-- 							order = 8,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHAT_MAIN'],
-- 							desc = XFG.Lib.Locale['CHAT_MAIN_TOOLTIP'],
-- 							disabled = function()
-- 								return not XFG.Config.Chat.Login.Enable
-- 							end,
-- 							get = function(info) return XFG.Config.Chat.Login[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Login[ info[#info] ] = value; end
-- 						},
-- 					},
-- 				},
-- 			}
-- 		},
-- 		Channel = {
-- 			order = 4,
-- 			type = 'group',
-- 			name = XFG.Lib.Locale['CHANNEL'],
-- 			args = {
-- 				Header = {
-- 					order = 1,
-- 					type = 'group',
-- 					name = XFG.Lib.Locale['DESCRIPTION'],
-- 					inline = true,
-- 					args = {
-- 						Description = {
-- 							order = 1,
-- 							type = 'description',
-- 							fontSize = 'medium',
-- 							name = XFG.Lib.Locale['CHAT_CHANNEL_DESCRIPTION'],
-- 						},
-- 					}
-- 				},
-- 				Space1 = {
-- 					order = 2,
-- 					type = 'description',
-- 					name = '',
-- 				},
-- 				Options = {
-- 					order = 3,
-- 					type = 'group',
-- 					name = '',
-- 					inline = true,
-- 					args = {
-- 						Last = {
-- 							order = 3,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHANNEL_LAST'],
-- 							desc = XFG.Lib.Locale['CHANNEL_LAST_TOOLTIP'],
-- 							get = function(info) return XFG.Config.Chat.Channel[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Channel[ info[#info] ] = value; end
-- 						},
-- 						Color = {
-- 							order = 4,
-- 							type = 'toggle',
-- 							name = XFG.Lib.Locale['CHANNEL_COLOR'],
-- 							desc = XFG.Lib.Locale['CHANNEL_COLOR_TOOLTIP'],
-- 							get = function(info) return XFG.Config.Chat.Channel[ info[#info] ] end,
-- 							set = function(info, value) XFG.Config.Chat.Channel[ info[#info] ] = value; end
-- 						},
-- 					},
-- 				},
-- 			}
-- 		}
-- 	}
-- }