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

function XFG:SupportConfig()
	local _Options = {
		name = XFG.Title,
		order = 1,
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
				name = 'Resources',
				guiInline = true,
				args = {
					Discord = {
						order = 1,
						type = 'execute',
						name = 'Discord',
						func = function() StaticPopup_Show("LINKS", nil, nil, 'https://discord.gg/eternalkingdom') end,
					},
					Git = {
						order = 1,
						type = 'execute',
						name = 'GitHub',
						func = function() StaticPopup_Show("LINKS", nil, nil, 'https://github.com/Chalsean/XFaction') end,
					},					
				}
			},
			Development = {
				order = 3,
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
				order = 4,
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
	
	XFG.Lib.Config:RegisterOptionsTable('XFaction', _Options)
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction', 'XFaction')
end