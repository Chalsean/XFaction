local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTMetrics'

DTMetrics = Object:newChildConstructor()
	
function DTMetrics:new()
	local _Object = DTGuild.parent.new(self)
    _Object.__name = ObjectName
	_Object._HeaderFont = nil
	_Object._RegularFont = nil
	_Object._LDBObject = nil
	_Object._Tooltip = nil
	_Object._Count = 0    
    return _Object
end

function DTMetrics:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self._LDBObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTMETRICS_NAME'], {
			type = 'data source',
			label = XFG.Lib.Locale['DTMETRICS_NAME'],
		    OnEnter = function(this) XFG.DataText.Metrics:OnEnter(this) end,
			OnLeave = function(this) XFG.DataText.Metrics:OnLeave(this) end,
		})

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTMetrics:SetFont()
	self._HeaderFont = CreateFont('_HeaderFont')
	self._HeaderFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize)
	self._HeaderFont:SetTextColor(0.4,0.78,1)
	self._RegularFont = CreateFont('_RegularFont')
	self._RegularFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize)
	self._RegularFont:SetTextColor(255,255,255)
end

function DTMetrics:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, "  _HeaderFont (" .. type(self._HeaderFont) .. "): ".. tostring(self._HeaderFont))
		XFG:Debug(ObjectName, "  _RegularFont (" .. type(self._RegularFont) .. "): ".. tostring(self._RegularFont))
		XFG:Debug(ObjectName, "  _Count (" .. type(self._Count) .. "): ".. tostring(self._Count))
		XFG:Debug(ObjectName, "  _LDBObject (" .. type(self._LDBObject) .. ")")
		XFG:Debug(ObjectName, "  _Tooltip (" .. type(_Tooltip) .. ")")
	end
end

function DTMetrics:RefreshBroker()
	if(XFG.Initialized) then
		local _Text = ''
		local _Delimiter = false
		if(XFG.Config.DataText.Metric.Total) then
			_Text = _Text .. format('|cffffffff%d|r', XFG.Metrics:Get(XFG.Settings.Metric.Messages):GetCount())
			_Delimiter = true
		end

		if(XFG.Config.DataText.Metric.Average) then
			if(_Delimiter) then _Text = _Text .. ' : ' end
			_Text = _Text .. format('|cffffffff%.2f|r', XFG.Metrics:Get(XFG.Settings.Metric.Messages):GetAverage(XFG.Config.DataText.Metric.Rate))
			_Delimiter = true
		end

		if(XFG.Config.DataText.Metric.Error) then
			if(_Delimiter) then _Text = _Text .. ' : ' end
			_Text = _Text .. format('|cffFF4700%d|r', XFG.Metrics:Get(XFG.Settings.Metric.Error):GetCount())
			_Delimiter = true
		end

		if(XFG.Config.DataText.Metric.Warning) then
			if(_Delimiter) then _Text = _Text .. ' : ' end
			_Text = _Text .. format('|cffffff00%d|r', XFG.Metrics:Get(XFG.Settings.Metric.Warning):GetCount())
			_Delimiter = true
		end
		self._LDBObject.text = _Text
	end
end

function DTMetrics:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(InCombatLockdown()) then return end

	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self._Tooltip = XFG.Lib.QT:Acquire(ObjectName, 3)
		self._Tooltip:SetHeaderFont(self._HeaderFont)
		self._Tooltip:SetFont(self._RegularFont)
		self._Tooltip:SmartAnchorTo(this)
		self._Tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function() DTMetrics:OnLeave() end)
		self._Tooltip:EnableMouse(true)
		self._Tooltip:SetClampedToScreen(false)
	end

	self._Tooltip:Clear()

	local line = self._Tooltip:AddLine()
	local _GuildName = XFG.Confederate:GetName()
	self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _GuildName), self._HeaderFont, "LEFT", 3)
	line = self._Tooltip:AddLine()
	local _CalendarTime = XFG.Metrics:GetStartCalendar()
	self._Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DTMETRICS_HEADER'], _CalendarTime.hour, _CalendarTime.minute), self._HeaderFont, "LEFT", 3)

	line = self._Tooltip:AddLine()
	line = self._Tooltip:AddLine()
	line = self._Tooltip:AddHeader()

	self._Tooltip:SetCell(line, 1, XFG.Lib.Locale['DTMETRICS_HEADER_METRIC'], self._HeaderFont, 'LEFT')
	self._Tooltip:SetCell(line, 2, XFG.Lib.Locale['DTMETRICS_HEADER_TOTAL'], self._HeaderFont, 'CENTER')
	self._Tooltip:SetCell(line, 3, XFG.Lib.Locale['DTMETRICS_HEADER_AVERAGE'], self._HeaderFont, 'RIGHT')

	line = self._Tooltip:AddLine()
	self._Tooltip:AddSeparator()
	line = self._Tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Metric in XFG.Metrics:Iterator() do
			self._Tooltip:SetCell(line, 1, _Metric:GetName(), self._RegularFont, 'LEFT')
			self._Tooltip:SetCell(line, 2, _Metric:GetCount(), self._RegularFont, 'CENTER')
			self._Tooltip:SetCell(line, 3, format("%.2f", _Metric:GetAverage(XFG.Config.DataText.Metric.Rate)), self._RegularFont, 'RIGHT')
			line = self._Tooltip:AddLine()
		end
	end

	self._Tooltip:Show()
end

function DTMetrics:OnLeave()
	if self._Tooltip and MouseIsOver(self._Tooltip) then
        return
    else
        XFG.Lib.QT:Release(self._Tooltip)
        self._Tooltip = nil
	end
end