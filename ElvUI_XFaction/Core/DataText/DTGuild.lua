local EKX, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local QT = LibStub('LibQTip-1.0')
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'

DTGuild = {}

function DTGuild:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Key = nil
		self._Tooltip = nil
        self._Initialized = false
		self._Enabled = true
    end

    return Object
end

function DTGuild:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function DTGuild:Initialize()
    if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		--self._Tooltip = CreateFrame("GameTooltip", "DTGuildX_Tooltip", UIParent, "GameTooltipTemplate")
		--self._Tooltip:SetOwner(DT)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function DTGuild:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Enabled = inBoolean
    end
    return self._Enabled
end

function DTGuild:Print()
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function DTGuild:GetKey()
    return self._Key
end

function DTGuild:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function DTGuild:CreateTooltip()
	EKX:Debug(LogCategory, "got here yo")
end

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

-- Setup the Title Font. 14
local ssTitleFont = CreateFont("ssTitleFont")
ssTitleFont:SetTextColor(1,0.823529,0)
ssTitleFont:SetFont(GameTooltipText:GetFont(), 14)

-- Setup the Header Font. 12
local ssHeaderFont = CreateFont("ssHeaderFont")
ssHeaderFont:SetTextColor(1,0.823529,0)
ssHeaderFont:SetFont(GameTooltipHeaderText:GetFont(), 12)

-- Setup the Regular Font. 12
local ssRegFont = CreateFont("ssRegFont")
ssRegFont:SetTextColor(1,0.823529,0)
ssRegFont:SetFont(GameTooltipText:GetFont(), 12)

function DTGuild:OnEnable()



	--self:SecureHook('AddUnit', 'OnEvent', true)

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

local function GetTipAnchor(frame, direction, parentTT)
	if not frame then return end
	local f,u,i,H,h,v,V = {frame:GetCenter()},{},0;
	if f[1]==nil or ns.ui.center[1]==nil then
		return "LEFT";
	end
	h = (f[1]>ns.ui.center[1] and "RIGHT") or "LEFT";
	v = (f[2]>ns.ui.center[2] and "TOP") or "BOTTOM";
	u[4]=ns.ui.center[1]/4; u[5]=ns.ui.center[2]/4; u[6]=(ns.ui.center[1]*2)-u[4]; u[7]=(ns.ui.center[2]*2)-u[5];
	H = (f[1]>u[6] and "RIGHT") or (f[1]<u[4] and "LEFT") or "";
	V = (f[2]>u[7] and "TOP") or (f[2]<u[5] and "BOTTOM") or "";
	if parentTT then
		local p,ph,pv,pH,pV = {parentTT:GetCenter()};
		ph,pv = (p[1]>ns.ui.center[1] and "RIGHT") or "LEFT", (p[2]>ns.ui.center[2] and "TOP") or "BOTTOM";
		pH = (p[1]>u[6] and "RIGHT") or (p[1]<u[4] and "LEFT") or "";
		pV = (p[2]>u[7] and "TOP") or (p[2]<u[5] and "BOTTOM") or "";
		if direction=="horizontal" then
			return pV..ph, parentTT, pV..(ph=="LEFT" and "RIGHT" or "LEFT"), ph=="LEFT" and i or -i, 0;
		end
		return pv..pH, parentTT, (pv=="TOP" and "BOTTOM" or "TOP")..pH, 0, pv=="TOP" and i or -i;
	else
		if direction=="horizontal" then
			return V..h, frame, V..(h=="LEFT" and "RIGHT" or "LEFT"), h=="LEFT" and i or -i, 0;
		end
		return v..H, frame, (v=="TOP" and "BOTTOM" or "TOP")..H, 0, v=="TOP" and i or -i;
	end
end

function DTGuild:OnEnter(self)
	-- LDB_ANCHOR = self
	tt = ns.acquireTooltip({ttName, ttColumns , "LEFT", "RIGHT"},{true},{self})

	if otooltip4 ~= nil then
		if QT:IsAcquired(ObjectName) then otooltip4:Clear() end
		otooltip4:Hide()
		QT:Release(otooltip4)
		otooltip4 = nil
	end
	otooltip4 = QT:Acquire(ObjectName, 5, "LEFT", "CENTER", "LEFT", "LEFT", "RIGHT")
	--otooltip4:SetBackdropColor(0,0,0,1)
	otooltip4:SetHeaderFont(ssHeaderFont)
	otooltip4:SetFont(ssRegFont)
	otooltip4:ClearAllPoints()
	otooltip4:SetClampedToScreen(false)
	otooltip4:SetPoint("CENTER",UIParent,0,200)
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

	otooltip4:Show()
end

function DTGuild:OnClick(self, button)
	--if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end


end

DT:RegisterDatatext('Guild (X)', EKX.Category, nil, nil, DTGuild.OnEnable, DTGuild.OnClick, DTGuild.OnEnter)