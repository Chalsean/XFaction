local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTGuild'
local CombatLockdown = InCombatLockdown

DTGuild = Object:newChildConstructor()
local LDB_ANCHOR

function DTGuild:new()
	local object = DTGuild.parent.new(self)
    object.__name = ObjectName
	object.headerFont = nil
	object.regularFont = nil
	object.ldbObject = nil
	object.tooltip = nil
	object.isReverseSort = false
	object.sortColumn = nil    
    return object
end

function DTGuild:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTGUILD_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTGUILD_NAME'],
		    OnEnter = function(this) XFG.DataText.Guild:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Guild:OnLeave(this) end,
			OnClick = function(this, button) XFG.DataText.Guild:OnClick(this, button) end,
		})
		LDB_ANCHOR = self.ldbObject
		self:SetFont()
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTGuild:SetFont()
	self.headerFont = CreateFont('headerFont')
	self.headerFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize, 'OUTLINE')
	self.headerFont:SetTextColor(0.4,0.78,1)
	self.regularFont = CreateFont('regularFont')
	self.regularFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize, 'OUTLINE')
	self.regularFont:SetTextColor(255,255,255)
end

function DTGuild:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
		XFG:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
		XFG:Debug(ObjectName, '  isReverseSort (' .. type(self.isReverseSort) .. '): ' .. tostring(self.isReverseSort))
		XFG:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
		XFG:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
	end
end

