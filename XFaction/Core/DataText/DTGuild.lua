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
		_UnitData.Zone = _Unit:GetZone()
		_UnitData.Name = _Unit:GetName()
		_UnitData.UnitName = _Unit:GetUnitName()
		_UnitData.Note = _Unit:GetNote()
		_UnitData.GUID = _Unit:GetGUID()
		_UnitData.Dungeon = _Unit:GetDungeonScore()
		_UnitData.Achievement = _Unit:GetAchievementPoints()
		_UnitData.Rank = _Unit:GetRank()
		if(_Unit:HasVersion()) then
			_UnitData.Version = _Unit:GetVersion()
		else
			_UnitData.Version = '0'
		end

		if(_Unit:IsAlt() and _Unit:HasMainName() and XFG.Config.DataText.Guild.Main) then
			_UnitData.Name = _Unit:GetName() .. " (" .. _Unit:GetMainName() .. ")"
		end

		local _Race = _Unit:GetRace()
		_UnitData.Race = _Race:GetName()

		local _Team = _Unit:GetTeam()
		_UnitData.Team = _Team:GetName()

		local _Class = _Unit:GetClass()
		_UnitData.Class = _Class:GetColorMixin()

		local _Faction = _Unit:GetFaction()
		_UnitData.Faction = _Faction:GetIconID()

		if(_Unit:HasSpec()) then
			local _Spec = _Unit:GetSpec()
			_UnitData.Spec = _Spec:GetIconID()
		end

		if(_Unit:HasCovenant()) then
			local _Covenant = _Unit:GetCovenant()
			_UnitData.Covenant = _Covenant:GetIconID()
		end

		if(_Unit:HasProfession1()) then
			local _Profession = _Unit:GetProfession1()
			_UnitData.Profession1 = _Profession:GetIconID()
		end

		if(_Unit:HasProfession2()) then
			local _Profession = _Unit:GetProfession2()
			_UnitData.Profession2 = _Profession:GetIconID()
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
	local _Unit = XFG.Confederate:GetUnit(inUnitGUID)
	local _Link = _Unit:GetLink()
	if(_Link == nil) then return end

	if(inMouseButton == 'RightButton' and IsShiftKeyDown()) then
 		C_PartyInfo.InviteUnit(_Unit:GetUnitName())
	elseif(inMouseButton == 'RightButton' and IsControlKeyDown()) then
		C_PartyInfo.RequestInviteFromUnit(_Unit:GetUnitName())
 	else
		SetItemRef(_Link, _, inMouseButton)
	end
end

function DTGuild:RefreshBroker()
	if(XFG.Initialized) then
		local _Text = ''  
		if(XFG.Config.DataText.Guild.Label) then
			_Text = XFG.Lib.Locale['GUILD'] .. ': '
		end
		_Text = format('%s|cff3CE13F%d', _Text, XFG.Confederate:GetNumberOfUnits())
		self._LDBObject.text = _Text
	end
end

function DTGuild:GetBroker()
	return self._LDBObject
end

function DTGuild:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(InCombatLockdown()) then return end
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName, 17, "RIGHT", "CENTER", "CENTER", "LEFT", "CENTER", "LEFT", "CENTER", "CENTER", "LEFT", "LEFT", "CENTER", "CENTER", "RIGHT", "LEFT", "LEFT", "CENTER", "CENTER")
		_Tooltip:SetHeaderFont(self._HeaderFont)
		_Tooltip:SetFont(self._RegularFont)
		_Tooltip:SmartAnchorTo(this)
		_Tooltip:SetAutoHideDelay(XFG.DataText.AutoHide, this, function() DTGuild:OnLeave() end)
		_Tooltip:EnableMouse(true)
		_Tooltip:SetClampedToScreen(false)
	end

	_Tooltip:Clear()
	local line = _Tooltip:AddLine()
	
	if(XFG.Config.DataText.Guild.GuildName) then
		local _GuildName = XFG.Player.Guild:GetName()
		local _Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildName)
		_GuildName = _GuildName .. ' <' .. _Guild:GetInitials() .. '>'
		_Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_GUILD'], _GuildName), self._HeaderFont, "LEFT", 4)
	end

	if(XFG.Config.DataText.Guild.Confederate) then
		local _ConfederateName = XFG.Confederate:GetName()
		_Tooltip:SetCell(line, 6, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _ConfederateName), self._HeaderFont, "LEFT", 4)	
	end

	if(XFG.Config.DataText.Guild.GuildName or XFG.Config.DataText.Guild.Confederate or XFG.Config.DataText.Guild.MOTD) then
		line = _Tooltip:AddLine()
		_Tooltip:AddSeparator()
		line = _Tooltip:AddLine()		
	end

	if(XFG.Config.DataText.Guild.MOTD) then
		local _MOTD = GetGuildRosterMOTD()
		local _LineWords = ''
		local _LineLength = 150
		if(_MOTD ~= nil) then
			local _Words = string.Split(_MOTD, ' ')		
			for _, _Word in pairs (_Words) do
				if(strlen(_LineWords .. ' ' .. _Word) < _LineLength) then
					_LineWords = _LineWords .. ' ' .. _Word
				else
					_Tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), self._RegularFont, "LEFT", 13)
					line = _Tooltip:AddLine()
					_LineWords = ''				
				end
			end
		end
		if(strlen(_LineWords) > 0) then
			_Tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), self._RegularFont, "LEFT", 13)
			line = _Tooltip:AddLine()
		end
		line = _Tooltip:AddLine()
	end
	
	line = _Tooltip:AddHeader()
	
	if(XFG.Config.DataText.Guild.Level) then
		line = _Tooltip:SetCell(line, 2, XFG.Lib.Locale['LEVEL'])
		_Tooltip:SetCellScript(line, 2, 'OnMouseUp', SetSortColumn, 'Level')
	end
	line = _Tooltip:SetCell(line, 4, XFG.Lib.Locale['NAME'])	
	_Tooltip:SetCellScript(line, 4, 'OnMouseUp', SetSortColumn, 'Name')
	if(XFG.Config.DataText.Guild.Race) then
		line = _Tooltip:SetCell(line, 6, XFG.Lib.Locale['RACE'])	
		_Tooltip:SetCellScript(line, 6, 'OnMouseUp', SetSortColumn, 'Race')
	end
	if(XFG.Config.DataText.Guild.Realm) then
		line = _Tooltip:SetCell(line, 7, XFG.Lib.Locale['REALM'])
		_Tooltip:SetCellScript(line, 7, 'OnMouseUp', SetSortColumn, 'Realm')
	end
	if(XFG.Config.DataText.Guild.Guild) then
		line = _Tooltip:SetCell(line, 8, XFG.Lib.Locale['GUILD'])
		_Tooltip:SetCellScript(line, 8, 'OnMouseUp', SetSortColumn, 'Guild')
	end
	if(XFG.Config.DataText.Guild.Team) then
		line = _Tooltip:SetCell(line, 9, XFG.Lib.Locale['TEAM'])
		_Tooltip:SetCellScript(line, 9, 'OnMouseUp', SetSortColumn, 'Team')
	end
	if(XFG.Config.DataText.Guild.Rank) then
		line = _Tooltip:SetCell(line, 10, XFG.Lib.Locale['RANK'])
		_Tooltip:SetCellScript(line, 10, 'OnMouseUp', SetSortColumn, 'Rank')
	end
	if(XFG.Config.DataText.Guild.Dungeon) then
		line = _Tooltip:SetCell(line, 11, XFG.Lib.Locale['DUNGEON'])	
		_Tooltip:SetCellScript(line, 11, 'OnMouseUp', SetSortColumn, 'Dungeon')
	end
	if(XFG.Config.DataText.Guild.Zone) then
		line = _Tooltip:SetCell(line, 12, XFG.Lib.Locale['ZONE'])	
		_Tooltip:SetCellScript(line, 12, 'OnMouseUp', SetSortColumn, 'Zone')
	end
	if(XFG.Config.DataText.Guild.Note) then
		line = _Tooltip:SetCell(line, 15, XFG.Lib.Locale['NOTE'])	
		_Tooltip:SetCellScript(line, 15, 'OnMouseUp', SetSortColumn, 'Note')
	end	
	if(XFG.Config.DataText.Guild.Achievement) then
		line = _Tooltip:SetCell(line, 16, XFG.Lib.Locale['ACHIEVEMENT'])	
		_Tooltip:SetCellScript(line, 16, 'OnMouseUp', SetSortColumn, 'Achievement')
	end
	if(XFG.Config.DataText.Guild.Version) then
		line = _Tooltip:SetCell(line, 17, XFG.Lib.Locale['VERSION'])	
		_Tooltip:SetCellScript(line, 17, 'OnMouseUp', SetSortColumn, 'Version')
	end
	_Tooltip:AddSeparator()

	if(XFG.Initialized) then

		local _List = PreSort()
		sort(_List, function(a, b) if(XFG.DataText.Guild:IsReverseSort()) then return a[XFG.DataText.Guild:GetSort()] > b[XFG.DataText.Guild:GetSort()] 
																	      else return a[XFG.DataText.Guild:GetSort()] < b[XFG.DataText.Guild:GetSort()] end end)

		for _, _UnitData in ipairs (_List) do
			line = _Tooltip:AddLine()

			-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank	
			if(XFG.Config.DataText.Guild.Faction) then
				_Tooltip:SetCell(line, 1, format('%s', format(XFG.Icons.String, _UnitData.Faction)))
			end
			if(XFG.Config.DataText.Guild.Level) then
				_Tooltip:SetCell(line, 2, format("|cffffffff%d|r", _UnitData.Level))
			end
			if(XFG.Config.DataText.Guild.Spec and _UnitData.Spec ~= nil) then
				_Tooltip:SetCell(line, 3, format('%s', format(XFG.Icons.String, _UnitData.Spec))) 
			end
			local _ClassHexColor = _UnitData.Class:GenerateHexColor()
			_Tooltip:SetCell(line, 4, format("|c%s%s|r", _ClassHexColor, _UnitData.Name))

			if(XFG.Config.DataText.Guild.Covenant and _UnitData.Covenant ~= nil) then 
				_Tooltip:SetCell(line, 5, format('%s', format(XFG.Icons.String, _UnitData.Covenant))) 
			end
			if(XFG.Config.DataText.Guild.Race) then
				_Tooltip:SetCell(line, 6, format("|cffffffff%s|r", _UnitData.Race))
			end
			if(XFG.Config.DataText.Guild.Realm) then
				_Tooltip:SetCell(line, 7, format("|cffffffff%s|r", _UnitData.Realm))
			end
			if(XFG.Config.DataText.Guild.Guild) then
				_Tooltip:SetCell(line, 8, format("|cffffffff%s|r", _UnitData.Guild))
			end
			if(XFG.Config.DataText.Guild.Team) then
				_Tooltip:SetCell(line, 9, format("|cffffffff%s|r", _UnitData.Team))			
			end
			if(XFG.Config.DataText.Guild.Rank) then
				_Tooltip:SetCell(line, 10, format("|cffffffff%s|r", _UnitData.Rank))
			end
			if(XFG.Config.DataText.Guild.Dungeon) then
				_Tooltip:SetCell(line, 11, format("|cffffffff%d|r", _UnitData.Dungeon))
			end
			if(XFG.Config.DataText.Guild.Zone) then
				_Tooltip:SetCell(line, 12, format("|cffffffff%s|r", _UnitData.Zone))
			end
			if(XFG.Config.DataText.Guild.Profession) then
				if(_UnitData.Profession1 ~= nil) then _Tooltip:SetCell(line, 13, format('%s', format(XFG.Icons.String, _UnitData.Profession1))) end
				if(_UnitData.Profession2 ~= nil) then _Tooltip:SetCell(line, 14, format('%s', format(XFG.Icons.String, _UnitData.Profession2))) end
			end
			if(XFG.Config.DataText.Guild.Note) then
				_Tooltip:SetCell(line, 15, format("|cffffffff%s|r", _UnitData.Note))
			end			
			if(XFG.Config.DataText.Guild.Achievement) then
				_Tooltip:SetCell(line, 16, format("|cffffffff%d|r", _UnitData.Achievement))
			end
			if(XFG.Config.DataText.Guild.Version) then
				_Tooltip:SetCell(line, 17, format("|cffffffff%s|r", _UnitData.Version))
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