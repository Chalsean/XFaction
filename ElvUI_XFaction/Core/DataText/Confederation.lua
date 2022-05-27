local EKX, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'
local QT = LibStub('LibQTip-1.0')

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
local ActiveString = "|cff00FF00Active|r"
local InactiveString = "|cffFF0000Inactive|r"

local tooltip
local LDB_ANCHOR

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



local _Initialized = false
local function Initialize()
	if(_Initialized == false) then

		_Initialized = true
	end
end

local function OnEnable(self, event, ...)
	DT:ForceUpdate_DataText(ObjectName)
end

local function OnEvent(self, event, ...)
	if(EKX.Initialized and event == 'ELVUI_FORCE_UPDATE') then
		if (not self.text) then
			local text = self:CreateFontString(nil, 'OVERLAY')
			text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
			text:SetFormattedText('N/A')
			self.text = text
		end

		local _UnitCount = EKX.Guild:GetNumberOfUnits()
		self.text:SetFormattedText(format('|cff3CE13F%d', _UnitCount))
	end
end

local function OnEnter(self)
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
	local _GuildName = EKX.Guild:GetName()
	tooltip:SetCell(line, 1, format("Guild: |cffffffff%s|r", _GuildName), ttHeaderFont, "LEFT", 4)

	line = tooltip:AddLine()
	line = tooltip:AddLine()

	line = tooltip:AddHeader()
	
	line = tooltip:SetCell(line, 4, "Name")	
	line = tooltip:SetCell(line, 6, "Race")
	line = tooltip:SetCell(line, 2, "Level")
	line = tooltip:SetCell(line, 7, "Realm")
	line = tooltip:SetCell(line, 8, "Guild")
	line = tooltip:SetCell(line, 9, "Team")
	line = tooltip:SetCell(line, 10, "Rank")
	line = tooltip:SetCell(line, 11, "Zone")	
	tooltip:AddSeparator()

	local _Units = EKX.Guild:GetUnits()
	for _UnitKey, _UnitData in pairs (_Units) do
		line = tooltip:AddLine()

		-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank		
		local _Faction = _UnitData:GetFaction()
		local _FactionIconID = _Faction:GetIconID()
		tooltip:SetCell(line, 1, format('%s', format(IconTokenString, _FactionIconID)))

		if(_UnitData:HasCovenant()) then
			local _Covenant = _UnitData:GetCovenant()
			local _CovenantIconID = _Covenant:GetIconID()
			tooltip:SetCell(line, 5, format('%s', format(IconTokenString, _CovenantIconID)))
		end

		-- if(UnitData.Profession1 ~= nil and UnitData.Profession1.Icon ~= nil) then
		-- 	tooltip:SetCell(line, 12, format('%s', format(IconTokenString, UnitData.Profession1.Icon)))
		-- end
		-- if(UnitData.Profession2 ~= nil and UnitData.Profession2.Icon ~= nil) then
		-- 	tooltip:SetCell(line, 13, format('%s', format(IconTokenString, UnitData.Profession2.Icon)))
		-- end

		if(_UnitData:HasSpec()) then
			local _Spec = _UnitData:GetSpec()
			local _SpecIconID = _Spec:GetIconID()
			tooltip:SetCell(line, 3, format('%s', format(IconTokenString, _SpecIconID)))
		end

		local _Name = _UnitData:GetName()
--		if(_UnitData:IsAlt()) then
--			_Name = _Name .. " (" .. _UnitData:GetMainName() .. ")"
--		end
		local _Class = _UnitData:GetClass()
		local _ClassName = _Class:GetAPIName()
		tooltip:SetCell(line, 4, ClassColorString(_Name, _ClassName))	

		local _Race = _UnitData:GetRace()
		local _RaceName = _Race:GetName()
		tooltip:SetCell(line, 6, format("|cffffffff%s|r", _RaceName))

		local _Level = _UnitData:GetLevel()
		tooltip:SetCell(line, 2, format("|cffffffff%d|r", _Level))

		local _RealmName = _UnitData:GetRealmName()
		tooltip:SetCell(line, 7, format("|cffffffff%s|r", _RealmName))

		local _GuildName = _UnitData:GetGuildName()
		tooltip:SetCell(line, 8, format("|cffffffff%s|r", _GuildName))

		local _TeamName = _UnitData:GetTeamName()
		tooltip:SetCell(line, 9, format("|cffffffff%s|r", _TeamName))

		-- local _Rank = _UnitData:GetRank()
		-- local _RankName = _Rank:GetAltName()
		-- tooltip:SetCell(line, 10, format("|cffffffff%s|r", _RankName))

		local _Zone = _UnitData:GetZone()
		tooltip:SetCell(line, 11, format("|cffffffff%s|r", _Zone))
	end

	tooltip:Show()
end

local function OnClick(self, button)
	--if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

DT:RegisterDatatext(EKX.DataText.Guild.Name, EKX.Category, {'ELVUI_FORCE_UPDATE'}, OnEvent, OnEnable, OnClick, OnEnter)