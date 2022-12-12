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
	type = 'group',
	args = {
		General = {
			name = XFG.Lib.Locale['GENERAL'],
			type = 'group',
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
				DHeader = {
					order = 3,
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
					order = 4,
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
				}
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
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Support', XFG.Name, 'Support')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Debug', XFG.Name, 'Debug')
	XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Profile', XFG.Name, 'Profile')

	XFG.ConfigDB.RegisterCallback(XFG, 'OnProfileChanged', 'InitProfile')
	XFG.ConfigDB.RegisterCallback(XFG, 'OnProfileCopied', 'InitProfile')
	XFG.ConfigDB.RegisterCallback(XFG, 'OnProfileReset', 'InitProfile')

	XFG:SetupRealms()
	XFG:Info(ObjectName, 'Configs loaded')
end

function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.ConfigDB.profile
end