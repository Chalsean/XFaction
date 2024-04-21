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
--#endregion

--#region Initializers
function XFC.MetricCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, metricName in pairs (XF.Enum.Metric) do
			local metric = XFC.Metric:new()
			metric:Initialize()
			metric:SetKey(metricName)
			metric:SetName(metricName)
			self:Add(metric)
		end
		self:SetStartTime(XFF.TimeGetLocal())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Print
function XFC.MetricCollection:Print()
	self:ParentPrint()
	XF:Debug(self:GetObjectName(), '  startTime (' .. type(self.startTime) .. '): ' .. tostring(self.startTime))
end
--#endregion

--#region Accessors
function XFC.MetricCollection:SetStartTime(inEpochTime)
	assert(type(inEpochTime) == 'number')
	self.startTime = inEpochTime
	self.startCalendar = XFF.TimeGetCalendar()
end

function XFC.MetricCollection:GetStartTime()
	return self.startTime
end

function XFC.MetricCollection:GetStartCalendar()
	return self.startCalendar
end
--#endregion