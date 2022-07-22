local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

StaticPopupDialogs["LINKS"] = {
	text = XFG.Title,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:SetWidth(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:SetWidth(self.editBox.width or 50)
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

XFG.Options.args.Support = {
	name = XFG.Lib.Locale['SUPPORT'],
	type = 'group',
	args = {
		Bar = {
			order = 1,
			name = format("|cffffffff%s|r", XFG.Version),
			type = 'header'
		},	
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
		PM = {
			order = 4,
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
		Translation = {
			order = 5,
			type = 'group',
			name = XFG.Lib.Locale['TRANSLATIONS'],
			guiInline = true,
			args = {
				Translators = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = 'Elskerdeg (Spanish)',
				}
			}
		},
		Testing = {
			order = 6,
			type = 'group',
			name = XFG.Lib.Locale['SUPPORT_UAT'],
			guiInline = true,
			args = {
				UAT = {
					order = 1,
					type = 'description',
					fontSize = 'medium',
					name = 'Bicter, Decobus, Dropbae, Elskerdeg, Fleecey, FrankyV, Fubash, Nyssa, Raelea, Rysal',
				}
			}
		}
	}
}