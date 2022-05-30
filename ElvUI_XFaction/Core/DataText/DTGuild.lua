local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'
local QT = LibStub('LibQTip-1.0')

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

local tooltip
local LDB_ANCHOR
XFG.DataText.Guild.Name = 'Guild (X)'
XFG.DataText.Guild.ColumnNames = {
	NAME = 'Name',
	RACE = 'Race',
	LEVEL = 'Level',
	REALM = 'Realm',
	GUILD = 'Guild',
	TEAM = 'Team',
	RANK = 'Rank',
	ZONE = 'Zone'
}
XFG.DataText.Guild.SortColumn = XFG.DataText.Guild.ColumnNames.TEAM
XFG.DataText.Guild.ReverseSort = false

local membScroll = {step=0,stepWidth=5,numLines=15,lines={},lineCols={},slider=false,regionColor={1,.82,0,.11}};

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
	DT:ForceUpdate_DataText(ObjectName)
end

local function PreSort()
	local _List = {}
	for _, _Unit in XFG.Guild:Iterator() do
		local _UnitData = {}

		_UnitData[XFG.DataText.Guild.ColumnNames.LEVEL] = _Unit:GetLevel()
		_UnitData[XFG.DataText.Guild.ColumnNames.REALM] = _Unit:GetRealmName()
		_UnitData[XFG.DataText.Guild.ColumnNames.GUILD] = _Unit:GetGuildName()
		_UnitData[XFG.DataText.Guild.ColumnNames.ZONE] = _Unit:GetZone()
		_UnitData[XFG.DataText.Guild.ColumnNames.NAME] = _Unit:GetName()
		if(_Unit:IsAlt() and _Unit:HasMainName()) then
			_UnitData[XFG.DataText.Guild.ColumnNames.NAME] = _Unit:GetName() .. " (" .. _Unit:GetMainName() .. ")"
		end

		local _Race = _Unit:GetRace()
		_UnitData[XFG.DataText.Guild.ColumnNames.RACE] = _Race:GetName()

		local _Team = _Unit:GetTeam()
		_UnitData[XFG.DataText.Guild.ColumnNames.TEAM] = _Team:GetName()

		local _Rank = _Unit:GetRank()
		_UnitData[XFG.DataText.Guild.ColumnNames.RANK] = _Rank:GetAltName() and _Rank:GetAltName() or _Rank:GetName()

		local _Class = _Unit:GetClass()
		_UnitData.Class = _Class:GetAPIName()

		local _Faction = _Unit:GetFaction()
		_UnitData.Faction = _Faction:GetIconID()

		if(_Unit:HasSpec()) then
			local _Spec = _Unit:GetSpec()
			_UnitData.Spec = _Spec:GetIconID()
		end

		if(_Unit:HasCovenant()) then
			local _Covenant = _Unit:GetCovenant()
			_UnitData.Covenant = _Covenant:GetIconID()
		end

		if(_Unit:HasProfession1()) then
			local _Profession = _Unit:GetProfession1()
			_UnitData.Profession1 = _Profession:GetIconID()
		end

		if(_Unit:HasProfession2()) then
			local _Profession = _Unit:GetProfession2()
			_UnitData.Profession2 = _Profession:GetIconID()
		end

		table.insert(_List, _UnitData)
	end
	return _List
end

local function SetSortColumn(_, inColumnName)
	if(XFG.DataText.Guild.SortColumn == inColumnName and XFG.DataText.Guild.ReverseSort) then
		XFG.DataText.Guild.ReverseSort = false
	elseif(XFG.DataText.Guild.SortColumn == inColumnName) then
		XFG.DataText.Guild.ReverseSort = true
	else
		XFG.DataText.Guild.SortColumn = inColumnName
		XFG.DataText.Guild.ReverseSort = false
	end
	OnEnter(LDB_ANCHOR)
end

local function OnEvent(self, event, ...)
	if(XFG.Initialized and event == 'ELVUI_FORCE_UPDATE') then
		if (not self.text) then
			local text = self:CreateFontString(nil, 'OVERLAY')
			text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
			text:SetFormattedText('N/A')
			self.text = text
		end

		local _UnitCount = XFG.Guild:GetNumberOfUnits()
		self.text:SetFormattedText(format('|cff3CE13F%d', _UnitCount))
	end
end

