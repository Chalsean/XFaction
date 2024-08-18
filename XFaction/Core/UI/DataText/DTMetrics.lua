local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTMetrics'
local CombatLockdown = InCombatLockdown

XFC.DTMetrics = XFC.Object:newChildConstructor()
	
--#region Constructors
function XFC.DTMetrics:new()
	local object = XFC.DTMetrics.parent.new(self)
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
function XFC.DTMetrics:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.ldbObject = XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTMETRICS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTMETRICS_NAME'],
		    OnEnter = function(this) XFO.DTMetrics:OnEnter(this) end,
			OnLeave = function(this) XFO.DTMetrics:OnLeave(this) end,
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

function XFC.DTMetrics:PostInitialize()
	XFO.DTMetrics:GetHeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XFO.DTMetrics:GetRegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	XFO.DTMetrics:RefreshBroker()
end
--#endregion

--#region Print
function XFC.DTMetrics:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  headerFont (' .. type(self.headerFont) .. '): ' .. tostring(self.headerFont))
	XF:Debug(ObjectName, '  regularFont (' .. type(self.regularFont) .. '): ' .. tostring(self.regularFont))
	XF:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
	XF:Debug(ObjectName, '  ldbObject (' .. type(self.ldbObject) .. ')')
	XF:Debug(ObjectName, '  tooltip (' .. type(tooltip) .. ')')
end
--#endregion

--#region Broker
function XFC.DTMetrics:GetBroker()
	return self.ldbObject
end

function XFC.DTMetrics:GetHeaderFont()
	return self.headerFont
end

function XFC.DTMetrics:GetRegularFont()
	return self.regularFont
end

function XFC.DTMetrics:RefreshBroker()
	if(XF.Initialized and self:IsInitialized()) then
		local text = ''
		local delimiter = false

		local sent = XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Count() + XFO.Metrics:Get(XF.Enum.Metric.GuildSend):Count() + XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Count()
		local received = XFO.Metrics:Get(XF.Enum.Metric.BNetReceive):Count() + XFO.Metrics:Get(XF.Enum.Metric.GuildReceive):Count() + XFO.Metrics:Get(XF.Enum.Metric.ChannelReceive):Count()

		local delta = (XFF.TimeCurrent() - XF.Start) / XF.Config.DataText.Metric.Rate
		sent = sent / delta
		received = received / delta

		local text = format('|cffffffff%d|r', sent) .. ' : ' ..
					 format('|cffffffff%d|r', received) .. ' : ' ..
					 format('|cffFF4700%d|r', XFO.Metrics:Get(XF.Enum.Metric.Error):Count()) .. ' : ' ..
					 format('|cffffff00%d|r', XFO.Metrics:Get(XF.Enum.Metric.Warning):Count())

		self.ldbObject.text = text
	end
end
--#endregion

--#region OnEnter
function XFC.DTMetrics:OnEnter(this)
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
		self.tooltip:SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() XFO.DTMetrics:OnLeave() end)
		self.tooltip:EnableMouse(true)
		self.tooltip:SetClampedToScreen(false)
	end

	self.tooltip:Clear()
	--#endregion

	--#region Header
	local line = self.tooltip:AddLine()
	self.tooltip:SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XFO.Confederate:Name()), self.headerFont, 'LEFT', 3)
	line = self.tooltip:AddLine()
	local calendar = XFO.Metrics:StartCalendar()
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
		for _, metric in XFO.Metrics:SortedIterator() do
			self.tooltip:SetCell(line, 1, metric:Name(), self.regularFont, 'LEFT')
			self.tooltip:SetCell(line, 2, metric:Count(), self.regularFont, 'CENTER')
			self.tooltip:SetCell(line, 3, format("%.2f", metric:GetAverage(XF.Config.DataText.Metric.Rate)), self.regularFont, 'RIGHT')
			line = self.tooltip:AddLine()
		end
	end
	--#endregion

	self.tooltip:Show()
end
--#endregion

--#region OnLeave
function XFC.DTMetrics:OnLeave()
	if self.tooltip and MouseIsOver(self.tooltip) then
        return
    else
        XF.Lib.QT:Release(self.tooltip)
        self.tooltip = nil
	end
end
--#endregion