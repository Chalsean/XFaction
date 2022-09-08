local XFG, G = unpack(select(2, ...))
local ObjectName = 'DTMetrics'
local CombatLockdown = InCombatLockdown

DTMetrics = Object:newChildConstructor()
	
--#region Constructors
function DTMetrics:new()
	local object = DTGuild.parent.new(self)
    object.__name = ObjectName
	object.headerFont = nil
	object.regularFont = nil
	object.ldbObject = nil
	object.tooltip = nil
	object.count = 0    
    return object
end
--#endregion

--#region Initializers
function DTMetrics:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XFG.Lib.Broker:NewDataObject(XFG.Lib.Locale['DTMETRICS_NAME'], {
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
	self.headerFont = CreateFont('headerFont')
	self.headerFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize, 'OUTLINE')
	self.headerFont:SetTextColor(0.4,0.78,1)
	self.regularFont = CreateFont('regularFont')
	self.regularFont:SetFont(XFG.Lib.LSM:Fetch('font', XFG.Config.DataText.Font), XFG.Config.DataText.FontSize, 'OUTLINE')
	self.regularFont:SetTextColor(255,255,255)
end
--#endregion

--#region Print
function DTMetrics:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
		XFG:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
		XFG:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
		XFG:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
		XFG:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
	end
end
--#endregion

--#region Broker
function DTMetrics:RefreshBroker()
	if(XFG.Initialized and self:IsInitialized()) then
		local text = ''
		local delimiter = false
		if(XFG.Config.DataText.Metric.Total) then
			text = text .. format('|cffffffff%d|r', XFG.Metrics:Get(XFG.Settings.Metric.Messages):GetCount())
			delimiter = true
		end

		if(XFG.Config.DataText.Metric.Average) then
			if(delimiter) then text = text .. ' : ' end
			text = text .. format('|cffffffff%.2f|r', XFG.Metrics:Get(XFG.Settings.Metric.Messages):GetAverage(XFG.Config.DataText.Metric.Rate))
			delimiter = true
		end

		if(XFG.Config.DataText.Metric.Error) then
			if(delimiter) then text = text .. ' : ' end
			text = text .. format('|cffFF4700%d|r', XFG.Metrics:Get(XFG.Settings.Metric.Error):GetCount())
			delimiter = true
		end

		if(XFG.Config.DataText.Metric.Warning) then
			if(delimiter) then text = text .. ' : ' end
			text = text .. format('|cffffff00%d|r', XFG.Metrics:Get(XFG.Settings.Metric.Warning):GetCount())
			delimiter = true
		end
		self.ldbObject.text = text
	end
end
--#endregion

--#region OnEnter
function DTMetrics:OnEnter(this)
	if(XFG.Initialized == false) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	if XFG.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XFG.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XFG.Lib.QT:Acquire(ObjectName, 3)
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XFG.Settings.DataText.AutoHide, this, function() DTMetrics:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	self.tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DT_HEADER_CONFEDERATE'], XFG.Confederate:GetName()), self.headerFont, 'LEFT', 3)
	line = self.tooltip:AddLine()
	local calendar = XFG.Metrics:GetStartCalendar()
	self.tooltip:SetCell(line, 1, format(XFG.Lib.Locale['DTMETRICS_HEADER'], calendar.hour, calendar.minute), self.headerFont, 'LEFT', 3)

	line = self.tooltip:AddLine()
	line = self.tooltip:AddLine()
	line = self.tooltip:AddHeader()
	--#endregion

	--#region Column Headers
	self.tooltip:SetCell(line, 1, XFG.Lib.Locale['DTMETRICS_HEADER_METRIC'], self.headerFont, 'LEFT')
	self.tooltip:SetCell(line, 2, XFG.Lib.Locale['DTMETRICS_HEADER_TOTAL'], self.headerFont, 'CENTER')
	self.tooltip:SetCell(line, 3, XFG.Lib.Locale['DTMETRICS_HEADER_AVERAGE'], self.headerFont, 'RIGHT')

	line = self.tooltip:AddLine()
	self.tooltip:AddSeparator()
	line = self.tooltip:AddLine()
	--#endregion

	--#region Populate Table
	if(XFG.Initialized) then
		for _, metric in XFG.Metrics:Iterator() do
			self.tooltip:SetCell(line, 1, metric:GetName(), self.regularFont, 'LEFT')
			self.tooltip:SetCell(line, 2, metric:GetCount(), self.regularFont, 'CENTER')
			self.tooltip:SetCell(line, 3, format("%.2f", metric:GetAverage(XFG.Config.DataText.Metric.Rate)), self.regularFont, 'RIGHT')
			line = self.tooltip:AddLine()
		end
	end
	--#endregion

	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function DTMetrics:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
        return
    else
        XFG.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion