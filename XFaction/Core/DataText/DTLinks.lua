local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTLinks'
local LogCategory = 'DTLinks'

DTLinks = {}
	
local _Tooltip

function DTLinks:new()
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
	self._Count = 0
    
    return _Object
end

function DTLinks:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTLINKS_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTLINKS_NAME'],
		    OnEnter = function(this) XFG.DataText.Links:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Links:OnLeave(this) end,
		})

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTLinks:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTLinks:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _HeaderFont (" .. type(self._HeaderFont) .. "): ".. tostring(self._HeaderFont))
	XFG:Debug(LogCategory, "  _RegularFont (" .. type(self._RegularFont) .. "): ".. tostring(self._RegularFont))
	XFG:Debug(LogCategory, "  _Count (" .. type(self._Count) .. "): ".. tostring(self._Count))
	XFG:Debug(LogCategory, "  _LDBObject (" .. type(self._LDBObject) .. ")")
	XFG:Debug(LogCategory, "  _Tooltip (" .. type(_Tooltip) .. ")")
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function DTLinks:RefreshBroker()
	if(XFG.Initialized) then
		local _Alliance = 0
		local _Horde = 0
		local _Names = {}
		
		for _, _Link in XFG.Links:Iterator() do
			XFG:Debug(LogCategory, '%s to %s', _Link:GetFromName(), _Link:GetToName())
			if(_Names[_Link:GetFromName()] == nil) then
				local _Faction = _Link:GetFromFaction()
				if(_Faction:GetName() == 'Alliance') then
					_Alliance = _Alliance + 1
				else
					_Horde = _Horde + 1
				end
				_Names[_Link:GetFromName()] = true
			end
			if(_Names[_Link:GetToName()] == nil) then
				local _Faction = _Link:GetToFaction()
				if(_Faction:GetName() == 'Alliance') then
					_Alliance = _Alliance + 1
				else
					_Horde = _Horde + 1
				end
				_Names[_Link:GetToName()] = true
			end
		end

		local _Text = ''
		if(XFG.Config.DataText.Link.Label) then
			_Text = XFG.Lib.Locale['LINKS'] .. ': '
		end

		if(XFG.Config.DataText.Link.Faction) then
			_Text = format('%s|cffffffff%d|r \(|cff00FAF6%d|r\|||cffFF4700%d|r\)', _Text, XFG.Links:GetCount(), _Alliance, _Horde)
		else
			_Text = format('%s|cffffffff%d|r', _Text, XFG.Links:GetCount())
		end
		self._LDBObject.text = _Text
	end
end

function DTLinks:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(InCombatLockdown()) then return end

	local _TargetCount = XFG.Targets:GetCount() + 1
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName, _TargetCount)
		_Tooltip:SetHeaderFont(self._HeaderFont)
		_Tooltip:SetFont(self._RegularFont)
		_Tooltip:SmartAnchorTo(this)
		_Tooltip:SetAutoHideDelay(XFG.DataText.AutoHide, this, function() DTLinks:OnLeave() end)
		_Tooltip:EnableMouse(true)
		_Tooltip:SetClampedToScreen(false)
	end

	_Tooltip:Clear()

	local line = _Tooltip:AddLine()
	local _GuildName = XFG.Confederate:GetName()
	_Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _GuildName), self._HeaderFont, "LEFT", _TargetCount)
	line = _Tooltip:AddLine()
	_Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DTLINKS_HEADER_LINKS'], self._Count), self._HeaderFont, "LEFT", _TargetCount)

	line = _Tooltip:AddLine()
	line = _Tooltip:AddLine()
	line = _Tooltip:AddHeader()

	-- Targets collection does not contain player's current realm/faction
	local _TargetColumn = {}
	local _TargetName = format('%s%s', format(XFG.Icons.String, XFG.Player.Faction:GetIconID()), XFG.Player.Realm:GetName())
	_Tooltip:SetCell(line, 1, _TargetName)
	local _Key = XFG.Player.Realm:GetID() .. ':' .. XFG.Player.Faction:GetID()
	_TargetColumn[_Key] = 1
	local i = 2

	for _, _Target in XFG.Targets:Iterator() do
		local _Realm = _Target:GetRealm()
		local _Faction = _Target:GetFaction()
		local _TargetName = format('%s%s', format(XFG.Icons.String, _Faction:GetIconID()), _Realm:GetName())
		_Tooltip:SetCell(line, i, _TargetName)
		_TargetColumn[_Target:GetKey()] = i
		i = i + 1
	end

	line = _Tooltip:AddLine()
	_Tooltip:AddSeparator()
	line = _Tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Link in XFG.Links:Iterator() do
			local _FromRealm = _Link:GetFromRealm()
			local _FromFaction = _Link:GetFromFaction()
			local _ToRealm = _Link:GetToRealm()
			local _ToFaction = _Link:GetToFaction()

			_FromKey = _FromRealm:GetID() .. ':' .. _FromFaction:GetID()
			_ToKey = _ToRealm:GetID() .. ':' .. _ToFaction:GetID()

			local _FromName = format("|cffffffff%s|r", _Link:GetFromName())
			if(_Link:IsMyLink() and _Link:GetFromName() == XFG.Player.Unit:GetName()) then
				_FromName = format("|cffffff00%s|r", _Link:GetFromName())
			end

			local _ToName = format("|cffffffff%s|r", _Link:GetToName())
			if(_Link:IsMyLink() and _Link:GetToName() == XFG.Player.Unit:GetName()) then
				_ToName = format("|cffffff00%s|r", _Link:GetToName())
			end

			_Tooltip:SetCell(line, _TargetColumn[_FromKey], _FromName)
			_Tooltip:SetCell(line, _TargetColumn[_ToKey], _ToName)
			
			line = _Tooltip:AddLine()
		end
	end

	_Tooltip:Show()
end

function DTLinks:OnLeave()
	if _Tooltip and MouseIsOver(_Tooltip) then
        return
    else
		if XFG.Lib.QT:IsAcquired(ObjectName) then _Tooltip:Clear() end
		_Tooltip:Hide()
		XFG.Lib.QT:Release(ObjectName)
		_Tooltip = nil
	end
end