local XFG, G = unpack(select(2, ...))
local ObjectName = 'MetricCollection'
local ServerTime = C_DateAndTime.GetServerTimeLocal
local CalendarTime = C_DateAndTime.GetCurrentCalendarTime

MetricCollection = ObjectCollection:newChildConstructor()

function MetricCollection:new()
	local object = MetricCollection.parent.new(self)
    object.__name = ObjectName
    object.startTime = nil
	object.startCalendar = nil
    return object
end

function MetricCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, metricName in pairs (XFG.Settings.Metric) do
			local metric = Metric:new()
			metric:SetKey(metricName)
			metric:SetName(metricName)
			self:Add(metric)
		end
		self:SetStartTime(ServerTime())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function MetricCollection:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  startTime (' .. type(self.startTime) .. '): ' .. tostring(self.startTime))
	end
end

function MetricCollection:SetStartTime(inEpochTime)
	assert(type(inEpochTime) == 'number')
	self.startTime = inEpochTime
	self.startCalendar = CalendarTime()
end

function MetricCollection:GetStartTime()
	return self.startTime
end

function MetricCollection:GetStartCalendar()
	return self.startCalendar
end