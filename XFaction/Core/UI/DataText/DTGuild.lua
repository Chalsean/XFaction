local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTGuild'
local CombatLockdown = InCombatLockdown

DTGuild = XFC.Object:newChildConstructor()
local LDB_ANCHOR

--#region Constructors
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
--#endregion

--#region Initializers
function DTGuild:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTGUILD_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTGUILD_NAME'],
		    OnEnter = function(this) XF.DataText.Guild:OnEnter(this) end,
			OnLeave = function(this) XF.DataText.Guild:OnLeave(this) end,
			OnClick = function(this, button) XF.DataText.Guild:OnClick(this, button) end,
		})
		LDB_ANCHOR = self.ldbObject
		self.headerFont = CreateFont('headerFont')
		self.headerFont:SetTextColor(0.4,0.78,1)
		self.regularFont = CreateFont('regularFont')
		self.regularFont:SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTGuild:PostInitialize()
	XF.DataText.Guild:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Guild:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Guild:RefreshBroker()
end
--#endregion

--#region Print
function DTGuild:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  isReverseSort (' .. type(self.isReverseSort) .. '): ' .. tostring(self.isReverseSort))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Accessors
function DTGuild:GetBroker()
	return self.ldbObject
end

function DTGuild:GetHeaderFont()
	return self.headerFont
end

function DTGuild:GetRegularFont()
	return self.regularFont
end

function DTGuild:RefreshBroker()
	if(XF.Initialized) then
		local text = ''  
		if(XF.Config.DataText.Guild.Label) then
			text = XF.Lib.Locale['GUILD'] .. ': '
		end
		text = format('%s|cff3CE13F%d', text, XFO.Confederate:OnlineCount())
		XF.DataText.Guild:GetBroker().text = text
	end
end
--#endregion

--#region Sorting
function DTGuild:IsReverseSort(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self.isReverseSort = inBoolean
	end
	return self.isReverseSort
end

function DTGuild:GetSort()
	return self.sortColumn == nil and self:SetSort(XF.Config.DataText.Guild.Sort) or self.sortColumn
end

function DTGuild:SetSort(inColumnName)
	assert(type(inColumnName) == 'string')
	self.sortColumn = inColumnName
	return self:GetSort()
end

local function PreSort()
	local list = {}
	for _, unit in XFO.Confederate:Iterator() do
		if(unit:IsOnline()) then
			local unitData = {}

			unitData.Level = unit:GetLevel()
			unitData.Realm = unit:GetGuild():Realm():Name()
			unitData.Guild = unit:GetGuild():Name()		
			unitData.Name = unit:Name()
			unitData.UnitName = unit:GetUnitName()
			unitData.Note = unit:GetNote()
			unitData.GUID = unit:GetGUID()
			unitData.Achievement = unit:GetAchievementPoints()
			unitData.Rank = unit:GetRank()
			unitData.ItemLevel = unit:GetItemLevel()	
			unitData.Race = unit:GetRace():Name()
			if(unit:HasTeam()) then 
				unitData.Team = unit:GetTeam():Name() 
			else
				unitData.Team = 'Unknown'
			end
			unitData.Class = unit:GetClass():Hex()
			unitData.Faction = unit:GetFaction():IconID()
			unitData.PvP = unit:GetPvP()

			if(unit:HasRaiderIO()) then
				unitData.Raid = unit:GetRaiderIO():GetRaid()
				unitData.Dungeon = unit:GetRaiderIO():GetDungeon()			
			end

			if(unit:HasVersion()) then
				unitData.Version = unit:GetVersion():Key()
			else
				unitData.Version = '0.0.0'
			end

			if(unit:IsAlt() and unit:HasMainName() and XF.Config.DataText.Guild.Main) then
				unitData.Name = unit:Name() .. ' (' .. unit:GetMainName() .. ')'
			end

			if(unit:HasSpec()) then
				unitData.Spec = unit:GetSpec():IconID()
			end

			if(unit:HasProfession1()) then
				unitData.Profession1 = unit:GetProfession1():IconID()
			end

			if(unit:HasProfession2()) then
				unitData.Profession2 = unit:GetProfession2():IconID()
			end

			if(unit:HasZone()) then
				unitData.Zone = unit:GetZone():LocaleName()
			else
				unitData.Zone = unit:GetZoneName()
			end

			if(unit:HasMythicKey() and unit:GetMythicKey():HasDungeon()) then
				unitData.MythicKey = unit:GetMythicKey():GetDungeon():Name() .. ' +' .. unit:GetMythicKey():ID()
			end

			list[#list + 1] = unitData
		end
	end
	return list
end

local function SetSortColumn(_, inColumnName)
	if(XF.DataText.Guild:GetSort() == inColumnName and XF.DataText.Guild:IsReverseSort()) then
		XF.DataText.Guild:IsReverseSort(false)
	elseif(XF.DataText.Guild:GetSort() == inColumnName) then
		XF.DataText.Guild:IsReverseSort(true)
	else
		XF.DataText.Guild:SetSort(inColumnName)
		XF.DataText.Guild:IsReverseSort(false)
	end
	XF.DataText.Guild:OnEnter(LDB_ANCHOR)
end
--#endregion

--#region OnEnter
local function LineClick(_, inUnitGUID, inMouseButton)
	local unit = XFO.Confederate:Get(inUnitGUID)
	local link = unit:GetLink()
	if(link == nil) then return end

	if(inMouseButton == 'RightButton' and IsShiftKeyDown()) then
 		C_PartyInfo.InviteUnit(unit:GetUnitName())
	elseif(inMouseButton == 'RightButton' and IsControlKeyDown()) then
		C_PartyInfo.RequestInviteFromUnit(unit:GetUnitName())
 	elseif(inMouseButton == 'LeftButton' or inMouseButton == 'RightButton') then
		SetItemRef(link, unit:Name(), inMouseButton)
	end
end

function DTGuild:OnEnter(this)
	if(not XF.Initialized) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	local orderEnabled = {}
	XF.Cache.DTGuildTotalEnabled = 0
	XF.Cache.DTGuildTextEnabled = 0
	XF:SortGuildColumns()
	for column, isEnabled in pairs (XF.Config.DataText.Guild.Enable) do
		if(isEnabled and XF.Config.DataText.Guild.Order[column] ~= 0 and XF.Config.DataText.Guild.Alignment[column] ~= nil) then
			XF.Cache.DTGuildTotalEnabled = XF.Cache.DTGuildTotalEnabled + 1
			local index = tostring(XF.Config.DataText.Guild.Order[column])
			orderEnabled[index] = {
				ColumnName = column,
				Alignment = string.upper(XF.Config.DataText.Guild.Alignment[column]),
				Icon = (column == 'Spec' or column == 'Profession' or column == 'Faction'),
			}
			if(not orderEnabled[index].Icon) then
				XF.Cache.DTGuildTextEnabled = XF.Cache.DTGuildTextEnabled + 1
			end
		end		
	end
	
	if XF.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)

		for i = 1, XF.Cache.DTGuildTotalEnabled do
			self.tooltip:AddColumn(orderEnabled[tostring(i)].Alignment)
		end
		
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() DTGuild:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
		self.tooltip:SetFrameStrata('FULLSCREEN_DIALOG')
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	
	if(XF.Config.DataText.Guild.GuildName and XF.Cache.DTGuildTotalEnabled > 4) then
		local guildName = XF.Player.Guild:Name()
		guildName = guildName .. ' <' .. XF.Player.Guild:Initials() .. '>'
		self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_GUILD'], guildName), self.headerFont, 'LEFT', 4)
	end

	if(XF.Config.DataText.Guild.Confederate and XF.Cache.DTGuildTotalEnabled > 8) then
		self.tooltip:SetCell(line, 6, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XFO.Confederate:Name()), self.headerFont, 'LEFT', -1)	
	end

	if(XF.Config.DataText.Guild.GuildName or XF.Config.DataText.Guild.Confederate or XF.Config.DataText.Guild.MOTD) then
		line = self.tooltip:AddLine()
		self.tooltip:AddSeparator()
		line = self.tooltip:AddLine()		
	end

	if(XF.Config.DataText.Guild.MOTD and XF.Cache.DTGuildTotalEnabled > 8) then
		local motd = GetGuildRosterMOTD()
		local lineWords = ''
		local lineLength = XF.Cache.DTGuildTextEnabled * 15
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
	--#endregion

	--#region Column Headers
	for i = 1, XF.Cache.DTGuildTotalEnabled do
		local columnName = orderEnabled[tostring(i)].ColumnName
		if(not orderEnabled[tostring(i)].Icon) then
			line = self.tooltip:SetCell(line, i, XF.Lib.Locale[string.upper(columnName)], self.headerFont, 'CENTER')
		end
		self.tooltip:SetCellScript(line, i, 'OnMouseUp', SetSortColumn, columnName)
	end
	self.tooltip:AddSeparator()
	--#endregion

	--#region Populate Table
	if(XF.Initialized) then

		local list = PreSort()
		sort(list, function(a, b) 
			if(XF.DataText.Guild:IsReverseSort()) then
				if(a[XF.DataText.Guild:GetSort()] == nil) then 
					return false
				elseif(b[XF.DataText.Guild:GetSort()] == nil) then
					return true
				else
					return a[XF.DataText.Guild:GetSort()] > b[XF.DataText.Guild:GetSort()]
				end
			else
				if(b[XF.DataText.Guild:GetSort()] == nil) then
					return false
				elseif(a[XF.DataText.Guild:GetSort()] == nil) then
					return true
				else
					return a[XF.DataText.Guild:GetSort()] < b[XF.DataText.Guild:GetSort()]
				end
			end end)

		for _, unitData in ipairs (list) do
			line = self.tooltip:AddLine()

			for i = 1, XF.Cache.DTGuildTotalEnabled do
				local columnName = orderEnabled[tostring(i)].ColumnName
				local cellValue = ''
				if(orderEnabled[tostring(i)].Icon) then
					if(columnName == 'Profession') then
						if(unitData.Profession1 ~= nil) then
							cellValue = format('%s', format(XF.Icons.String, unitData.Profession1))
						end
						if(unitData.Profession2 ~= nil) then
							cellValue = cellValue .. ' ' .. format('%s', format(XF.Icons.String, unitData.Profession2))
						end
					elseif(unitData[columnName] ~= nil) then
						cellValue = format('%s', format(XF.Icons.String, unitData[columnName]))
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
	--#endregion

	self.tooltip:UpdateScrolling(XF.Config.DataText.Guild.Size)
	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function DTGuild:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
	    return
	else
        XF.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion

--#region OnClick
function DTGuild:OnClick(this, inButton)
	if(InCombatLockdown()) then return end
	if(inButton == 'LeftButton') then
		ToggleGuildFrame()
	elseif(inButton == 'RightButton') then
		if not InterfaceOptionsFrame or not InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Show()
			InterfaceOptionsFrame_OpenToCategory(XF.Name)
		else
			InterfaceOptionsFrame:Hide()
		end
	end
end
--#endregion