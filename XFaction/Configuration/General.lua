local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

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
	name = XFG.Title,
	type = 'group',
	args = {
		General = {
			name = XFG.Lib.Locale['GENERAL'],
			type = 'group',
			args = {
				Bar = {
					order = 1,
					name = format("|cffffffff%s|r", type(XFG.Version) == 'string' and XFG.Version or XFG.Version:GetKey()),
					type = 'header'
				},	
				DHeader = {
					order = 2,
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
				DisHeader = {
					order = 3,
					type = 'group',
					name = XFG.Lib.Locale['DISCLAIMER'],
					guiInline = true,
					args = {
						Disclaimer = {
							order = 1,
							type = 'description',
							fontSize = 'medium',
							name = XFG.Lib.Locale['GENERAL_DISCLAIMER'],
						},
						Space1 = {
							order = 2,
							type = 'description',
							name = '',
						},
						Realm = {
							order = 3,
							type = 'description',
							fontSize = 'medium',
							name = 'Proudmoore (US)'
						},
						EK = {
							order = 4,
							type = 'description',
							fontSize = 'medium',
							name = '- Eternal Kingdom'
						},
						ENK = {
							order = 5,
							type = 'description',
							fontSize = 'medium',
							name = '- Endless Kingdom'
						},
						EDK = {
							order = 6,
							type = 'description',
							fontSize = 'medium',
							name = '- Enduring Kingdom'
						},
						AK = {
							order = 7,
							type = 'description',
							fontSize = 'medium',
							name = '- Alternal Kingdom'
						},
						AK2 = {
							order = 8,
							type = 'description',
							fontSize = 'medium',
							name = '- Alternal Kingdom 2'
						},
						AK3 = {
							order = 9,
							type = 'description',
							fontSize = 'medium',
							name = '- Alternal Kingdom 3'
						},
						AK4 = {
							order = 10,
							type = 'description',
							fontSize = 'medium',
							name = '- Alternal Kingdom 4'
						},
					}
				},
				What = {
					order = 4,
					type = 'group',
					name = XFG.Lib.Locale['GENERAL_WHAT'],
					guiInline = true,
					args = {
						GChat ={
							order = 1,
							type = 'group',
							name = XFG.Lib.Locale['CHAT_GUILD'],
							guiInline = true,
							args = {
								GChat1 = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_GUILD_CHAT']
								},
								GChat2 = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_GUILD_CHAT_ACHIEVEMENT']
								}
							}
						},
						System = {
							order = 2,
							type = 'group',
							name = XFG.Lib.Locale['GENERAL_SYSTEM_MESSAGES'],
							guiInline = true,
							args = {
								Login = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_SYSTEM_LOGIN']
								},
							}
						},
						DataText = {
							order = 3,
							type = 'group',
							name = XFG.Lib.Locale['GENERAL_DATA_BROKERS'],
							guiInline = true,
							args = {
								DTGuild = {
									order = 1,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTGUILD']
								},
								DTLinks = {
									order = 2,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTLINKS']
								},
								DTSoulbind = {
									order = 3,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTSOULBIND']
								},
								DTToken = {
									order = 4,
									type = 'description',
									fontSize = 'medium',
									name = XFG.Lib.Locale['GENERAL_DTTOKEN']
								}
							}
						}
					}
				}
			}
		},
	}
}