local EKX, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local LogCategory = 'DTConfederation'
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

function EKX:OnEnable(self, event, ...)

	self:SecureHook('AddUnit', 'OnEvent', true)

	-- if(event == 'GUILD_ROSTER_UPDATE' or event == 'PLAYER_GUILD_UPDATE' or event == 'PLAYER_ENTERING_WORLD') then
	-- 	if (not self.text) then
	-- 		local text = self:CreateFontString(nil, 'OVERLAY')
	-- 		text:SetFont(DataText.Font, DataText.Size, DataText.Flags)
	-- 		text:SetFormattedText('N/A')
	-- 		self.text = text
	-- 	end

	-- 	self.text:SetFormattedText(format('|cff00FF98%d', EKX.Guild:))
	-- end
end

hooksecurefunc(EKX, 'Guild:AddUnit', EKX.OnEnable)
EKX:Info(LogCategory, "Created hook for EKX.Guild.AddUnit")

local function OnEnter(self)
	LDB_ANCHOR = self

	-- if QT:IsAcquired("ConfederationDT") then
	-- 	tooltip:Clear()
	-- else
	-- 	-- Faction, Covenant, Prof1, Prof2, Spec, Name, Race, Level, Realm, Guild, Team, Zone, Note, Rank
	-- 	tooltip = QT:Acquire("ConfederationDT", 13, "RIGHT", "CENTER", "CENTER", "LEFT", "CENTER", "LEFT", "CENTER", "CENTER", "LEFT", "LEFT", "CENTER", "RIGHT", "LEFT")

	-- 	ttHeaderFont:SetFont(GameTooltipHeaderText:GetFont())
	-- 	ttRegFont:SetFont(GameTooltipText:GetFont())
	-- 	tooltip:SetHeaderFont(ttHeaderFont)
	-- 	tooltip:SetFont(ttRegFont)

	-- 	tooltip:SmartAnchorTo(self)
	-- 	tooltip:SetAutoHideDelay(DB.DataText.Confederation.ToolTipAutoHide, self)
	-- 	tooltip:SetAutoHideDelay(2, self)
	-- 	tooltip:SetScript("OnShow", function(ttskinself) ttskinself:SetTemplate('Transparent') end)
	-- end

	-- local line = tooltip:AddLine()
	-- tooltip:SetCell(line, 1, format("Confederation: |cffffffff%s|r", DB.Name), ttHeaderFont, "LEFT", 4)

	-- line = tooltip:AddLine()
	-- line = tooltip:AddLine()

	-- line = tooltip:AddHeader()
	
	-- line = tooltip:SetCell(line, 4, "Name")	
	-- line = tooltip:SetCell(line, 6, "Race")
	-- line = tooltip:SetCell(line, 2, "Level")
	-- line = tooltip:SetCell(line, 7, "Realm")
	-- line = tooltip:SetCell(line, 8, "Guild")
	-- line = tooltip:SetCell(line, 9, "Team")
	-- line = tooltip:SetCell(line, 10, "Rank")
	-- line = tooltip:SetCell(line, 11, "Zone")	
	-- tooltip:AddSeparator()

	-- for TeamKey, TeamValue in PairsByKeys (DB.Data.Teams) do		
	-- 	for UnitKey, UnitData in pairs (DB.Data.Guild.Roster) do
	-- 		if(TeamKey == UnitData.Team and UnitData.Online == true) then	
	-- 			if(UnitData.Name == nil or UnitData.Faction == nil) then
	-- 				EKX:DataDumper(LogCategory, UnitData)
	-- 			end
	-- 			line = tooltip:AddLine()

	-- 			-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank
	-- 			if(UnitData.Faction ~= nil) then
	-- 				tooltip:SetCell(line, 1, format('%s', format(IconTokenString, IconNumbersFaction[UnitData.Faction])))
	-- 			end
	-- 			if(UnitData.Covenant ~= nil) then
	-- 				tooltip:SetCell(line, 5, format('%s', format(IconTokenString, IconNumbersCovenant[UnitData.Covenant.ID])))
	-- 			end
	-- 			if(UnitData.Profession1 ~= nil and UnitData.Profession1.Icon ~= nil) then
	-- 				tooltip:SetCell(line, 12, format('%s', format(IconTokenString, UnitData.Profession1.Icon)))
	-- 			end
	-- 			if(UnitData.Profession2 ~= nil and UnitData.Profession2.Icon ~= nil) then
	-- 				tooltip:SetCell(line, 13, format('%s', format(IconTokenString, UnitData.Profession2.Icon)))
	-- 			end
	-- 			if(UnitData.Spec ~= nil) then
	-- 				tooltip:SetCell(line, 3, format('%s', format(IconTokenString, UnitData.Spec.Icon)))
	-- 			end
	-- 			local Name = UnitData.Name
	-- 			if(UnitData.Alt == true and UnitData.AltName ~= nil) then
	-- 				Name = Name .. " (" .. UnitData.AltName .. ")"
	-- 			end
	-- 			tooltip:SetCell(line, 4, ClassColorString(Name, UnitData.Class))				
	-- 			tooltip:SetCell(line, 6, format("|cffffffff%s|r", UnitData.Race))
	-- 			tooltip:SetCell(line, 2, format("|cffffffff%d|r", UnitData.Level))				
	-- 			tooltip:SetCell(line, 7, format("|cffffffff%s|r", UnitData.RealmName))
	-- 			tooltip:SetCell(line, 8, format("|cffffffff%s|r", UnitData.GuildName))
	-- 			tooltip:SetCell(line, 9, format("|cffffffff%s|r", UnitData.Team))
	-- 			tooltip:SetCell(line, 10, format("|cffffffff%s|r", UnitData.GuildRank))
	-- 			tooltip:SetCell(line, 11, format("|cffffffff%s|r", (UnitData.Zone == nil) and '?' or UnitData.Zone))
	-- 		end
	-- 	end
	-- end

	-- tooltip:Show()
end

local function OnClick(self, button)
	--if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

local events = {
	'PLAYER_ENTERING_WORLD'
}

DT:RegisterDatatext('Confederation (C)', EKX.Category, events, OnEvent, OnEnable, OnClick, OnEnter)