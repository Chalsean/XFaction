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

		for name, key in pairs(XF.Enum.Metric) do
			local metric = XFC.Metric:new()
			metric:Key(key)
			metric:Name(name)
			self:Add(metric)
		end

		self:StartCalendar(XFF.TimeCalendar())
		self:StartTime(XFF.TimeLocal())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.MetricCollection:StartCalendar(inCalendar)
	assert(type(inCalendar) == 'table' or inCalendar == nil)
	if(inCalendar ~= nil) then
		self.startCalendar = inCalendar
	end
	return self.startCalendar
end

function XFC.MetricCollection:StartTime(inEpochTime)
	assert(type(inEpochTime) == 'number' or inEpochTime == nil)
	if(inEpochTime ~= nil) then
		self.startTime = inEpochTime
	end
	return self.startTime
end
--#endregion

--#region Methods
function XFC.MetricCollection:Print()
	self:ParentPrint()
	XF:Debug(self:ObjectName(), '  startCalendar (' .. type(self.startCalendar) .. '): ' .. tostring(self.startCalendar))
	XF:Debug(self:ObjectName(), '  startTime (' .. type(self.startTime) .. '): ' .. tostring(self.startTime))
end
--#endregion