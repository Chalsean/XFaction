local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'DTBridge'
local LogCategory = 'DTBridge'

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
		local _BridgeCount = 0
		for _, _Friend in XFG.Network.BNet.Friends:Iterator() do
			if(_Friend:IsRunningAddon()) then
				_BridgeCount = _BridgeCount + 1
			end
		end
		self.text:SetFormattedText(_BridgeCount)
	end
end

local function OnEnter(self)

	LDB_ANCHOR = self	

	if XFG.Lib.QT:IsAcquired(ObjectName) then
		tooltip:Clear()
	else
		tooltip = XFG.Lib.QT:Acquire(ObjectName, 3, "LEFT", "LEFT", "LEFT")

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
	tooltip:SetCell(line, 1, format("Guild: |cffffffff%s|r", _GuildName), ttHeaderFont, "LEFT", 2)
	tooltip:SetCell(line, 3, 'Bridges', ttHeaderFont, "RIGHT")

	line = tooltip:AddLine()
	line = tooltip:AddLine()
	line = tooltip:AddHeader()

	line = tooltip:SetCell(line, 2, format('%sProudmoore', format(IconTokenString, 2565243)))
	line = tooltip:SetCell(line, 3, format('%sProudmoore', format(IconTokenString, 463451)))
	line = tooltip:SetCell(line, 1, format('%sArea 52', format(IconTokenString, 463451)))
	line = tooltip:AddLine()
	tooltip:AddSeparator()
	line = tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Friend in XFG.Network.BNet.Friends:Iterator() do
			if(_Friend:IsRunningAddon()) then
				local _Target = _Friend:GetTarget()
				local _TargetRealm = _Target:GetRealm()
				local _Name = _Friend:GetTag() ~= nil and _Friend:GetTag() or _Friend:GetName()
				tooltip:SetCell(line, 2, format("|cffffffff%s|r", XFG.Player.Account.battleTag))
				if(_TargetRealm:GetName() == 'Area 52') then
					tooltip:SetCell(line, 1, format("|cffffffff%s|r", _Name))
				else
					tooltip:SetCell(line, 3, format("|cffffffff%s|r", _Name))
				end
				line = tooltip:AddLine()
			end
		end
	end

	tooltip:Show()
end

DT:RegisterDatatext(XFG.DataText.Bridge.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, nil, nil, OnEnter)