function OnEnter(self)
	LDB_ANCHOR = self

	if QT:IsAcquired(ObjectName) then
		tooltip:Clear()
	else
		-- Faction, Covenant, Prof1, Prof2, Spec, Name, Race, Level, Realm, Guild, Team, Zone, Note, Rank
		tooltip = QT:Acquire(ObjectName, 13, "RIGHT", "CENTER", "CENTER", "LEFT", "CENTER", "LEFT", "CENTER", "CENTER", "LEFT", "LEFT", "CENTER", "RIGHT", "LEFT")

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
	local _GuildName = XFG.Guild:GetName()
	tooltip:SetCell(line, 1, format("Guild: |cffffffff%s|r", _GuildName), ttHeaderFont, "LEFT", 4)

	line = tooltip:AddLine()
	line = tooltip:AddLine()

	line = tooltip:AddHeader()
	
	line = tooltip:SetCell(line, 2, XFG.DataText.Guild.ColumnNames.LEVEL)
	tooltip:SetCellScript(line, 2, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.LEVEL)
	line = tooltip:SetCell(line, 4, XFG.DataText.Guild.ColumnNames.NAME)	
	tooltip:SetCellScript(line, 4, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.NAME)
	line = tooltip:SetCell(line, 6, XFG.DataText.Guild.ColumnNames.RACE)	
	tooltip:SetCellScript(line, 6, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.RACE)
	line = tooltip:SetCell(line, 7, XFG.DataText.Guild.ColumnNames.REALM)
	tooltip:SetCellScript(line, 7, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.REALM)
	line = tooltip:SetCell(line, 8, XFG.DataText.Guild.ColumnNames.GUILD)
	tooltip:SetCellScript(line, 8, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.GUILD)
	line = tooltip:SetCell(line, 9, XFG.DataText.Guild.ColumnNames.TEAM)
	tooltip:SetCellScript(line, 9, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.TEAM)
	line = tooltip:SetCell(line, 10, XFG.DataText.Guild.ColumnNames.RANK)
	tooltip:SetCellScript(line, 10, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.RANK)
	line = tooltip:SetCell(line, 11, XFG.DataText.Guild.ColumnNames.ZONE)	
	tooltip:SetCellScript(line, 11, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.ZONE)
	tooltip:AddSeparator()

	if(XFG.Initialized) then

		local _List = PreSort()
		sort(_List, function(a, b) if(XFG.DataText.Guild.ReverseSort) then return a[XFG.DataText.Guild.SortColumn] > b[XFG.DataText.Guild.SortColumn] 
																	  else return a[XFG.DataText.Guild.SortColumn] < b[XFG.DataText.Guild.SortColumn] end end)

		for _, _UnitData in ipairs (_List) do
			line = tooltip:AddLine()

			-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank		
			tooltip:SetCell(line, 1, format('%s', format(IconTokenString, _UnitData.Faction)))
			tooltip:SetCell(line, 2, format("|cffffffff%d|r", _UnitData[XFG.DataText.Guild.ColumnNames.LEVEL]))
			if(_UnitData.Spec ~= nil) then tooltip:SetCell(line, 3, format('%s', format(IconTokenString, _UnitData.Spec))) end
			tooltip:SetCell(line, 4, ClassColorString(_UnitData[XFG.DataText.Guild.ColumnNames.NAME], _UnitData.Class))			
			if(_UnitData.Covenant ~= nil) then tooltip:SetCell(line, 5, format('%s', format(IconTokenString, _UnitData.Covenant))) end
			tooltip:SetCell(line, 6, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.RACE]))
			tooltip:SetCell(line, 7, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.REALM]))
			tooltip:SetCell(line, 8, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.GUILD]))
			tooltip:SetCell(line, 9, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.TEAM]))			
			tooltip:SetCell(line, 10, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.RANK]))
			tooltip:SetCell(line, 11, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.ZONE]))
			if(_UnitData.Profession1 ~= nil) then tooltip:SetCell(line, 12, format('%s', format(IconTokenString, _UnitData.Profession1))) end
			if(_UnitData.Profession2 ~= nil) then tooltip:SetCell(line, 13, format('%s', format(IconTokenString, _UnitData.Profession2))) end
		end
	end

	tooltip:UpdateScrolling(200)
	tooltip:Show()
end

local function OnClick(self, button)
	--if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

DT:RegisterDatatext(XFG.DataText.Guild.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, OnEnable, OnClick, OnEnter)