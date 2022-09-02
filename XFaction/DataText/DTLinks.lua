local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTLinks'

DTLinks = Object:newChildConstructor()
	
function DTLinks:new()
	local _Object = DTGuild.parent.new(self)
    _Object.__name = ObjectName
    _Object._HeaderFont = nil
	_Object._RegularFont = nil
	_Object._LDBObject = nil
	_Object._Tooltip = nil
	_Object._Count = 0    
    return _Object
end

function DTLinks:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
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

function DTLinks:SetFont()
	self._HeaderFont = CreateFont('_HeaderFont')
	self._HeaderFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize)
	self._HeaderFont:SetTextColor(0.4,0.78,1)
	self._RegularFont = CreateFont('_RegularFont')
	self._RegularFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize)
	self._RegularFont:SetTextColor(255,255,255)
end

function DTLinks:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, "  _HeaderFont (" .. type(self._HeaderFont) .. "): ".. tostring(self._HeaderFont))
		XFG:Debug(ObjectName, "  _RegularFont (" .. type(self._RegularFont) .. "): ".. tostring(self._RegularFont))
		XFG:Debug(ObjectName, "  _Count (" .. type(self._Count) .. "): ".. tostring(self._Count))
		XFG:Debug(ObjectName, "  _LDBObject (" .. type(self._LDBObject) .. ")")
		XFG:Debug(ObjectName, "  _Tooltip (" .. type(_Tooltip) .. ")")
	end
end

function DTLinks:RefreshBroker()
	if(XFG.Initialized) then
		local _Text = ''
		if(XFG.Config.DataText.Link.Label) then
			_Text = XFG.Lib.Locale['LINKS'] .. ': '
		end

		local _Names = {}
		local _AllianceCount = 0
		local _HordeCount = 0

		for _, _Link in XFG.Links:Iterator() do
			if(_Names[_Link:GetFromNode():GetName()] == nil) then
				if(_Link:GetFromNode():GetTarget():GetFaction():GetName() == 'Alliance') then
					_AllianceCount = _AllianceCount + 1
				else
					_HordeCount = _HordeCount + 1
				end
				_Names[_Link:GetFromNode():GetName()] = true
			end
			if(_Names[_Link:GetToNode():GetName()] == nil) then
				if(_Link:GetToNode():GetTarget():GetFaction():GetName() == 'Alliance') then
					_AllianceCount = _AllianceCount + 1
				else
					_HordeCount = _HordeCount + 1
				end
				_Names[_Link:GetToNode():GetName()] = true
			end
		end

		if(XFG.Config.DataText.Link.Faction) then
			_Text = format('%s|cffffffff%d|r \(|cff00FAF6%d|r\|||cffFF4700%d|r\)', _Text, XFG.Links:GetCount(), _AllianceCount, _HordeCount)
		else
			_Text = format('%s|cffffffff%d|r', _Text, XFG.Links:GetCount())
		end
		self._LDBObject.text = _Text
	end
end

function DTLinks:OnEnter(this)
	if(not XFG.Initialized) then return end
	if(InCombatLockdown()) then return end

	local _TargetCount = XFG.Targets:GetCount() + 1
	
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName, _TargetCount)
		self._Tooltip:SetHeaderFont(self._HeaderFont)
		self._Tooltip:SetFont(self._RegularFont)
		self._Tooltip:SmartAnchorTo(this)
		self._Tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function() DTLinks:OnLeave() end)
		self._Tooltip:EnableMouse(true)
		self._Tooltip:SetClampedToScreen(false)
	end

	self._Tooltip:Clear()

	local line = self._Tooltip:AddLine()
	local _GuildName = XFG.Confederate:GetName()
	self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _GuildName), self._HeaderFont, "LEFT", _TargetCount)
	line = self._Tooltip:AddLine()
	self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DTLINKS_HEADER_LINKS'], XFG.Links:GetCount()), self._HeaderFont, "LEFT", _TargetCount)

	line = self._Tooltip:AddLine()
	line = self._Tooltip:AddLine()
	line = self._Tooltip:AddHeader()

	local _TargetColumn = {}
	local i = 1
	for _, _Target in XFG.Targets:Iterator() do
		local _TargetName = format('%s%s', format(XFG.Icons.String, _Target:GetFaction():GetIconID()), _Target:GetRealm():GetName())
		self._Tooltip:SetCell(line, i, _TargetName)
		_TargetColumn[_Target:GetKey()] = i
		i = i + 1
	end

	line = self._Tooltip:AddLine()
	self._Tooltip:AddSeparator()
	line = self._Tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Link in XFG.Links:Iterator() do
			local _FromName = format("|cffffffff%s|r", _Link:GetFromNode():GetName())
			if(_Link:IsMyLink() and _Link:GetFromNode():IsMyNode()) then
				_FromName = format("|cffffff00%s|r", _Link:GetFromNode():GetName())
			end

			local _ToName = format("|cffffffff%s|r", _Link:GetToNode():GetName())
			if(_Link:IsMyLink() and _Link:GetToNode():IsMyNode()) then
				_ToName = format("|cffffff00%s|r", _Link:GetToNode():GetName())
			end

			self._Tooltip:SetCell(line, _TargetColumn[_Link:GetFromNode():GetTarget():GetKey()], _FromName, self._RegularFont)
			self._Tooltip:SetCell(line, _TargetColumn[_Link:GetToNode():GetTarget():GetKey()], _ToName, self._RegularFont)
			
			line = self._Tooltip:AddLine()
		end
	end

	self._Tooltip:Show()
end

function DTLinks:OnLeave()
	if self._Tooltip and MouseIsOver(self._Tooltip) then
        return
    else
        XFG.Lib.QT:Release(self._Tooltip)
        self._Tooltip = nil
	end
end