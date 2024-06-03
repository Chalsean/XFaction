local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTGuild'
local CombatLockdown = InCombatLockdown

XFC.DTGuild = XFC.Object:newChildConstructor()
local LDB_ANCHOR

-- Very old code that desperately needs refactoring

--#region Constructors
function XFC.DTGuild:new()
	local object = XFC.DTGuild.parent.new(self)
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
function XFC.DTGuild:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTGUILD_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTGUILD_NAME'],
		    OnEnter = function(this) XFO.DTGuild:OnEnter(this) end,
			OnLeave = function(this) XFO.DTGuild:OnLeave(this) end,
			OnClick = function(this, button) XFO.DTGuild:OnClick(this, button) end,
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

function XFC.DTGuild:PostInitialize()
	XFO.DTGuild:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XFO.DTGuild:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XFO.DTGuild:RefreshBroker()
end
--#endregion

--#region Print
function XFC.DTGuild:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  isReverseSort (' .. type(self.isReverseSort) .. '): ' .. tostring(self.isReverseSort))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Accessors
function XFC.DTGuild:GetBroker()
	return self.ldbObject
end

function XFC.DTGuild:GetHeaderFont()
	return self.headerFont
end

function XFC.DTGuild:GetRegularFont()
	return self.regularFont
end

function XFC.DTGuild:RefreshBroker()
	if(XF.Initialized) then
		local text = ''  
		if(XF.Config.DataText.Guild.Label) then
			text = XF.Lib.Locale['GUILD'] .. ': '
		end
		text = format('%s|cff3CE13F%d', text, XFO.Confederate:OnlineCount())
		XFO.DTGuild:GetBroker().text = text
	end
end
--#endregion

--#region Sorting
function XFC.DTGuild:IsReverseSort(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self.isReverseSort = inBoolean
	end
	return self.isReverseSort
end

function XFC.DTGuild:GetSort()
	return self.sortColumn == nil and self:SetSort(XF.Config.DataText.Guild.Sort) or self.sortColumn
end

function XFC.DTGuild:SetSort(inColumnName)
	assert(type(inColumnName) == 'string')
	self.sortColumn = inColumnName
	return self:GetSort()
end

local function PreSort()
	local list = {}
	for _, unit in XFO.Confederate:Iterator() do
		if(unit:IsOnline()) then
			local data = {}

			data.Level = unit:Level()
			data.Realm = unit:Guild():Realm():Name()
			data.Guild = unit:Guild():Name()		
			data.Name = unit:IsAlt() and XF.Config.DataText.Guild.Main and unit:Name() .. ' (' .. unit:MainName() .. ')' or unit:Name()
			data.UnitName = unit:UnitName()
			data.Note = unit:Note()
			data.GUID = unit:GUID()
			data.Achievement = unit:AchievementPoints()
			data.Rank = unit:Rank()
			data.ItemLevel = unit:ItemLevel()	
			data.Race = unit:Race():Name()
            data.Team = unit:HasTeam() and unit:Team():Name() or 'Unknown'
			data.Class = unit:Spec():Class():Hex()
			data.Faction = unit:Race():Faction():IconID()
			data.PvP = unit:PvP()
            data.Version = unit:HasVersion() and unit:Version():Key() or '0.0.0'
            data.Spec = unit:HasSpec() and unit:Spec():IconID() or nil
            data.Profession1 = unit:HasProfession1() and unit:Profession1():IconID() or nil
            data.Profession2 = unit:HasProfession2() and unit:Profession2():IconID() or nil
            data.Zone = unit:HasZone() and unit:Zone():Name() or nil
            data.MythicKey = unit:HasMythicKey() and unit:MythicKey():HasDungeon() and unit:MythicKey():Dungeon():Name() .. ' +' .. unit:MythicKey():ID() or nil
            data.Raid = unit:HasRaiderIO() and unit:RaiderIO():Raid() or nil
            data.Dungeon = unit:HasRaiderIO() and unit:RaiderIO():DungeonScore() or nil

			list[#list + 1] = data
		end
	end
	return list
end

local function SetSortColumn(_, inColumnName)
	if(XFO.DTGuild:GetSort() == inColumnName and XFO.DTGuild:IsReverseSort()) then
		XFO.DTGuild:IsReverseSort(false)
	elseif(XFO.DTGuild:GetSort() == inColumnName) then
		XFO.DTGuild:IsReverseSort(true)
	else
		XFO.DTGuild:SetSort(inColumnName)
		XFO.DTGuild:IsReverseSort(false)
	end
	XFO.DTGuild:OnEnter(LDB_ANCHOR)
end
--#endregion

--#region OnEnter
local function LineClick(_, inUnitGUID, inMouseButton)
	local unit = XFO.Confederate:Get(inUnitGUID)
	local link = unit:GetChatLink()
	if(link == nil) then return end

	if(inMouseButton == 'RightButton' and IsShiftKeyDown()) then
 		C_PartyInfo.InviteUnit(unit:UnitName())
	elseif(inMouseButton == 'RightButton' and IsControlKeyDown()) then
		C_PartyInfo.RequestInviteFromUnit(unit:UnitName())
 	elseif(inMouseButton == 'LeftButton' or inMouseButton == 'RightButton') then
		SetItemRef(link, unit:Name(), inMouseButton)
	end
end

function XFC.DTGuild:OnEnter(this)
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
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() XFO.DTGuild:OnLeave() end)
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
			if(XFO.DTGuild:IsReverseSort()) then
				if(a[XFO.DTGuild:GetSort()] == nil) then 
					return false
				elseif(b[XFO.DTGuild:GetSort()] == nil) then
					return true
				else
					return a[XFO.DTGuild:GetSort()] > b[XFO.DTGuild:GetSort()]
				end
			else
				if(b[XFO.DTGuild:GetSort()] == nil) then
					return false
				elseif(a[XFO.DTGuild:GetSort()] == nil) then
					return true
				else
					return a[XFO.DTGuild:GetSort()] < b[XFO.DTGuild:GetSort()]
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
function XFC.DTGuild:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
	    return
	else
        XF.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion

--#region OnClick
function XFC.DTGuild:OnClick(this, inButton)
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