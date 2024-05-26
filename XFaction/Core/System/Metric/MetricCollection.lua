local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MetricCollection'

XFC.MetricCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.MetricCollection:new()
	local object = XFC.MetricCollection.parent.new(self)
    object.__name = ObjectName
    object.startTime = nil
	object.startCalendar = nil
    return object
end

function XFC.MetricCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, metricName in pairs (XF.Enum.Metric) do
			local metric = XFC.Metric:new()
			metric:Initialize()
			metric:Key(metricName)
			metric:Name(metricName)
			self:Add(metric)
		end
		self:StartTime(XFF.TimeGetCurrent())
		self:StartCalendar(XFF.TimeGetCalendar())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.MetricCollection:StartTime(inEpochTime)
	assert(type(inEpochTime) == 'number')
	if(inEpochTime ~= nil) then
		self.startTime = inEpochTime
	end
	return self.startTime
end

function XFC.MetricCollection:StartCalendar(inCalendar)
	-- FIX:assert(type(inCalendar) == 'number' or nil, 'argument must be number or nil')
	if(inCalendar ~= nil) then
		self.startCalendar = inCalendar
	end
	return self.startCalendar
end
--#endregion

--#region Methods
function XFC.MetricCollection:Print()
	self:ParentPrint()
	XF:Debug(self:ObjectName(), '  startTime (' .. type(self.startTime) .. '): ' .. tostring(self.startTime))
end
--#endregion