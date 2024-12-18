local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DTMetrics'

XFC.DTMetrics = XFC.Object:newChildConstructor()
	
--#region Constructors
function XFC.DTMetrics:new()
	local object = XFC.DTMetrics.parent.new(self)
    object.__name = ObjectName
	object.headerFont = nil
	object.regularFont = nil
	object.broker = nil
	object.tooltip = nil
    return object
end

function XFC.DTMetrics:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:Broker(XF.Lib.Broker:NewDataObject(XF.Lib.Locale['DTMETRICS_NAME'], {
			type = 'data source',
			label = XF.Lib.Locale['DTMETRICS_NAME'],
		    OnEnter = function(this) XFO.DTMetrics:CallbackOnEnter(this) end,
			OnLeave = function(this) XFO.DTMetrics:CallbackOnLeave(this) end,
		}))
		self:HeaderFont(XFF.UICreateFont('headerFont'))
		self:HeaderFont():SetTextColor(0.4,0.78,1)
		self:RegularFont(XFF.UICreateFont('regularFont'))
		self:RegularFont():SetTextColor(255,255,255)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function XFC.DTMetrics:PostInitialize()
	self:HeaderFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:RegularFont():SetFont(XF.Lib.LSM:Fetch('font', XF.Config.DataText.Font), XF.Config.DataText.FontSize, 'OUTLINE')
	self:RefreshBroker()
end
--#endregion

--#region Properties
function XFC.DTMetrics:Broker(inBroker)
	if(inBroker ~= nil) then
		self.broker = inBroker
	end
	return self.broker
end

function XFC.DTMetrics:HeaderFont(inFont)
	if(inFont ~= nil) then
		self.headerFont = inFont
	end
	return self.headerFont
end

function XFC.DTMetrics:RegularFont(inFont)
	if(inFont ~= nil) then
		self.regularFont = inFont
	end
	return self.regularFont
end

function XFC.DTMetrics:Tooltip(inTooltip)
	local self = XFO.DTMetrics
	if(inTooltip ~= nil) then
		self.tooltip = inTooltip
	end
	return self.tooltip
end
--#region

--#region Methods
function XFC.DTMetrics:RefreshBroker()
	local self = XFO.DTMetrics
	if(XF.Initialized and self:IsInitialized()) then
		try(function()
			local text = ''
			local delimiter = false

			local bnet = XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Count()
			local channel = XFO.Metrics:Get(XF.Enum.Metric.GuildSend):Count() + XFO.Metrics:Get(XF.Enum.Metric.ChannelSend):Count()

			local delta = (XFF.TimeCurrent() - XF.Start) / XF.Config.DataText.Metric.Rate
			bnet = bnet / delta
			channel = channel / delta

			local text = format('|cffffffff%d|r', channel) .. ' : ' ..
						format('|cffffffff%d|r', bnet) .. ' : ' ..
						format('|cffFF4700%d|r', XFO.Metrics:Get(XF.Enum.Metric.Error):Count()) .. ' : ' ..
						format('|cffffff00%d|r', XFO.Metrics:Get(XF.Enum.Metric.Warning):Count())

			self:Broker().text = text
		end).
		catch(function(err)
			XF:Warn(self:ObjectName(), err)
		end)
	end
end

function XFC.DTMetrics:CallbackOnEnter(this)
	local self = XFO.DTMetrics
	if(XF.Initialized == false) then return end
	if(XFF.PlayerIsInCombat()) then return end

	try(function()

		--#region Configure Tooltip
		if XF.Lib.QT:IsAcquired(self:ObjectName()) then
			self:Tooltip(XF.Lib.QT:Acquire(self:ObjectName()))
		else
			self:Tooltip(XF.Lib.QT:Acquire(self:ObjectName(), 3))
			self:Tooltip():SetHeaderFont(self:HeaderFont())
			self:Tooltip():SetFont(self:RegularFont())
			self:Tooltip():SmartAnchorTo(this)
			self:Tooltip():SetAutoHideDelay(XF.Settings.DataText.AutoHide, this, function() XFO.DTMetrics:CallbackOnLeave() end)
			self:Tooltip():EnableMouse(true)
			self:Tooltip():SetClampedToScreen(false)
		end

		self:Tooltip():Clear()
		--#endregion

		--#region Header
		local line = self:Tooltip():AddLine()
		self:Tooltip():SetCell(line, 1, format(XF.Lib.Locale['DT_HEADER_CONFEDERATE'], XFO.Confederate:Name()), self:HeaderFont(), 'LEFT', 3)
		line = self:Tooltip():AddLine()
		local calendar = XFO.Metrics:StartCalendar()
		self:Tooltip():SetCell(line, 1, format(XF.Lib.Locale['DTMETRICS_HEADER'], calendar.hour, calendar.minute), self:HeaderFont(), 'LEFT', 3)

		line = self.Tooltip():AddLine()
		line = self.Tooltip():AddLine()
		line = self.Tooltip():AddHeader()
		--#endregion

		--#region Column Headers
		self:Tooltip():SetCell(line, 1, XF.Lib.Locale['DTMETRICS_HEADER_METRIC'], self:HeaderFont(), 'LEFT')
		self:Tooltip():SetCell(line, 2, XF.Lib.Locale['DTMETRICS_HEADER_TOTAL'], self:HeaderFont(), 'CENTER')
		self:Tooltip():SetCell(line, 3, XF.Lib.Locale['DTMETRICS_HEADER_AVERAGE'], self:HeaderFont(), 'RIGHT')

		line = self:Tooltip():AddLine()
		self:Tooltip():AddSeparator()
		line = self:Tooltip():AddLine()
		--#endregion

		--#region Populate Table
		if(XF.Initialized) then
			for _, metric in XFO.Metrics:SortedIterator() do
				self:Tooltip():SetCell(line, 1, metric:Name(), self:RegularFont(), 'LEFT')
				self:Tooltip():SetCell(line, 2, metric:Count(), self:RegularFont(), 'CENTER')
				self:Tooltip():SetCell(line, 3, format("%.2f", metric:GetAverage(XF.Config.DataText.Metric.Rate)), self:RegularFont(), 'RIGHT')
				line = self:Tooltip():AddLine()
			end
		end
		--#endregion

		self.Tooltip():Show()
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion

--#region OnLeave
function XFC.DTMetrics:CallbackOnLeave()
	local self = XFO.DTMetrics
	try(function()
		if self:Tooltip() and XFF.UIIsMouseOver(self:Tooltip()) then
			return
		else
			XF.Lib.QT:Release(self:Tooltip())
			self.tooltip = nil
		end
	end).
	catch(function(err)
		XF:Warn(self:ObjectName(), err)
	end)
end
--#endregion