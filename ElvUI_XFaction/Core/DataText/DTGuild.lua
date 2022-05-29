local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'
local QT = LibStub('LibQTip-1.0')

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
local ActiveString = "|cff00FF00Active|r"
local InactiveString = "|cffFF0000Inactive|r"

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

local _Initialized = false
local function Initialize()
	if(_Initialized == false) then

		_Initialized = true
	end
end

local list_sort = {
	TOONNAME = function(a, b)
		if not a.name or not b.name then return false end
		return a.name < b.name
	end,
	LEVEL =	function(a, b)
		if not a.level or not b.level then
			return false
		elseif a.level < b.level then
			return true
		elseif a.level > b.level then
			return false
		else  -- TOONNAME
			return a.name < b.name
		end
	end,
	RANKINDEX =	function(a, b)
		if not a.rankIndex or not b.rankIndex then
			return false
		elseif a.rankIndex > b.rankIndex then
			return true
		elseif a.rankIndex < b.rankIndex then
			return false
		else -- TOONNAME
			return a.name < b.name
		end
	end,
	ZONENAME = function(a, b)
		if not a.zone or not b.zone then
			return false
		elseif a.zone < b.zone then
			return true
		elseif a.zone > b.zone then
			return false
		else -- TOONNAME
			return a.name < b.name
		end
	end,
	revTOONNAME	= function(a, b)
		if a.name or not b.name then return false end
		return a.name > b.name
	end,
	revLEVEL = function(a, b)
		if not a.level or not b.level then
			return false
		elseif a.level > b.level then
			return true
		elseif a.level < b.level then
			return false
		else  -- TOONNAME
			return a.name < b.name
		end
	end,
	revRANKINDEX = function(a, b)
		if not a.rankIndex or not b.rankIndex then
			return false
		elseif a.rankIndex < b.rankIndex then
			return true
		elseif a.rankIndex > b.rankIndex then
			return false
		else -- TOONNAME
			return a.name < b.name
		end
	end,
	revZONENAME	= function(a, b)
		if not a.zone or not b.zone then
			return false
		elseif a.zone > b.zone then
			return true
		elseif a.zone < b.zone then
			return false
		else -- TOONNAME
			return a.name < b.name
		end
	end
}

local function OnEnable(self, event, ...)
	DT:ForceUpdate_DataText(ObjectName)
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

local function Presort()
	local _PresortedList = {}
	for _, _Unit in XFG.Guild:Iterator() do

		local _Name = _Unit:GetName()
		if(_Unit:IsAlt() and _Unit:GetMainName() ~= nil) then
			_Name = _Name .. " (" .. _Unit:GetMainName() .. ")"
		end

		local _Race = _Unit:GetRace()
		local _Team = _Unit:GetTeam()
		local _Rank = _Unit:GetRank()
		local _Class = _Unit:GetClass()
		local _Faction = _Unit:GetFaction()

		local _UnitData = {
			Faction = _Faction:GetIconID(),
			Level = _Unit:GetLevel(),
			Name = _Name,
			Race = _Race:GetName(),
			Realm = _Unit:GetRealmName(),
			Guild = _Unit:GetGuildName(),
			Team = _Team:GetName(),
			Rank = _Rank:GetName(),
			Zone = _Unit:GetZone(),
			Class = _Class:GetAPIName()
		}

		table.insert(_PresortedList, _UnitData)
	end
	return _PresortedList
end

local function OnEnter(self)
	LDB_ANCHOR = self

	if QT:IsAcquired(ObjectName) then
		tooltip:Clear()
	else
		-- Faction, Level, Spec, Name, Covenant, Race, Realm, Guild, Team, Rank, Zone, Prof1, Prof2
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
	
	line = tooltip:SetCell(line, 2, "Level")
	line = tooltip:SetCell(line, 4, "Name")	
	line = tooltip:SetCell(line, 6, "Race")	
	line = tooltip:SetCell(line, 7, "Realm")
	line = tooltip:SetCell(line, 8, "Guild")
	line = tooltip:SetCell(line, 9, "Team")
	line = tooltip:SetCell(line, 10, "Rank")
	line = tooltip:SetCell(line, 11, "Zone")	
	tooltip:AddSeparator()	

	if(XFG.Initialized) then
		local _List = Presort()
		sort(_List, function(a, b) return a.Name < b.Name end)

		XFG:DataDumper(LogCategory, _List)

		for _, _UnitData in ipairs(_List) do
			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, format('%s', format(IconTokenString, _UnitData.Faction)))
			tooltip:SetCell(line, 2, format("|cffffffff%d|r", _UnitData.Level))
			--tooltip:SetCell(line, 3, format('%s', format(IconTokenString, _SpecIconID)))
			tooltip:SetCell(line, 4, ClassColorString(_UnitData.Name, _UnitData.Class))
			--tooltip:SetCell(line, 5, format('%s', format(IconTokenString, _CovenantIconID)))
			tooltip:SetCell(line, 6, format("|cffffffff%s|r", _UnitData.Race))
			tooltip:SetCell(line, 7, format("|cffffffff%s|r", _UnitData.Realm))
			tooltip:SetCell(line, 8, format("|cffffffff%s|r", _UnitData.Guild))
			tooltip:SetCell(line, 9, format("|cffffffff%s|r", _UnitData.Team))
			tooltip:SetCell(line, 10, format("|cffffffff%s|r", _UnitData.Rank))
			tooltip:SetCell(line, 11, format("|cffffffff%s|r", _UnitData.Zone))
			--tooltip:SetCell(line, 12, format('%s', format(IconTokenString, _IconID)))
			--tooltip:SetCell(line, 13, format('%s', format(IconTokenString, _IconID)))
		end
	end

	tooltip:UpdateScrolling(200)
	tooltip:Show()
end

local function OnClick(self, button)
	--if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

DT:RegisterDatatext(XFG.DataText.Guild.Name, XFG.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, OnEnable, OnClick, OnEnter)