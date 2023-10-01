local XF, G = unpack(select(2, ...))
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
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTMETRICS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTMETRICS_NAME'],
		    OnEnter = function(this) XF.DataText.Metrics:OnEnter(this) end,
			OnLeave = function(this) XF.DataText.Metrics:OnLeave(this) end,
		})
		LDB_ANCHOR = self.ldbObject
		self.headerFont = CreateFont('headerFont')
		self.headerFont:SetTextColor(0.4,0.78,1)
		self.regularFont = CreateFont('regularFont')
		self.regularFont:SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function DTMetrics:PostInitialize()
	XF.DataText.Guild:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Guild:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XF.DataText.Guild:RefreshBroker()
end
--#endregion

--#region Print
function DTMetrics:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Broker
function DTMetrics:GetBroker()
	return self.ldbObject
end

function DTMetrics:GetHeaderFont()
	return self.headerFont
end

function DTMetrics:GetRegularFont()
	return self.regularFont
end

function DTMetrics:RefreshBroker()
	if(XF.Initialized and self:IsInitialized()) then
		local text = ''
		local delimiter = false
		if(XF.Config.DataText.Metric.Total) then
			text = text .. format('|cffffffff%d|r', XF.Metrics:Get(XF.Enum.Metric.Messages):GetCount())
			delimiter = true
		end

		if(XF.Config.DataText.Metric.Average) then
			if(delimiter) then text = text .. ' : ' end
			text = text .. format('|cffffffff%.2f|r', XF.Metrics:Get(XF.Enum.Metric.Messages):GetAverage(XF.Config.DataText.Metric.Rate))
			delimiter = true
		end

		if(XF.Config.DataText.Metric.Error) then
			if(delimiter) then text = text .. ' : ' end
			text = text .. format('|cffFF4700%d|r', XF.Metrics:Get(XF.Enum.Metric.Error):GetCount())
			delimiter = true
		end

		if(XF.Config.DataText.Metric.Warning) then
			if(delimiter) then text = text .. ' : ' end
			text = text .. format('|cffffff00%d|r', XF.Metrics:Get(XF.Enum.Metric.Warning):GetCount())
			delimiter = true
		end
		self.ldbObject.text = text
	end
end
--#endregion

--#region OnEnter
function DTMetrics:OnEnter(this)
	if(XF.Initialized == false) then return end
	if(CombatLockdown()) then return end

	--#region Configure Tooltip
	if XF.Lib.QT:IsAcquired(ObjectName) then
		self.tooltip = XF.Lib.QT:Acquire(ObjectName)		
	else
		self.tooltip = XF.Lib.QT:Acquire(ObjectName, 3)
		self.tooltip:SetHeaderFont(self.headerFont)
		self.tooltip:SetFont(self.regularFont)
		self.tooltip:SmartAnchorTo(this)
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() DTMetrics:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XF.Confederate:GetName()), self.headerFont, 'LEFT', 3)
	line = self.tooltip:AddLine()
	local calendar = XF.Metrics:GetStartCalendar()
	self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DTMETRICS_HEADER'], calendar.hour, calendar.minute), self.headerFont, 'LEFT', 3)

	line = self.tooltip:AddLine()
	line = self.tooltip:AddLine()
	line = self.tooltip:AddHeader()
	--#endregion

	--#region Column Headers
	self.tooltip:SetCell(line, 1, XF.Lib.Locale['DTMETRICS_HEADER_METRIC'], self.headerFont, 'LEFT')
	self.tooltip:SetCell(line, 2, XF.Lib.Locale['DTMETRICS_HEADER_TOTAL'], self.headerFont, 'CENTER')
	self.tooltip:SetCell(line, 3, XF.Lib.Locale['DTMETRICS_HEADER_AVERAGE'], self.headerFont, 'RIGHT')

	line = self.tooltip:AddLine()
	self.tooltip:AddSeparator()
	line = self.tooltip:AddLine()
	--#endregion

	--#region Populate Table
	if(XF.Initialized) then
		for _, metric in XF.Metrics:Iterator() do
			self.tooltip:SetCell(line, 1, metric:GetName(), self.regularFont, 'LEFT')
			self.tooltip:SetCell(line, 2, metric:GetCount(), self.regularFont, 'CENTER')
			self.tooltip:SetCell(line, 3, format("%.2f", metric:GetAverage(XF.Config.DataText.Metric.Rate)), self.regularFont, 'RIGHT')
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
        XF.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion