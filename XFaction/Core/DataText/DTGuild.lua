local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTGuild'
local LogCategory = 'DTGuild'

DTGuild = {}
local LDB_ANCHOR

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
	self._Tooltip = nil
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
		})
		LDB_ANCHOR = self._LDBObject

		self:SetSort('Team')

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
	XFG:Debug(LogCategory, "  _Tooltip (" .. type(self._Tooltip) .. ")")
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
	return self._SortColumn
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
		_UnitData.Note = _Unit:GetNote()
		_UnitData.GUID = _Unit:GetGUID()

		if(_Unit:IsAlt() and _Unit:HasMainName()) then
			_UnitData.Name = _Unit:GetName() .. " (" .. _Unit:GetMainName() .. ")"
		end

		if(_Unit:HasRace()) then
			local _Race = _Unit:GetRace()
			_UnitData.Race = _Race:GetName()
		else
			_UnitData.Race = '?'
		end

		local _Team = _Unit:GetTeam()
		_UnitData.Team = _Team:GetName()

		local _Rank = _Unit:GetRank()
		_UnitData.Rank = _Rank:GetAltName() and _Rank:GetAltName() or _Rank:GetName()

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
	local _UnitName = _Unit:GetUnitName()

	local _UnitFaction = _Unit:GetFaction()
	local _PlayerFaction = XFG.Player.Unit:GetFaction()

	if inMouseButton == 'LeftButton' then
		if IsShiftKeyDown() then
			-- Who
			SetItemRef('player:' .. _UnitName, format('|Hplayer:%1$s|h[%1$s]|h', _UnitName), 'LeftButton') 
		elseif(_UnitFaction:Equals(_PlayerFaction)) then
			-- Whisper		
			SetItemRef('player:' .. _UnitName, format('|Hplayer:%1$s|h[%1$s]|h', _UnitName), 'LeftButton')
		end		
	elseif inMouseButton == 'RightButton' then
		if IsShiftKeyDown() then
			-- Invite
			C_PartyInfo.InviteUnit(inUnitName)
		else
			-- Menu
			SetItemRef('player:' .. _UnitName, format('|Hplayer:%1$s|h[%1$s]|h', _UnitName), 'LeftButton')
		end
	end
end

function DTGuild:RefreshBroker()
	if(XFG.Initialized) then
		self._LDBObject.text = format('|cff3CE13F%d', XFG.Confederate:GetNumberOfUnits())
	end
end

function DTGuild:GetBroker()
	return self._LDBObject
end