function DTGuild:IsReverseSort(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self.isReverseSort = inBoolean
	end
	return self.isReverseSort
end

function DTGuild:GetSort()
	return self.sortColumn == nil and self:SetSort(XFG.Config.DataText.Guild.Sort) or self.sortColumn
end

function DTGuild:SetSort(inColumnName)
	assert(type(inColumnName) == 'string')
	self.sortColumn = inColumnName
	return self:GetSort()
end

local function PreSort()
	local list = {}
	for _, unit in XFG.Confederate:Iterator() do
		local unitData = {}

		unitData.Level = unit:GetLevel()
		unitData.Realm = unit:GetRealm():GetName()
		unitData.Guild = unit:GetGuild():GetName()		
		unitData.Name = unit:GetName()
		unitData.UnitName = unit:GetUnitName()
		unitData.Note = unit:GetNote()
		unitData.GUID = unit:GetGUID()
		unitData.Achievement = unit:GetAchievementPoints()
		unitData.Rank = unit:GetRank()
		unitData.ItemLevel = unit:GetItemLevel()	
		unitData.Race = unit:GetRace():GetLocaleName()
		unitData.Team = unit:GetTeam():GetName()
		unitData.Class = unit:GetClass():GetHex()
		unitData.Faction = unit:GetFaction():GetIconID()
		unitData.PvP = unit:GetPvP()

		if(unit:HasRaidIO()) then
			unitData.Raid = unit:GetRaidIO():GetRaid()
			unitData.Dungeon = unit:GetRaidIO():GetDungeon()			
		end

		if(unit:HasVersion()) then
			unitData.Version = unit:GetVersion():GetKey()
		else
			unitData.Version = '0.0.0'
		end

		if(unit:IsAlt() and unit:HasMainName() and XFG.Config.DataText.Guild.Main) then
			unitData.Name = unit:GetName() .. ' (' .. unit:GetMainName() .. ')'
		end

		if(unit:HasSpec()) then
			unitData.Spec = unit:GetSpec():GetIconID()
		end

		if(unit:HasProfession1()) then
			unitData.Profession1 = unit:GetProfession1():GetIconID()
		end

		if(unit:HasProfession2()) then
			unitData.Profession2 = unit:GetProfession2():GetIconID()
		end

		if(unit:HasZone()) then
			unitData.Zone = unit:GetZone():GetLocaleName()
		else
			unitData.Zone = unit:GetZoneName()
		end

		list[#list + 1] = unitData
	end
	return list
end

local function SetSortColumn(_, inColumnName)
	if(XFG.DataText.Guild:GetSort() == inColumnName and XFG.DataText.Guild:IsReverseSort()) then
		XFG.DataText.Guild:IsReverseSort(false)
	elseif(XFG.DataText.Guild:GetSort() == inColumnName) then
		XFG.DataText.Guild:IsReverseSort(true)
	else
		XFG.DataText.Guild:SetSort(inColumnName)
		XFG.DataText.Guild:IsReverseSort(false)
	end
	XFG.DataText.Guild:OnEnter(LDB_ANCHOR)
end

local function LineClick(_, inUnitGUID, inMouseButton)
	local unit = XFG.Confederate:Get(inUnitGUID)
	local link = unit:GetLink()
	if(link == nil) then return end

	if(inMouseButton == 'RightButton' and IsShiftKeyDown()) then
 		C_PartyInfo.InviteUnit(unit:GetUnitName())
	elseif(inMouseButton == 'RightButton' and IsControlKeyDown()) then
		C_PartyInfo.RequestInviteFromUnit(unit:GetUnitName())
 	else
		SetItemRef(link, unit:GetName(), inMouseButton)
	end
end

function DTGuild:RefreshBroker()
	if(XFG.Initialized) then
		local text = ''  
		if(XFG.Config.DataText.Guild.Label) then
			text = XFG.Lib.Locale['GUILD'] .. ': '
		end
		text = format('%s|cff3CE13F%d', text, XFG.Confederate:GetCount())
		self.ldbObject.text = text
	end
end

function DTGuild:GetBroker()
	return self.ldbObject
end

function DTGuild:OnEnter(this)
	if(not XFG.Initialized) then return end
	if(CombatLockdown()) then return end

	local orderEnabled = {}
	XFG.Cache.DTGuildTotalEnabled = 0
	XFG.Cache.DTGuildTextEnabled = 0
	for columnName, isEnabled in pairs (XFG.Config.DataText.Guild.Enable) do
		if(isEnabled) then
			local orderKey = columnName .. 'Order'
			local alignmentKey = columnName .. 'Alignment'

			if(XFG.Config.DataText.Guild.Order[orderKey] ~= 0) then
				XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled + 1
				local index = tostring(XFG.Config.DataText.Guild.Order[orderKey])
				orderEnabled[index] = {
					ColumnName = columnName,
					Alignment = string.upper(XFG.Config.DataText.Guild.Alignment[alignmentKey]),
					Icon = (columnName == 'Spec' or columnName == 'Profession' or columnName == 'Faction'),
				}
				if(not orderEnabled[index].Icon) then
					XFG.Cache.DTGuildTextEnabled = XFG.Cache.DTGuildTextEnabled + 1
				end
			end
		end		
	end
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XFG.Lib.QT:Acquire(ObjectName)

		for i = 1, XFG.Cache.DTGuildTotalEnabled do
			self.tooltip:AddColumn(orderEnabled[tostring(i)].Alignment)
		end
		
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function() DTGuild:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
		self.tooltip:SetFrameStrata('FULLSCREEN_DIALOG')
	end

	self.tooltip:Clear()
	local line = self.tooltip:AddLine()
	
	if(XFG.Config.DataText.Guild.GuildName and XFG.Cache.DTGuildTotalEnabled > 4) then
		local guildName = XFG.Player.Guild:GetName()
		local guild = XFG.Guilds:GetByRealmGuildName(XFG.Player.Realm, guildName)
		guildName = guildName .. ' <' .. guild:GetInitials() .. '>'
		self.tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_GUILD'], guildName), self.headerFont, 'LEFT', 4)
	end

	if(XFG.Config.DataText.Guild.Confederate and XFG.Cache.DTGuildTotalEnabled > 8) then
		self.tooltip:SetCell(line, 6, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], XFG.Confederate:GetName()), self.headerFont, 'LEFT', -1)	
	end

	if(XFG.Config.DataText.Guild.GuildName or XFG.Config.DataText.Guild.Confederate or XFG.Config.DataText.Guild.MOTD) then
		line = self.tooltip:AddLine()
		self.tooltip:AddSeparator()
		line = self.tooltip:AddLine()		
	end

	if(XFG.Config.DataText.Guild.MOTD and XFG.Cache.DTGuildTotalEnabled > 8) then
		local motd = GetGuildRosterMOTD()
		local lineWords = ''
		local lineLength = XFG.Cache.DTGuildTextEnabled * 15
		if(motd ~= nil) then
			local words = string.Split(motd, ' ')		
			for _, word in pairs (words) do
				if(strlen(lineWords .. ' ' .. word) < lineLength) then
					lineWords = lineWords .. ' ' .. word
				else
					self.tooltip:SetCell(line, 1, format('|cffffffff%s|r', lineWords), self.regularFont, 'LEFT', -1)
					line = self.tooltip:AddLine()
					lineWords = ''				
				end
			end
		end
		if(strlen(lineWords) > 0) then
			self.tooltip:SetCell(line, 1, format('|cffffffff%s|r', lineWords), self.regularFont, 'LEFT', -1)
			line = self.tooltip:AddLine()
		end
		line = self.tooltip:AddLine()
	end
	line = self.tooltip:AddLine()
	
	line = self.tooltip:AddHeader()
	for i = 1, XFG.Cache.DTGuildTotalEnabled do
		local columnName = orderEnabled[tostring(i)].ColumnName
		if(not orderEnabled[tostring(i)].Icon) then
			line = self.tooltip:SetCell(line, i, XFG.Lib.Locale[string.upper(columnName)], self.headerFont, 'CENTER')
		end
		self.tooltip:SetCellScript(line, i, 'OnMouseUp', SetSortColumn, columnName)
	end
	self.tooltip:AddSeparator()

	if(XFG.Initialized) then

		local list = PreSort()
		sort(list, function(a, b) if(XFG.DataText.Guild:IsReverseSort()) then return a[XFG.DataText.Guild:GetSort()] > b[XFG.DataText.Guild:GetSort()] 
																	     else return a[XFG.DataText.Guild:GetSort()] < b[XFG.DataText.Guild:GetSort()] end end)

		for _, unitData in ipairs (list) do
			line = self.tooltip:AddLine()

			for i = 1, XFG.Cache.DTGuildTotalEnabled do
				local columnName = orderEnabled[tostring(i)].ColumnName
				local cellValue = ''
				if(orderEnabled[tostring(i)].Icon) then
					if(columnName == 'Profession') then
						if(unitData.Profession1 ~= nil) then
							cellValue = format('%s', format(XFG.Icons.String, unitData.Profession1))
						end
						if(unitData.Profession2 ~= nil) then
							cellValue = cellValue .. ' ' .. format('%s', format(XFG.Icons.String, unitData.Profession2))
						end
					elseif(unitData[columnName] ~= nil) then
						cellValue = format('%s', format(XFG.Icons.String, unitData[columnName]))
					end
				elseif(columnName == 'Name') then
					cellValue = format('|cff%s%s|r', unitData.Class, unitData.Name)
				elseif(unitData[columnName] ~= nil) then
					cellValue = format('|cffffffff%s|r', unitData[columnName])
				end
				self.tooltip:SetCell(line, i, cellValue, self.regularFont)
			end

			self.tooltip:SetLineScript(line, "OnMouseUp", LineClick, unitData.GUID)
		end
	end

	self.tooltip:UpdateScrolling(XFG.Config.DataText.Guild.Size)
	self.tooltip:Show()
end

function DTGuild:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
	    return
	else
        XFG.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end

function DTGuild:OnClick(this, inButton)
	if(InCombatLockdown()) then return end
	if(inButton == 'LeftButton') then
		ToggleGuildFrame()
	elseif(inButton == 'RightButton') then
		if not InterfaceOptionsFrame or not InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Show()
			InterfaceOptionsFrame_OpenToCategory(XFG.Name)
		else
			InterfaceOptionsFrame:Hide()
		end
	end
end