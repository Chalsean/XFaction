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

local function CountLinks()
	if(XFG.Config.DataText.Links.Area52 and XFG.Config.DataText.Links.OnlyMine == false) then
		return XFG.Network.BNet.Links:GetCount()
	else
		local _Count = 0
		for _, _Link in XFG.Network.BNet.Links:Iterator() do
			if(XFG.Config.DataText.Links.OnlyMine == false or _Link:IsMyLink()) then
				local _FromRealm = _Link:GetFromRealm()
				local _ToRealm = _Link:GetToRealm()
				if(XFG.Config.DataText.Links.Area52 or (_FromRealm:GetName() ~= 'Area 52' and _ToRealm:GetName() ~= 'Area 52')) then
					_Count = _Count + 1
				end
			end
		end
		return _Count
	end
end

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
		self.text:SetFormattedText(CountLinks())
	end
end

local function OnEnter(self)
	if(XFG.Initialized == false) then return end
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
	local _LinksCount = CountLinks()
	tooltip:SetCell(line, 1, format("Confederate: |cffffffff%s|r", _GuildName), ttHeaderFont, "LEFT", 2)
	line = tooltip:AddLine()
	tooltip:SetCell(line, 1, format("Active BNet Links: |cffffffff%d|r", _LinksCount), ttHeaderFont, "LEFT", 2)

	line = tooltip:AddLine()
	line = tooltip:AddLine()
	line = tooltip:AddHeader()

	
	line = tooltip:SetCell(line, 1, format('%sProudmoore', format(IconTokenString, 463451)))
	line = tooltip:SetCell(line, 2, format('%sProudmoore', format(IconTokenString, 2565243)))
	if(XFG.Config.DataText.Links.Area52) then
		line = tooltip:SetCell(line, 3, format('%sArea 52', format(IconTokenString, 463451)))
	end
	
	line = tooltip:AddLine()
	tooltip:AddSeparator()
	line = tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Link in XFG.Network.BNet.Links:Iterator() do
			if((XFG.Config.DataText.Links.OnlyMine and _Link:IsMyLink()) or XFG.Config.DataText.Links.OnlyMine == false) then
				local _FromRealm = _Link:GetFromRealm()
				local _FromFaction = _Link:GetFromFaction()
				local _ToRealm = _Link:GetToRealm()
				local _ToFaction = _Link:GetToFaction()

				if(XFG.Config.DataText.Links.Area52 or (_FromRealm:GetName() ~= 'Area 52' and _ToRealm:GetName() ~= 'Area 52')) then
					local _FromName = format("|cffffffff%s|r", _Link:GetFromName())
					if(_Link:IsMyLink()) then
						_FromName = format("|cffffff00%s|r", _Link:GetFromName())
					end

					if(_FromRealm:GetName() == 'Area 52') then
						tooltip:SetCell(line, 3, _FromName)
					elseif(_ToRealm:GetName() == 'Area 52') then
						tooltip:SetCell(line, 3, format("|cffffffff%s|r", _Link:GetToName()))
					end

					if(_FromRealm:GetName() == 'Proudmoore' and _FromFaction:GetName() == 'Alliance') then
						tooltip:SetCell(line, 2, _FromName)
					elseif(_ToRealm:GetName() == 'Proudmoore' and _ToFaction:GetName() == 'Alliance') then
						tooltip:SetCell(line, 2, format("|cffffffff%s|r", _Link:GetToName()))
					end

					if(_FromRealm:GetName() == 'Proudmoore' and _FromFaction:GetName() == 'Horde') then
						tooltip:SetCell(line, 1, _FromName)
					elseif(_ToRealm:GetName() == 'Proudmoore' and _ToFaction:GetName() == 'Horde') then
						tooltip:SetCell(line, 1, format("|cffffffff%s|r", _Link:GetToName()))
					end
					
					line = tooltip:AddLine()
				end
			end
		end
	end

	tooltip:Show()
end

DT:RegisterDatatext(XFG.DataText.Links.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, nil, nil, OnEnter)