local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'

DTGuild = {}
local LDB_ANCHOR
local _Tooltip

function DTGuild:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Initialized = false
	self._HeaderFont = nil
	self._RegularFont = nil
	self._LDBObject = nil
	_Tooltip = nil
	self._ReverseSort = false
	self._SortColumn = nil
    
    return _Object
end

function DTGuild:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTGUILD_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTGUILD_NAME'],
		    OnEnter = function(this) XFG.DataText.Guild:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Guild:OnLeave(this) end,
			OnClick = function(this, button) XFG.DataText.Guild:OnClick(this, button) end,
		})
		LDB_ANCHOR = self._LDBObject

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTGuild:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTGuild:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _HeaderFont (" .. type(self._HeaderFont) .. "): ".. tostring(self._HeaderFont))
	XFG:Debug(LogCategory, "  _RegularFont (" .. type(self._RegularFont) .. "): ".. tostring(self._RegularFont))
	XFG:Debug(LogCategory, "  _ReverseSort (" .. type(self._ReverseSort) .. "): ".. tostring(self._ReverseSort))
	XFG:Debug(LogCategory, "  _LDBObject (" .. type(self._LDBObject) .. ")")
	XFG:Debug(LogCategory, "  _Tooltip (" .. type(_Tooltip) .. ")")
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function DTGuild:IsReverseSort(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._ReverseSort = inBoolean
	end
	return self._ReverseSort
end

function DTGuild:GetSort()
	return self._SortColumn == nil and self:SetSort(XFG.Config.DataText.Guild.Sort) or self._SortColumn
end

function DTGuild:SetSort(inColumnName)
	assert(type(inColumnName) == 'string')
	self._SortColumn = inColumnName
	return self:GetSort()
end

local function PreSort()
	local _List = {}
	for _, _Unit in XFG.Confederate:Iterator() do
		local _UnitData = {}
		local _UnitRealm = _Unit:GetRealm()
		local _UnitGuild = _Unit:GetGuild()

		_UnitData.Level = _Unit:GetLevel()
		_UnitData.Realm = _UnitRealm:GetName()
		_UnitData.Guild = _UnitGuild:GetName()		
		_UnitData.Name = _Unit:GetName()
		_UnitData.UnitName = _Unit:GetUnitName()
		_UnitData.Note = _Unit:GetNote()
		_UnitData.GUID = _Unit:GetGUID()
		_UnitData.Dungeon = _Unit:GetDungeonScore()
		_UnitData.Achievement = _Unit:GetAchievementPoints()
		_UnitData.Rank = _Unit:GetRank()
		_UnitData.ItemLevel = _Unit:GetItemLevel()
		_UnitData.Raid = _Unit:GetRaidProgress()
		_UnitData.PvP = _Unit:GetPvP()
		_UnitData.Race = _Unit:GetRace():GetLocaleName()
		_UnitData.Team = _Unit:GetTeam():GetName()
		_UnitData.Class = _Unit:GetClass():GetHex()
		_UnitData.Faction = _Unit:GetFaction():GetIconID()

		if(_Unit:HasVersion()) then
			_UnitData.Version = _Unit:GetVersion():GetKey()
		else
			_UnitData.Version = '0.0.0'
		end

		if(_Unit:IsAlt() and _Unit:HasMainName() and XFG.Config.DataText.Guild.Main) then
			_UnitData.Name = _Unit:GetName() .. " (" .. _Unit:GetMainName() .. ")"
		end

		if(_Unit:HasSpec()) then
			_UnitData.Spec = _Unit:GetSpec():GetIconID()
		end

		if(_Unit:HasCovenant()) then
			_UnitData.Covenant = _Unit:GetCovenant():GetIconID()
		end

		if(_Unit:HasProfession1()) then
			_UnitData.Profession1 = _Unit:GetProfession1():GetIconID()
		end

		if(_Unit:HasProfession2()) then
			_UnitData.Profession2 = _Unit:GetProfession2():GetIconID()
		end

		if(_Unit:HasZone()) then
			_UnitData.Zone = _Unit:GetZone():GetLocaleName()
		else
			_UnitData.Zone = _Unit:GetZoneName()
		end

		table.insert(_List, _UnitData)
	end
	return _List
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
	local _Unit = XFG.Confederate:GetObject(inUnitGUID)
	local _Link = _Unit:GetLink()
	if(_Link == nil) then return end

	if(inMouseButton == 'RightButton' and IsShiftKeyDown()) then
 		C_PartyInfo.InviteUnit(_Unit:GetUnitName())
	elseif(inMouseButton == 'RightButton' and IsControlKeyDown()) then
		C_PartyInfo.RequestInviteFromUnit(_Unit:GetUnitName())
 	else
		SetItemRef(_Link, _Unit:GetName(), inMouseButton)
	end
end

function DTGuild:RefreshBroker()
	if(XFG.Initialized) then
		local _Text = ''  
		if(XFG.Config.DataText.Guild.Label) then
			_Text = XFG.Lib.Locale['GUILD'] .. ': '
		end
		_Text = format('%s|cff3CE13F%d', _Text, XFG.Confederate:GetCount())
		self._LDBObject.text = _Text
	end
end

function DTGuild:GetBroker()
	return self._LDBObject
end

function DTGuild:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(InCombatLockdown()) then return end

	local _OrderEnabled = {}
	XFG.Cache.DTGuildTotalEnabled = 0
	XFG.Cache.DTGuildTextEnabled = 0
	for _ColumnName, _Enabled in pairs (XFG.Config.DataText.Guild.Enable) do
		if(_Enabled) then
			local _OrderKey = _ColumnName .. 'Order'
			local _AlignmentKey = _ColumnName .. 'Alignment'

			if(XFG.Config.DataText.Guild.Order[_OrderKey] ~= 0) then
				XFG.Cache.DTGuildTotalEnabled = XFG.Cache.DTGuildTotalEnabled + 1
				local _Index = tostring(XFG.Config.DataText.Guild.Order[_OrderKey])
				_OrderEnabled[_Index] = {
					ColumnName = _ColumnName,
					Alignment = string.upper(XFG.Config.DataText.Guild.Alignment[_AlignmentKey]),
					Icon = (_ColumnName == 'Covenant' or _ColumnName == 'Spec' or _ColumnName == 'Profession' or _ColumnName == 'Faction'),
				}
				if(not _OrderEnabled[_Index].Icon) then
					XFG.Cache.DTGuildTextEnabled = XFG.Cache.DTGuildTextEnabled + 1
				end
			end
		end		
	end
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName)

		for i = 1, XFG.Cache.DTGuildTotalEnabled do
			_Tooltip:AddColumn(_OrderEnabled[tostring(i)].Alignment)
		end
		
		_Tooltip:SetHeaderFont(self._HeaderFont)
		_Tooltip:SetFont(self._RegularFont)
		_Tooltip:SmartAnchorTo(this)
		_Tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function() XFG.DataText.Guild:OnLeave() end)
		_Tooltip:EnableMouse(true)
		_Tooltip:SetClampedToScreen(false)
		_Tooltip:SetFrameStrata("FULLSCREEN_DIALOG")
	end

	_Tooltip:Clear()
	local line = _Tooltip:AddLine()
	
	if(XFG.Config.DataText.Guild.GuildName and XFG.Cache.DTGuildTotalEnabled > 4) then
		local _GuildName = XFG.Player.Guild:GetName()
		local _Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildName)
		_GuildName = _GuildName .. ' <' .. _Guild:GetInitials() .. '>'
		_Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_GUILD'], _GuildName), self._HeaderFont, "LEFT", 4)
	end

	if(XFG.Config.DataText.Guild.Confederate and XFG.Cache.DTGuildTotalEnabled > 8) then
		local _ConfederateName = XFG.Confederate:GetName()
		_Tooltip:SetCell(line, 6, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _ConfederateName), self._HeaderFont, "LEFT", -1)	
	end

	if(XFG.Config.DataText.Guild.GuildName or XFG.Config.DataText.Guild.Confederate or XFG.Config.DataText.Guild.MOTD) then
		line = _Tooltip:AddLine()
		_Tooltip:AddSeparator()
		line = _Tooltip:AddLine()		
	end

	if(XFG.Config.DataText.Guild.MOTD and XFG.Cache.DTGuildTotalEnabled > 8) then
		local _MOTD = GetGuildRosterMOTD()
		local _LineWords = ''
		local _LineLength = XFG.Cache.DTGuildTextEnabled * 15
		if(_MOTD ~= nil) then
			local _Words = string.Split(_MOTD, ' ')		
			for _, _Word in pairs (_Words) do
				if(strlen(_LineWords .. ' ' .. _Word) < _LineLength) then
					_LineWords = _LineWords .. ' ' .. _Word
				else
					_Tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), self._RegularFont, "LEFT", -1)
					line = _Tooltip:AddLine()
					_LineWords = ''				
				end
			end
		end
		if(strlen(_LineWords) > 0) then
			_Tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), self._RegularFont, "LEFT", -1)
			line = _Tooltip:AddLine()
		end
		line = _Tooltip:AddLine()
	end
	line = _Tooltip:AddLine()
	
	line = _Tooltip:AddHeader()
	for i = 1, XFG.Cache.DTGuildTotalEnabled do
		local _ColumnName = _OrderEnabled[tostring(i)].ColumnName
		if(not _OrderEnabled[tostring(i)].Icon) then
			line = _Tooltip:SetCell(line, i, XFG.Lib.Locale[string.upper(_ColumnName)], self._HeaderFont, 'CENTER')
		end
		_Tooltip:SetCellScript(line, i, 'OnMouseUp', SetSortColumn, _ColumnName)
	end
	_Tooltip:AddSeparator()

	if(XFG.Initialized) then

		local _List = PreSort()
		sort(_List, function(a, b) if(XFG.DataText.Guild:IsReverseSort()) then return a[XFG.DataText.Guild:GetSort()] > b[XFG.DataText.Guild:GetSort()] 
																	      else return a[XFG.DataText.Guild:GetSort()] < b[XFG.DataText.Guild:GetSort()] end end)

		for _, _UnitData in ipairs (_List) do
			line = _Tooltip:AddLine()

			for i = 1, XFG.Cache.DTGuildTotalEnabled do
				local _ColumnName = _OrderEnabled[tostring(i)].ColumnName
				local _CellValue = ''
				if(_OrderEnabled[tostring(i)].Icon) then
					if(_ColumnName == 'Profession') then
						if(_UnitData.Profession1 ~= nil) then
							_CellValue = format('%s', format(XFG.Icons.String, _UnitData.Profession1))
						end
						if(_UnitData.Profession2 ~= nil) then
							_CellValue = _CellValue .. ' ' .. format('%s', format(XFG.Icons.String, _UnitData.Profession2))
						end
					elseif(_UnitData[_ColumnName] ~= nil) then
						_CellValue = format('%s', format(XFG.Icons.String, _UnitData[_ColumnName]))
					end
				elseif(_ColumnName == 'Name') then
					_CellValue = format('|cff%s%s|r', _UnitData.Class, _UnitData.Name)
				elseif(_UnitData[_ColumnName] ~= nil) then
					_CellValue = format('|cffffffff%s|r', _UnitData[_ColumnName])
				end
				_Tooltip:SetCell(line, i, _CellValue, self._RegularFont)
			end

	 		_Tooltip:SetLineScript(line, "OnMouseUp", LineClick, _UnitData.GUID)
		end
	end

	_Tooltip:UpdateScrolling(XFG.Config.DataText.Guild.Size)
	_Tooltip:Show()
end

function DTGuild:OnLeave()
	if _Tooltip and MouseIsOver(_Tooltip) then
	    return
	else
        XFG.Lib.QT:Release(_Tooltip)
        _Tooltip = nil
	end
end

function DTGuild:OnClick(this, inButton)
	if(InCombatLockdown()) then return end
	if(inButton == 'LeftButton') then
		ToggleGuildFrame()
	elseif(inButton == 'RightButton') then
		if not InterfaceOptionsFrame or not InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Show()
			InterfaceOptionsFrame_OpenToCategory('XFaction')
		else
			InterfaceOptionsFrame:Hide()
		end
	end
end