function DTGuild:OnEnter(this)
	if(XFG.Initialized == false) then return end

	local _Tooltip
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName, 14, "RIGHT", "CENTER", "CENTER", "LEFT", "CENTER", "LEFT", "CENTER", "CENTER", "LEFT", "LEFT", "CENTER", "RIGHT", "LEFT", "LEFT")
		self._Tooltip:SetHeaderFont(self._HeaderFont)
		self._Tooltip:SetFont(self._RegularFont)
		self._Tooltip:SmartAnchorTo(this)
		self._Tooltip:SetAutoHideDelay(XFG.DataText.AutoHide, self._Tooltip)
		self._Tooltip:EnableMouse(true)
		self._Tooltip:SetClampedToScreen(false)
	end

	self._Tooltip:Clear()
	local line = self._Tooltip:AddLine()
	
	if(XFG.Config.DataText.Guild.GuildName) then
		local _GuildName = XFG.Player.Guild:GetName()
		local _Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildName)
		_GuildName = _GuildName .. ' <' .. _Guild:GetInitials() .. '>'
		self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_GUILD'], _GuildName), self._HeaderFont, "LEFT", 4)
	end

	if(XFG.Config.DataText.Guild.Confederate) then
		local _ConfederateName = XFG.Confederate:GetName()
		self._Tooltip:SetCell(line, 6, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _ConfederateName), self._HeaderFont, "LEFT", 4)	
	end

	if(XFG.Config.DataText.Guild.GuildName or XFG.Config.DataText.Guild.Confederate) then
		line = self._Tooltip:AddLine()
		line = self._Tooltip:AddLine()
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
					self._Tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), self._RegularFont, "LEFT", 13)
					line = self._Tooltip:AddLine()
					_LineWords = ''				
				end
			end
		end
		if(strlen(_LineWords) > 0) then
			self._Tooltip:SetCell(line, 1, format("|cffffffff%s|r", _LineWords), self._RegularFont, "LEFT", 13)
			line = self._Tooltip:AddLine()
		end
		line = self._Tooltip:AddLine()
	end
	
	line = self._Tooltip:AddHeader()
	
	if(XFG.Config.DataText.Guild.Level) then
		line = self._Tooltip:SetCell(line, 2, XFG.Lib.Locale['LEVEL'])
		self._Tooltip:SetCellScript(line, 2, 'OnMouseUp', SetSortColumn, 'Level')
	end
	line = self._Tooltip:SetCell(line, 4, XFG.Lib.Locale['NAME'])	
	self._Tooltip:SetCellScript(line, 4, 'OnMouseUp', SetSortColumn, 'Name')
	if(XFG.Config.DataText.Guild.Race) then
		line = self._Tooltip:SetCell(line, 6, XFG.Lib.Locale['RACE'])	
		self._Tooltip:SetCellScript(line, 6, 'OnMouseUp', SetSortColumn, 'Race')
	end
	if(XFG.Config.DataText.Guild.Realm) then
		line = self._Tooltip:SetCell(line, 7, XFG.Lib.Locale['REALM'])
		self._Tooltip:SetCellScript(line, 7, 'OnMouseUp', SetSortColumn, 'Realm')
	end
	if(XFG.Config.DataText.Guild.Guild) then
		line = self._Tooltip:SetCell(line, 8, XFG.Lib.Locale['GUILD'])
		self._Tooltip:SetCellScript(line, 8, 'OnMouseUp', SetSortColumn, 'Guild')
	end
	if(XFG.Config.DataText.Guild.Team) then
		line = self._Tooltip:SetCell(line, 9, XFG.Lib.Locale['TEAM'])
		self._Tooltip:SetCellScript(line, 9, 'OnMouseUp', SetSortColumn, 'Team')
	end
	if(XFG.Config.DataText.Guild.Rank) then
		line = self._Tooltip:SetCell(line, 10, XFG.Lib.Locale['RANK'])
		self._Tooltip:SetCellScript(line, 10, 'OnMouseUp', SetSortColumn, 'Rank')
	end
	if(XFG.Config.DataText.Guild.Zone) then
		line = self._Tooltip:SetCell(line, 11, XFG.Lib.Locale['ZONE'])	
		self._Tooltip:SetCellScript(line, 11, 'OnMouseUp', SetSortColumn, 'Zone')
	end
	if(XFG.Config.DataText.Guild.Note) then
		line = self._Tooltip:SetCell(line, 14, XFG.Lib.Locale['NOTE'])	
		self._Tooltip:SetCellScript(line, 14, 'OnMouseUp', SetSortColumn, 'Note')
	end
	self._Tooltip:AddSeparator()

	if(XFG.Initialized) then

		local _List = PreSort()
		sort(_List, function(a, b) if(XFG.DataText.Guild:IsReverseSort()) then return a[XFG.DataText.Guild:GetSort()] > b[XFG.DataText.Guild:GetSort()] 
																	      else return a[XFG.DataText.Guild:GetSort()] < b[XFG.DataText.Guild:GetSort()] end end)

		for _, _UnitData in ipairs (_List) do
			line = self._Tooltip:AddLine()

			-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank	
			if(XFG.Config.DataText.Guild.Faction) then
				self._Tooltip:SetCell(line, 1, format('%s', format(XFG.Icons.String, _UnitData.Faction)))
			end
			if(XFG.Config.DataText.Guild.Level) then
				self._Tooltip:SetCell(line, 2, format("|cffffffff%d|r", _UnitData.Level))
			end
			if(XFG.Config.DataText.Guild.Spec and _UnitData.Spec ~= nil) then
				self._Tooltip:SetCell(line, 3, format('%s', format(XFG.Icons.String, _UnitData.Spec))) 
			end
			local _ClassHexColor = _UnitData.Class:GenerateHexColor()
			self._Tooltip:SetCell(line, 4, format("|c%s%s|r", _ClassHexColor, _UnitData.Name))

			if(XFG.Config.DataText.Guild.Covenant and _UnitData.Covenant ~= nil) then 
				self._Tooltip:SetCell(line, 5, format('%s', format(XFG.Icons.String, _UnitData.Covenant))) 
			end
			if(XFG.Config.DataText.Guild.Race) then
				self._Tooltip:SetCell(line, 6, format("|cffffffff%s|r", _UnitData.Race))
			end
			if(XFG.Config.DataText.Guild.Realm) then
				self._Tooltip:SetCell(line, 7, format("|cffffffff%s|r", _UnitData.Realm))
			end
			if(XFG.Config.DataText.Guild.Guild) then
				self._Tooltip:SetCell(line, 8, format("|cffffffff%s|r", _UnitData.Guild))
			end
			if(XFG.Config.DataText.Guild.Team) then
				self._Tooltip:SetCell(line, 9, format("|cffffffff%s|r", _UnitData.Team))			
			end
			if(XFG.Config.DataText.Guild.Rank) then
				self._Tooltip:SetCell(line, 10, format("|cffffffff%s|r", _UnitData.Rank))
			end
			if(XFG.Config.DataText.Guild.Zone) then
				self._Tooltip:SetCell(line, 11, format("|cffffffff%s|r", _UnitData.Zone))
			end
			if(XFG.Config.DataText.Guild.Profession) then
				if(_UnitData.Profession1 ~= nil) then self._Tooltip:SetCell(line, 12, format('%s', format(XFG.Icons.String, _UnitData.Profession1))) end
				if(_UnitData.Profession2 ~= nil) then self._Tooltip:SetCell(line, 13, format('%s', format(XFG.Icons.String, _UnitData.Profession2))) end
			end
			if(XFG.Config.DataText.Guild.Note) then
				self._Tooltip:SetCell(line, 14, format("|cffffffff%s|r", _UnitData.Note))
			end

			self._Tooltip:SetLineScript(line, "OnMouseUp", LineClick, _UnitData.GUID)
		end
	end

	self._Tooltip:UpdateScrolling(200)
	self._Tooltip:Show()
end

function DTGuild:OnLeave()
	if(MouseIsOver(self._Tooltip) == false) then 
		if XFG.Lib.QT:IsAcquired(ObjectName) then self._Tooltip:Clear() end
		self._Tooltip:Hide()
		XFG.Lib.QT:Release(ObjectName)
		self._Tooltip = nil
	end
end