local CON, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local LogCategory = 'DTConfederation'
local DB = E.db.Confederation
local QT = LibStub('LibQTip-1.0')

local IconTokenString = '|T%d:16:16:0:0:64:64:4:60:4:60|t'
local IconNumbersCovenant = {3257748, 3257751, 3257750, 3257749} -- Kyrian, Venthyr, Night Fae, Necrolord
local ActiveString = "|cff00FF00Active|r"
local InactiveString = "|cffFF0000Inactive|r"
local IconNumbersFaction = {
	Alliance = 2565243,
	Horde = 463451
}

local guildInfoString = "%s"
local guildInfoString2 = GUILD..": %d/%d"
local nameString = "|cff%02x%02x%02x%s|r"
local onoteString = "|cff%02x%02x%02x[%s]|r"
local guildTable, guildMotD, lastPanel = {}, ""
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

DB.DataText = {
	Confederation = {
		ToolTipAutoHide = 2
	}
}

local function OnEvent(self, event, ...)

	if(event == 'PLAYER_ENTERING_WORLD') then
		CON:InitializeChannel()		
		CON:InitializeRoster()
		--CON.Comm:Initialize()

		-- Broadcast you have logged in, because only you know your covenant/soulbind
		CON:BroadcastUnitData(DB.Data.Player)

		-- Broadcast a request to everyone for current information
		CON:BroadcastStatus()
	end

	if(event == 'COVENANT_CHOSEN' or event == 'SOULBIND_CHOSEN') then
		UpdatePlayerCovenantSoulbind()
	end

	if(event == 'GUILD_ROSTER_UPDATE' or event == 'PLAYER_GUILD_UPDATE') then
		CON:RefreshLocalGuildRoster()
	end

	if(event == 'GUILD_ROSTER_UPDATE' or event == 'PLAYER_GUILD_UPDATE' or event == 'PLAYER_ENTERING_WORLD') then
		if (not self.text) then
			local text = self:CreateFontString(nil, 'OVERLAY')
			text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
			text:SetFormattedText('N/A')
			self.text = text
		end

		self.text:SetFormattedText(format('|cff00FF98%d', DB.Data.Guild.OnlineMembers))
	end
end

local function OnEnter(self)
	LDB_ANCHOR = self

	if QT:IsAcquired("ConfederationDT") then
		tooltip:Clear()
	else
		-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank
		tooltip = QT:Acquire("ConfederationDT", 11, "RIGHT", "CENTER", "CENTER", "CENTER", "LEFT", "LEFT", "CENTER", "CENTER", "CENTER", "LEFT", "LEFT")

		ttHeaderFont:SetFont(GameTooltipHeaderText:GetFont())
		ttRegFont:SetFont(GameTooltipText:GetFont())
		tooltip:SetHeaderFont(ttHeaderFont)
		tooltip:SetFont(ttRegFont)

		tooltip:SmartAnchorTo(self)
		tooltip:SetAutoHideDelay(DB.DataText.Confederation.ToolTipAutoHide, self)
		tooltip:SetAutoHideDelay(2, self)
		tooltip:SetScript("OnShow", function(ttskinself) ttskinself:SetTemplate('Transparent') end)
	end

	local line = tooltip:AddLine()
	tooltip:SetCell(line, 1, format("Confederation: |cffffffff%s|r", DB.Name), ttHeaderFont, "LEFT", 4)

	line = tooltip:AddLine()
	line = tooltip:AddLine()

	line = tooltip:AddHeader()
	line = tooltip:SetCell(line, 1, "Team")
	line = tooltip:SetCell(line, 2, "Level")
	line = tooltip:SetCell(line, 5, "Name")	
	line = tooltip:SetCell(line, 6, "Race")
	line = tooltip:SetCell(line, 7, "Realm")
	line = tooltip:SetCell(line, 8, "Guild")
	line = tooltip:SetCell(line, 9, "Zone")
	line = tooltip:SetCell(line, 10, "Note")
	line = tooltip:SetCell(line, 11, "Rank")
	tooltip:AddSeparator()

	for TeamKey, TeamValue in PairsByKeys (DB.Data.Teams) do		
		for UnitKey, UnitData in pairs (DB.Data.Guild.Roster) do
			if(TeamKey == UnitData.Team and UnitData.Online == true) then	
				if(UnitData.Name == nil or UnitData.Faction == nil) then
					CON:DataDumper(LogCategory, UnitData)
				end
				line = tooltip:AddLine()

				-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank
				tooltip:SetCell(line, 1, format("|cffffffff%s|r", UnitData.Team))
				tooltip:SetCell(line, 2, format("|cffffffff%d|r", UnitData.Level))
				--CON:Debug(LogCategory, format("unit [%s] faction [%s]", UnitData.Unit, UnitData.Faction))
				if(UnitData.Faction ~= nil) then
					tooltip:SetCell(line, 3, format('%s', format(IconTokenString, IconNumbersFaction[UnitData.Faction])))
				end
				if(UnitData.Covenant ~= nil) then
					tooltip:SetCell(line, 4, format('%s', format(IconTokenString, IconNumbersCovenant[UnitData.Covenant.ID])))
				end
				tooltip:SetCell(line, 5, ClassColorString(UnitData.Name, UnitData.Class))
				tooltip:SetCell(line, 6, format("|cffffffff%s|r", UnitData.Race))
				tooltip:SetCell(line, 7, format("|cffffffff%s|r", UnitData.RealmName))
				tooltip:SetCell(line, 8, format("|cffffffff%s|r", UnitData.GuildName))
				tooltip:SetCell(line, 9, format("|cffffffff%s|r", (UnitData.Zone == nil) and '?' or UnitData.Zone))
				tooltip:SetCell(line, 10, format("|cffffffff%s|r", UnitData.Note))
				tooltip:SetCell(line, 11, format("|cffffffff%s|r", UnitData.GuildRank))
			end
		end
	end

	tooltip:Show()
end

local function OnClick(self, button)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

local events = {
	'GUILD_ROSTER_UPDATE',
	'PLAYER_GUILD_UPDATE',
	'GUILD_MOTD',
	'PLAYER_ENTERING_WORLD',
	'COVENANT_CHOSEN',
	'SOULBIND_ACTIVATED'
}

DT:RegisterDatatext('Confederation (C)', CON.Category, events, OnEvent, nil, OnClick, OnEnter)