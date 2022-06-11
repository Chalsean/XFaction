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
    
    return _Object
end

function DTGuild:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.DataText.Guild.BrokerName, {
			type = 'data source',
			label = XFG.DataText.Guild.BrokerName,
		    OnEnter = function(this) XFG.DataText.Guild.Broker:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Guild.Broker:OnLeave(this) end,
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
	XFG:Debug(LogCategory, "  _Price (" .. type(self._Price) .. "): ".. tostring(self._Price))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

local function PreSort()
	local _List = {}
	for _, _Unit in XFG.Confederate:Iterator() do
		local _UnitData = {}
		local _UnitRealm = _Unit:GetRealm()
		local _UnitGuild = _Unit:GetGuild()

		_UnitData[XFG.DataText.Guild.ColumnNames.LEVEL] = _Unit:GetLevel()
		_UnitData[XFG.DataText.Guild.ColumnNames.REALM] = _UnitRealm:GetName()
		_UnitData[XFG.DataText.Guild.ColumnNames.GUILD] = _UnitGuild:GetName()
		_UnitData[XFG.DataText.Guild.ColumnNames.ZONE] = _Unit:GetZone()
		_UnitData[XFG.DataText.Guild.ColumnNames.NAME] = _Unit:GetName()
		_UnitData[XFG.DataText.Guild.ColumnNames.NOTE] = _Unit:GetNote()
		_UnitData.GUID = _Unit:GetGUID()

		if(_Unit:IsAlt() and _Unit:HasMainName()) then
			_UnitData[XFG.DataText.Guild.ColumnNames.NAME] = _Unit:GetName() .. " (" .. _Unit:GetMainName() .. ")"
		end

		if(_Unit:HasRace()) then
			local _Race = _Unit:GetRace()
			_UnitData[XFG.DataText.Guild.ColumnNames.RACE] = _Race:GetName()
		else
			_UnitData[XFG.DataText.Guild.ColumnNames.RACE] = '?'
		end

		local _Team = _Unit:GetTeam()
		_UnitData[XFG.DataText.Guild.ColumnNames.TEAM] = _Team:GetName()

		local _Rank = _Unit:GetRank()
		_UnitData[XFG.DataText.Guild.ColumnNames.RANK] = _Rank:GetAltName() and _Rank:GetAltName() or _Rank:GetName()

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
	if(XFG.DataText.Guild.SortColumn == inColumnName and XFG.DataText.Guild.ReverseSort) then
		XFG.DataText.Guild.ReverseSort = false
	elseif(XFG.DataText.Guild.SortColumn == inColumnName) then
		XFG.DataText.Guild.ReverseSort = true
	else
		XFG.DataText.Guild.SortColumn = inColumnName
		XFG.DataText.Guild.ReverseSort = false
	end
	XFG.DataText.Guild.Broker:OnEnter(LDB_ANCHOR)
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
		_GuildName = _GuildName .. ' <' .. _Guild:GetShortName() .. '>'
		self._Tooltip:SetCell(line, 1, format("Guild: |cffffffff%s|r", _GuildName), self._HeaderFont, "LEFT", 4)
	end

	if(XFG.Config.DataText.Guild.Confederate) then
		local _ConfederateName = XFG.Confederate:GetName()
		self._Tooltip:SetCell(line, 6, format("Confederate: |cffffffff%s|r", _ConfederateName), self._HeaderFont, "LEFT", 4)	
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
		line = self._Tooltip:SetCell(line, 2, XFG.DataText.Guild.ColumnNames.LEVEL)
		self._Tooltip:SetCellScript(line, 2, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.LEVEL)
	end
	line = self._Tooltip:SetCell(line, 4, XFG.DataText.Guild.ColumnNames.NAME)	
	self._Tooltip:SetCellScript(line, 4, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.NAME)
	if(XFG.Config.DataText.Guild.Race) then
		line = self._Tooltip:SetCell(line, 6, XFG.DataText.Guild.ColumnNames.RACE)	
		self._Tooltip:SetCellScript(line, 6, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.RACE)
	end
	if(XFG.Config.DataText.Guild.Realm) then
		line = self._Tooltip:SetCell(line, 7, XFG.DataText.Guild.ColumnNames.REALM)
		self._Tooltip:SetCellScript(line, 7, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.REALM)
	end
	if(XFG.Config.DataText.Guild.Guild) then
		line = self._Tooltip:SetCell(line, 8, XFG.DataText.Guild.ColumnNames.GUILD)
		self._Tooltip:SetCellScript(line, 8, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.GUILD)
	end
	if(XFG.Config.DataText.Guild.Team) then
		line = self._Tooltip:SetCell(line, 9, XFG.DataText.Guild.ColumnNames.TEAM)
		self._Tooltip:SetCellScript(line, 9, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.TEAM)
	end
	if(XFG.Config.DataText.Guild.Rank) then
		line = self._Tooltip:SetCell(line, 10, XFG.DataText.Guild.ColumnNames.RANK)
		self._Tooltip:SetCellScript(line, 10, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.RANK)
	end
	if(XFG.Config.DataText.Guild.Zone) then
		line = self._Tooltip:SetCell(line, 11, XFG.DataText.Guild.ColumnNames.ZONE)	
		self._Tooltip:SetCellScript(line, 11, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.ZONE)
	end
	if(XFG.Config.DataText.Guild.Note) then
		line = self._Tooltip:SetCell(line, 14, XFG.DataText.Guild.ColumnNames.NOTE)	
		self._Tooltip:SetCellScript(line, 14, 'OnMouseUp', SetSortColumn, XFG.DataText.Guild.ColumnNames.NOTE)
	end
	self._Tooltip:AddSeparator()

	if(XFG.Initialized) then

		local _List = PreSort()
		sort(_List, function(a, b) if(XFG.DataText.Guild.ReverseSort) then return a[XFG.DataText.Guild.SortColumn] > b[XFG.DataText.Guild.SortColumn] 
																	  else return a[XFG.DataText.Guild.SortColumn] < b[XFG.DataText.Guild.SortColumn] end end)

		for _, _UnitData in ipairs (_List) do
			line = self._Tooltip:AddLine()

			-- Team, Level, Faction, Covenant, Name, Race, Realm, Guild, Zone, Note, Rank	
			if(XFG.Config.DataText.Guild.Faction) then
				self._Tooltip:SetCell(line, 1, format('%s', format(XFG.Icons.String, _UnitData.Faction)))
			end
			if(XFG.Config.DataText.Guild.Level) then
				self._Tooltip:SetCell(line, 2, format("|cffffffff%d|r", _UnitData[XFG.DataText.Guild.ColumnNames.LEVEL]))
			end
			if(XFG.Config.DataText.Guild.Spec and _UnitData.Spec ~= nil) then
				self._Tooltip:SetCell(line, 3, format('%s', format(XFG.Icons.String, _UnitData.Spec))) 
			end
			local _ClassHexColor = _UnitData.Class:GenerateHexColor()
			self._Tooltip:SetCell(line, 4, format("|c%s%s|r", _ClassHexColor, _UnitData[XFG.DataText.Guild.ColumnNames.NAME]))

			if(XFG.Config.DataText.Guild.Covenant and _UnitData.Covenant ~= nil) then 
				self._Tooltip:SetCell(line, 5, format('%s', format(XFG.Icons.String, _UnitData.Covenant))) 
			end
			if(XFG.Config.DataText.Guild.Race) then
				self._Tooltip:SetCell(line, 6, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.RACE]))
			end
			if(XFG.Config.DataText.Guild.Realm) then
				self._Tooltip:SetCell(line, 7, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.REALM]))
			end
			if(XFG.Config.DataText.Guild.Guild) then
				self._Tooltip:SetCell(line, 8, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.GUILD]))
			end
			if(XFG.Config.DataText.Guild.Team) then
				self._Tooltip:SetCell(line, 9, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.TEAM]))			
			end
			if(XFG.Config.DataText.Guild.Rank) then
				self._Tooltip:SetCell(line, 10, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.RANK]))
			end
			if(XFG.Config.DataText.Guild.Zone) then
				self._Tooltip:SetCell(line, 11, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.ZONE]))
			end
			if(XFG.Config.DataText.Guild.Profession) then
				if(_UnitData.Profession1 ~= nil) then self._Tooltip:SetCell(line, 12, format('%s', format(XFG.Icons.String, _UnitData.Profession1))) end
				if(_UnitData.Profession2 ~= nil) then self._Tooltip:SetCell(line, 13, format('%s', format(XFG.Icons.String, _UnitData.Profession2))) end
			end
			if(XFG.Config.DataText.Guild.Note) then
				self._Tooltip:SetCell(line, 14, format("|cffffffff%s|r", _UnitData[XFG.DataText.Guild.ColumnNames.NOTE]))
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