local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'

local tooltip
local LDB_ANCHOR

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
	for _, _Unit in XFG.Confederate:Iterator() do
		local _UnitData = {}
		local _UnitRealm = _Unit:GetRealm()
		local _UnitGuild = _Unit:GetGuild()

		_UnitData[XFG.DataText.Guild.ColumnNames.LEVEL] = _Unit:GetLevel()
		_UnitData[XFG.DataText.Guild.ColumnNames.REALM] = _UnitRealm:GetName()
		_UnitData[XFG.DataText.Guild.ColumnNames.GUILD] = _UnitGuild:GetName()
		_UnitData[XFG.DataText.Guild.ColumnNames.ZONE] = _Unit:GetZone()
		_UnitData[XFG.DataText.Guild.ColumnNames.NAME] = _Unit:GetName()
		_UnitData.GUID = _Unit:GetGUID()
		if(_Unit:IsAlt() and _Unit:HasMainName()) then
			_UnitData[XFG.DataText.Guild.ColumnNames.NAME] = _Unit:GetName() .. " (" .. _Unit:GetMainName() .. ")"
		end

		if(_Unit:HasRace()) then
			local _Race = _Unit:GetRace()
			_UnitData[XFG.DataText.Guild.ColumnNames.RACE] = _Race:GetName()
		else
			_UnitData[XFG.DataText.Guild.ColumnNames.RACE] = '?'
		end

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

local function LineClick(_, inUnitGUID, inMouseButton)
	local _Unit = XFG.Confederate:GetUnit(inUnitGUID)
	local _UnitName = _Unit:GetUnitName()

	local _UnitFaction = _Unit:GetFaction()
	local _PlayerFaction = XFG.Player.Unit:GetFaction()

	if inMouseButton == 'LeftButton' then
		if IsShiftKeyDown() then
			-- Who
			SetItemRef('player:' .. _UnitName, format('|Hplayer:%1$s|h[%1$s]|h', _UnitName), 'LeftButton') 
		elseif(_UnitFaction:Equals(_PlayerFaction)) then
			-- Whisper		
			SetItemRef('player:' .. _UnitName, format('|Hplayer:%1$s|h[%1$s]|h', _UnitName), 'LeftButton')
		end		
	elseif inMouseButton == 'RightButton' then
		if IsShiftKeyDown() then
			-- Invite
			C_PartyInfo.InviteUnit(inUnitName)
		else
			-- Menu
			SetItemRef('player:' .. _UnitName, format('|Hplayer:%1$s|h[%1$s]|h', _UnitName), 'LeftButton')
		end
	end
end

local function OnEvent(self, event, ...)
	if(XFG.Initialized and event == 'ELVUI_FORCE_UPDATE') then
		if (not self.text) then
			local text = self:CreateFontString(nil, 'OVERLAY')
			text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
			text:SetFormattedText('N/A')
			self.text = text
		end

		local _UnitCount = XFG.Confederate:GetNumberOfUnits()
		self.text:SetFormattedText(format('|cff3CE13F%d', _UnitCount))
	end
end

function OnEnter(self)
	LDB_ANCHOR = self	

	if XFG.Lib.QT:IsAcquired(ObjectName) then
		tooltip:Clear()
	else
		-- Faction, Covenant, Prof1, Prof2, Spec, Name, Race, Level, Realm, Guild, Team, Zone, Note, Rank
		tooltip = XFG.Lib.QT:Acquire(ObjectName, 13, "RIGHT", "CENTER", "CENTER", "LEFT", "CENTER", "LEFT", "CENTER", "CENTER", "LEFT", "LEFT", "CENTER", "RIGHT", "LEFT")

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
	local _ConfederateName = XFG.Confederate:GetName()
	local _GuildName = XFG.Player.Guild:GetName()
	local _Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildName)
	_GuildName = _GuildName .. ' <' .. _Guild:GetShortName() .. '>'
	tooltip:SetCell(line, 1, format("Guild: |cffffffff%s|r", _GuildName), ttHeaderFont, "LEFT", 4)
	tooltip:SetCell(line, 6, format("Confederate: |cffffffff%s|r", _ConfederateName), ttHeaderFont, "LEFT", 4)	
	line = tooltip:AddLine()
	line = tooltip:AddLine()

	local _MOTD = GetGuildRosterMOTD()
	local _LineWords = ''
	local _LineLength = 150
	if(_MOTD ~= nil) then
		local _Words = string.Split(_MOTD, ' ')		
		for _, _Word in pairs (_Words) do
			if(strlen(_LineWords .. ' ' .. _Word) < _LineLength) then
				_LineWords = _LineWords .. ' ' .. _Word
			else
				tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), ttHeaderFont, "LEFT", 13)
				line = tooltip:AddLine()
				_LineWords = ''				
			end
		end
	end

	if(strlen(_LineWords) > 0) then
		tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), ttHeaderFont, "LEFT", 13)
		line = tooltip:AddLine()
	end

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

			tooltip:SetLineScript(line, "OnMouseUp", LineClick, _UnitData.GUID)
		end
	end

	tooltip:UpdateScrolling(200)
	tooltip:Show()
end

local function OnClick(self, button)
	--if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

DT:RegisterDatatext(XFG.DataText.Guild.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, OnEnable, OnClick, OnEnter)