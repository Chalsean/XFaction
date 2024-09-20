local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTGuild'

XFC.DTGuild = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.DTGuild:new()
	local object = XFC.DTGuild.parent.new(self)
    object.__name = ObjectName
	object.headerFont = nil
	object.regularFont = nil
	object.broker = nil
	object.tooltip = nil
	object.isReverseSort = false
	object.sortColumn = nil
    return object
end

function XFC.DTGuild:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:Broker(XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTGUILD_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTGUILD_NAME'],
		    OnEnter = function(this) XFO.DTGuild:CallbackOnEnter(this) end,
			OnLeave = function(this) XFO.DTGuild:CallbackOnLeave(this) end,
			OnClick = function(this, button) XFO.DTGuild:CallbackOnClick(this, button) end,
		}))
		self:HeaderFont(XFF.UICreateFont('headerFont'))
		self:HeaderFont():SetTextColor(0.4,0.78,1)
		self:RegularFont(XFF.UICreateFont('regularFont'))
		self:RegularFont():SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function XFC.DTGuild:PostInitialize()
	self:HeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:RegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:SortColumn(XF.Config.DataText.Guild.Sort)
	self:RefreshBroker()
end
--#endregion

--#region Properties
function XFC.DTGuild:Broker(inBroker)
	if(inBroker ~= nil) then
		self.broker = inBroker
	end
	return self.broker
end

function XFC.DTGuild:HeaderFont(inFont)
	if(inFont ~= nil) then
		self.headerFont = inFont
	end
	return self.headerFont
end

function XFC.DTGuild:RegularFont(inFont)
	if(inFont ~= nil) then
		self.regularFont = inFont
	end
	return self.regularFont
end

function XFC.DTGuild:Tooltip(inTooltip)
	local self = XFO.DTGuild
	if(inTooltip ~= nil) then
		self.tooltip = inTooltip
	end
	return self.tooltip
end

function XFC.DTGuild:IsReverseSort(inBoolean)
	assert(type(inBoolean) == 'boolean' or inBoolean == nil)
	if(inBoolean ~= nil) then
		self.isReverseSort = inBoolean
	end
	return self.isReverseSort
end

function XFC.DTGuild:SortColumn(inColumn)
	assert(type(inColumn) == 'string' or inColumn == nil)
	if(inColumn ~= nil) then
		self.sortColumn = inColumn
	end
	return self.sortColumn
end
--#endregion

--#region Methods
function XFC.DTGuild:RefreshBroker()
	local self = XFO.DTGuild
	if(XF.Initialized) then
		try(function()
			local text = ''  
			if(XF.Config.DataText.Guild.Label) then
				text = XF.Lib.Locale['GUILD'] .. ': '
			end
			text = format('%s|cff3CE13F%d', text, XFO.Confederate:OnlineCount())
			self:Broker().text = text
		end).
		catch(function(err)
			XF:Warn(self:ObjectName(), err)
		end)
	end
end

local function PreSort()
	local list = {}
	local guids = {}
	for _, unit in XFO.Confederate:Iterator() do
		if(unit:IsOnline()) then
			local unitData = {}

			unitData.Level = unit:Level()
			unitData.Realm = unit:Realm():Name()
			unitData.Guild = unit:Guild():Name()		
			unitData.Name = unit:Name()
			unitData.UnitName = unit:UnitName()
			unitData.Note = unit:Note()
			unitData.GUID = unit:GUID()
			unitData.Achievement = unit:AchievementPoints()
			unitData.Rank = unit:Rank()
			unitData.ItemLevel = unit:ItemLevel()	
			unitData.Race = unit:Race():Name()
			unitData.Team = unit:HasTeam() and unit:Team():Name() or 'Unknown'
			unitData.Class = unit:Class():Hex()
			unitData.Faction = unit:Faction():IconID()
			unitData.PvP = unit:PvP()

			if(unit:HasVersion()) then
				unitData.Version = unit:Version():Key()
			elseif(unit:LoginEpoch() < XFF.TimeCurrent() - XF.Settings.Confederate.UnitStale) then
				unitData.Version = '0.0.0'
			end

			if(unit:HasRaiderIO()) then
				unitData.Raid = unit:RaiderIO():GetRaid()
				unitData.Dungeon = unit:RaiderIO():GetDungeon()			
			end

			if(unit:IsAlt() and XF.Config.DataText.Guild.Main) then
				unitData.Name = unit:Name() .. ' (' .. unit:MainName() .. ')'
			end

			if(unit:HasSpec()) then
				unitData.Spec = unit:Spec():IconID()
			end

			if(unit:HasHero()) then
				unitData.Hero = unit:Hero():IconID()
			end

			if(unit:HasProfession1()) then
				unitData.Profession1 = unit:Profession1():IconID()
			end

			if(unit:HasProfession2()) then
				unitData.Profession2 = unit:Profession2():IconID()
			end

			unitData.Location = unit:HasLocation() and unit:Location():Name() or nil

			if(unit:HasMythicKey() and unit:MythicKey():HasDungeon()) then
				unitData.MythicKey = unit:MythicKey():Dungeon():Name() .. ' +' .. unit:MythicKey():ID()
			end

			if(guids[unitData.GUID] == nil) then
				list[#list + 1] = unitData
				guids[unitData.GUID] = true
			end
		end
	end
	return list
end

local function SetSortColumn(_, inColumnName)
	local self = XFO.DTGuild
	if(self:SortColumn() == inColumnName and self:IsReverseSort()) then
		self:IsReverseSort(false)
	elseif(self:SortColumn() == inColumnName) then
		self:IsReverseSort(true)
	else
		self:SortColumn(inColumnName)
		self:IsReverseSort(false)
	end
	self:CallbackOnEnter(self:Broker())
end

local function LineClick(_, inUnitGUID, inMouseButton)
	local unit = XFO.Confederate:Get(inUnitGUID)
	local link = unit:IsFriend() and
		format('BNplayer:%s:%d:0:WHISPER:%s', unit:Friend():Name(), unit:Friend():AccountID(), unit:Friend():Name()) or
		format('player:%s', unit:UnitName())

	if(inMouseButton == 'RightButton' and XFF.UIIsShiftDown()) then
		XFF.PartySendInvite(unit:UnitName())
	elseif(inMouseButton == 'RightButton' and XFF.UIIsCtrlDown()) then
		XFF.PartyRequestInvite(unit:UnitName())
 	elseif(inMouseButton == 'LeftButton' or inMouseButton == 'RightButton') then
		XFF.UICreateLink(link, unit:Name(), inMouseButton)
	end
end

function XFC.DTGuild:CallbackOnEnter(this)
	local self = XFO.DTGuild
	if(not XF.Initialized) then return end
	if(XFF.PlayerIsInCombat()) then return end

	try(function()

		--#region Configure Tooltip
		-- This is really old code but dont have the desire to refactor
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
					Icon = (column == 'Spec' or column == 'Profession' or column == 'Faction' or column == 'Hero'),
				}
				if(not orderEnabled[index].Icon) then
					XF.Cache.DTGuildTextEnabled = XF.Cache.DTGuildTextEnabled + 1
				end
			end		
		end
		
		if XF.Lib.QT:IsAcquired(self:ObjectName()) then
			self:Tooltip(XF.Lib.QT:Acquire(self:ObjectName()))
		else
			self:Tooltip(XF.Lib.QT:Acquire(self:ObjectName()))

			for i = 1, XF.Cache.DTGuildTotalEnabled do
				self:Tooltip():AddColumn(orderEnabled[tostring(i)].Alignment)
			end
			
			self:Tooltip():SetHeaderFont(self:HeaderFont())
			self:Tooltip():SetFont(self:RegularFont())
			self:Tooltip():SmartAnchorTo(this)
			self:Tooltip():SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() XFO.DTGuild:CallbackOnLeave() end)
			self:Tooltip():EnableMouse(true)
			self:Tooltip():SetClampedToScreen(false)
			self:Tooltip():SetFrameStrata('FULLSCREEN_DIALOG')
		end

		self:Tooltip():Clear()
		--#endregion

		--#region Header
		local line = self:Tooltip():AddLine()
		
		if(XF.Config.DataText.Guild.GuildName and XF.Cache.DTGuildTotalEnabled > 4) then
			local guildName = XF.Player.Guild:Name()
			guildName = guildName .. ' <' .. XF.Player.Guild:Initials() .. '>'
			self:Tooltip():SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_GUILD'], guildName), self:HeaderFont(), 'LEFT', 4)
		end

		if(XF.Config.DataText.Guild.Confederate and XF.Cache.DTGuildTotalEnabled > 8) then
			self:Tooltip():SetCell(line, 6, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XFO.Confederate:Name()), self:HeaderFont(), 'LEFT', -1)	
		end

		if(XF.Config.DataText.Guild.GuildName or XF.Config.DataText.Guild.Confederate or XF.Config.DataText.Guild.MOTD) then
			line = self:Tooltip():AddLine()
			self:Tooltip():AddSeparator()
			line = self:Tooltip():AddLine()		
		end

		if(XF.Config.DataText.Guild.MOTD and XF.Cache.DTGuildTotalEnabled > 8) then
			local motd = XFF.GuildMOTD()
			local lineWords = ''
			local lineLength = XF.Cache.DTGuildTextEnabled * 15
			if(motd ~= nil) then
				local words = string.Split(motd, ' ')		
				for _, word in pairs (words) do
					if(strlen(lineWords .. ' ' .. word) < lineLength) then
						lineWords = lineWords .. ' ' .. word
					else
						self:Tooltip():SetCell(line, 1, format('|cffffffff%s|r', lineWords), self:RegularFont(), 'LEFT', -1)
						line = self.Tooltip():AddLine()
						lineWords = ''				
					end
				end
			end
			if(strlen(lineWords) > 0) then
				self:Tooltip():SetCell(line, 1, format('|cffffffff%s|r', lineWords), self:RegularFont(), 'LEFT', -1)
				line = self:Tooltip():AddLine()
			end
			line = self:Tooltip():AddLine()
		end
		line = self:Tooltip():AddLine()	
		line = self:Tooltip():AddHeader()
		--#endregion

		--#region Column Headers
		for i = 1, XF.Cache.DTGuildTotalEnabled do
			local columnName = orderEnabled[tostring(i)].ColumnName
			if(not orderEnabled[tostring(i)].Icon) then
				line = self:Tooltip():SetCell(line, i, XF.Lib.Locale[string.upper(columnName)], self:HeaderFont(), 'CENTER')
			end
			self:Tooltip():SetCellScript(line, i, 'OnMouseUp', SetSortColumn, columnName)
		end
		self:Tooltip():AddSeparator()
		--#endregion

		--#region Populate Table
		if(XF.Initialized) then

			local list = PreSort()
			sort(list, function(a, b) 
				if(self:IsReverseSort()) then
					if(a[self:SortColumn()] == nil) then 
						return false
					elseif(b[self:SortColumn()] == nil) then
						return true
					else
						return a[self:SortColumn()] > b[self:SortColumn()]
					end
				else
					if(b[self:SortColumn()] == nil) then
						return false
					elseif(a[self:SortColumn()] == nil) then
						return true
					else
						return a[self:SortColumn()] < b[self:SortColumn()]
					end
				end end)

			for _, unitData in ipairs (list) do
				line = self:Tooltip():AddLine()

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
					self:Tooltip():SetCell(line, i, cellValue, self:RegularFont())
				end

				self:Tooltip():SetLineScript(line, 'OnMouseUp', LineClick, unitData.GUID)
			end
		end
		--#endregion

		self:Tooltip():UpdateScrolling(XF.Config.DataText.Guild.Size)
		self:Tooltip():Show()
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.DTGuild:CallbackOnLeave()
	local self = XFO.DTGuild
	try(function()
		if self:Tooltip() and XFF.UIIsMouseOver(self:Tooltip()) then
			return
		else
			XF.Lib.QT:Release(self:Tooltip())
			self.tooltip = nil
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end

function XFC.DTGuild:CallbackOnClick(this, inButton)
	local self = XFO.DTGuild
	if(XFF.PlayerIsInCombat()) then return end
	try(function()
		if(inButton == 'LeftButton') then
			XFF.UIToggleGuild()
		elseif(inButton == 'RightButton') then
			if not XFF.UIOptionsFrame or not XFF.UIOptionsFrame:IsShown() then
				XFF.UIOptionsFrame:Show()
				XFF.UIOptionsFrameCategory(XF.Name)
			else
				XFF.UIOptionsFrame:Hide()
			end
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion