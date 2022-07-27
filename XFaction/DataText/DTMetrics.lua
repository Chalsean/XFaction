local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTMetrics'
local LogCategory = 'DTMetrics'

DTMetrics = {}
	
local _Tooltip

function DTMetrics:new()
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

function DTMetrics:Initialize()
	if(self:IsInitialized() == false) then
		self._HeaderFont = CreateFont('_HeaderFont')
		self._HeaderFont:SetTextColor(0.4,0.78,1)
		self._RegularFont = CreateFont('_RegularFont')
		self._RegularFont:SetTextColor(255,255,255)

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

function DTMetrics:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function DTMetrics:Print()
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

function DTMetrics:RefreshBroker()
	if(XFG.Initialized) then
		local _Text = ''
		local _Delimiter = false
		if(XFG.Config.DataText.Metric.Total) then
			_Text = _Text .. format('|cffffffff%d|r', XFG.Metrics:GetMetric(XFG.Settings.Metric.Messages):GetCount())
			_Delimiter = true
		end

		if(XFG.Config.DataText.Metric.Average) then
			if(_Delimiter) then _Text = _Text .. ' : ' end
			_Text = _Text .. format('|cffffffff%.2f|r', XFG.Metrics:GetMetric(XFG.Settings.Metric.Messages):GetAverage(XFG.Config.DataText.Metric.Rate))
			_Delimiter = true
		end

		if(XFG.Config.DataText.Metric.Error) then
			if(_Delimiter) then _Text = _Text .. ' : ' end
			_Text = _Text .. format('|cffFF4700%d|r', XFG.Metrics:GetMetric(XFG.Settings.Metric.Error):GetCount())
			_Delimiter = true
		end

		if(XFG.Config.DataText.Metric.Warning) then
			if(_Delimiter) then _Text = _Text .. ' : ' end
			_Text = _Text .. format('|cffffff00%d|r', XFG.Metrics:GetMetric(XFG.Settings.Metric.Warning):GetCount())
			_Delimiter = true
		end
		self._LDBObject.text = _Text
	end
end

function DTMetrics:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(InCombatLockdown()) then return end

	if XFG.Lib.QT:IsAcquired(ObjectName) then
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		_Tooltip = XFG.Lib.QT:Acquire(ObjectName, 3)
		_Tooltip:SetHeaderFont(self._HeaderFont)
		_Tooltip:SetFont(self._RegularFont)
		_Tooltip:SmartAnchorTo(this)
		_Tooltip:SetAutoHideDelay(XFG.DataText.AutoHide, this, function() DTMetrics:OnLeave() end)
		_Tooltip:EnableMouse(true)
		_Tooltip:SetClampedToScreen(false)
	end

	_Tooltip:Clear()

	local line = _Tooltip:AddLine()
	local _GuildName = XFG.Confederate:GetName()
	_Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], _GuildName), self._HeaderFont, "LEFT", 3)
	line = _Tooltip:AddLine()
	local _CalendarTime = XFG.Metrics:GetStartCalendar()
	XFG.Metrics:Print()
	_Tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DTMETRICS_HEADER'], _CalendarTime.hour, _CalendarTime.minute), self._HeaderFont, "LEFT", 3)

	line = _Tooltip:AddLine()
	line = _Tooltip:AddLine()
	line = _Tooltip:AddHeader()

	_Tooltip:SetCell(line, 1, XFG.Lib.Locale['DTMETRICS_HEADER_METRIC'], self._HeaderFont, 'LEFT')
	_Tooltip:SetCell(line, 2, XFG.Lib.Locale['DTMETRICS_HEADER_TOTAL'], self._HeaderFont, 'CENTER')
	_Tooltip:SetCell(line, 3, XFG.Lib.Locale['DTMETRICS_HEADER_AVERAGE'], self._HeaderFont, 'RIGHT')

	line = _Tooltip:AddLine()
	_Tooltip:AddSeparator()
	line = _Tooltip:AddLine()

	if(XFG.Initialized) then
		for _, _Metric in XFG.Metrics:Iterator() do
			_Tooltip:SetCell(line, 1, _Metric:GetName(), self._RegularFont, 'LEFT')
			_Tooltip:SetCell(line, 2, _Metric:GetCount(), self._RegularFont, 'CENTER')
			_Tooltip:SetCell(line, 3, format("%.2f", _Metric:GetAverage(XFG.Config.DataText.Metric.Rate)), self._RegularFont, 'RIGHT')
			line = _Tooltip:AddLine()
		end
	end

	_Tooltip:Show()
end

function DTMetrics:OnLeave()
	if _Tooltip and MouseIsOver(_Tooltip) then
        return
    else
        XFG.Lib.QT:Release(_Tooltip)
        _Tooltip = nil
	end
end