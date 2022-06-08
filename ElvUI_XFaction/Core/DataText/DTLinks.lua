local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'DTLinks'
local LogCategory = 'DTLinks'

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
local tooltip
local LDB_ANCHOR

-- Setup the Title Font. 14
local ttTitleFont = CreateFont("ttTitleFont")
ttTitleFont:SetTextColor(1,0.823529,0)

-- Setup the Header Font. 12
local ttHeaderFont = CreateFont("ttHeaderFont")
ttHeaderFont:SetTextColor(0.4,0.78,1)

-- Setup the Regular Font. 12
local ttRegFont = CreateFont("ttRegFont")
ttRegFont:SetTextColor(255,255,255)

local function OnEnable(self, event, ...)
	if (not self.text) then
		local text = self:CreateFontString(nil, 'OVERLAY')
		text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
		self.text = text
	end
	self.text:SetFormattedText('0')	
end

local function OnEvent(self, event, ...)
	if(XFG.Initialized and event == 'ELVUI_FORCE_UPDATE') then
		self.text:SetFormattedText(XFG.Network.BNet.Links:GetCount())
	end
end

local function OnEnter(self)

	LDB_ANCHOR = self	

	if XFG.Lib.QT:IsAcquired(ObjectName) then
		tooltip:Clear()
	else
		tooltip = XFG.Lib.QT:Acquire(ObjectName, 3, "CENTER", "CENTER", "CENTER")

		ttHeaderFont:SetFont(GameTooltipHeaderText:GetFont())
		ttRegFont:SetFont(GameTooltipText:GetFont())
		tooltip:SetHeaderFont(ttHeaderFont)
		tooltip:SetFont(ttRegFont)

		tooltip:SmartAnchorTo(self)
		--tooltip:SetAutoHideDelay(DB.DataText.Confederation.ToolTipAutoHide, self)
		tooltip:SetAutoHideDelay(2, self)
		tooltip:SetScript("OnShow", function(ttskinself) ttskinself:SetTemplate('Transparent') end)
	end

	local line = tooltip:AddLine()
	local _GuildName = XFG.Confederate:GetName()
	local _LinksCount = XFG.Network.BNet.Links:GetCount()
	tooltip:SetCell(line, 1, format("Confederate: |cffffffff%s|r", _GuildName), ttHeaderFont, "LEFT", 2)
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, format("Active BNet Links: |cffffffff%d|r", _LinksCount), ttHeaderFont, "LEFT", 2)

	line = tooltip:AddLine()
	line = tooltip:AddLine()
	line = tooltip:AddHeader()

	line = tooltip:SetCell(line, 1, format('%sArea 52', format(IconTokenString, 463451)))
	line = tooltip:SetCell(line, 2, format('%sProudmoore', format(IconTokenString, 2565243)))
	line = tooltip:SetCell(line, 3, format('%sProudmoore', format(IconTokenString, 463451)))
	line = tooltip:AddLine()
	tooltip:AddSeparator()
	line = tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Link in XFG.Network.BNet.Links:Iterator() do
			local _FromRealm = _Link:GetFromRealm()
			local _FromFaction = _Link:GetFromFaction()
			local _ToRealm = _Link:GetToRealm()
			local _ToFaction = _Link:GetToFaction()

			if(_FromRealm:GetName() == 'Area 52') then
				tooltip:SetCell(line, 1, format("|cffffffff%s|r", _Link:GetFromUnitName()))
			elseif(_ToRealm:GetName() == 'Area 52') then
				tooltip:SetCell(line, 1, format("|cffffffff%s|r", _Link:GetToUnitName()))
			end

			if(_FromRealm:GetName() == 'Proudmoore' and _FromFaction:GetName() == 'Alliance') then
				tooltip:SetCell(line, 2, format("|cffffffff%s|r", _Link:GetFromUnitName()))
			elseif(_ToRealm:GetName() == 'Proudmoore' and _ToFaction:GetName() == 'Alliance') then
				tooltip:SetCell(line, 2, format("|cffffffff%s|r", _Link:GetToUnitName()))
			end

			if(_FromRealm:GetName() == 'Proudmoore' and _FromFaction:GetName() == 'Horde') then
				tooltip:SetCell(line, 3, format("|cffffffff%s|r", _Link:GetFromUnitName()))
			elseif(_ToRealm:GetName() == 'Proudmoore' and _ToFaction:GetName() == 'Horde') then
				tooltip:SetCell(line, 3, format("|cffffffff%s|r", _Link:GetToUnitName()))
			end
			
			line = tooltip:AddLine()
		end
	end

	tooltip:Show()
end

DT:RegisterDatatext(XFG.DataText.Links.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, nil, nil, OnEnter)