local XFG, G = unpack(select(2, ...))
local ObjectName = 'MetricCollection'
local LogCategory = 'MCMetric'

MetricCollection = {}

function MetricCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Metrics = {}
	self._MetricCount = 0
	self._Initialized = false
	self._StartTime = nil
	self._StartCalendar = nil
    
    return Object
end

function MetricCollection:Initialize()
	if(not self._Initialized) then
		for _, _MetricName in pairs (XFG.Settings.Metric.Names) do
			local _NewMetric = Metric:new()
			_NewMetric:SetKey(_MetricName)
			_NewMetric:SetName(_MetricName)
			self:AddMetric(_NewMetric)
		end
		local _Time = C_DateAndTime.GetServerTimeLocal()
		self:SetStartTime(_Time)
		self._Initialized = true
	end
	return self._Initialized
end

function MetricCollection:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _MetricCount (' .. type(self._MetricCount) .. '): ' .. tostring(self._MetricCount))
	XFG:Debug(LogCategory, '  _StartTime (' .. type(self._StartTime) .. '): ' .. tostring(self._StartTime))
	XFG:DataDumper(LogCategory, self._StartCalendar)
	for _, _Metric in self:Iterator() do
		_Metric:Print()
	end
end

function MetricCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Metrics[inKey] ~= nil
end

function MetricCollection:GetMetric(inKey)
	assert(type(inKey) == 'string')
	return self._Metrics[inKey]
end

function MetricCollection:AddMetric(inMetric)
    assert(type(inMetric) == 'table' and inMetric.__name ~= nil and inMetric.__name == 'Metric', 'argument must be Metric object')
	if(not self:Contains(inMetric:GetKey())) then
		self._MetricCount = self._MetricCount + 1
	end
	self._Metrics[inMetric:GetKey()] = inMetric
	return self:Contains(inMetric:GetKey())
end

function MetricCollection:Iterator()
	return next, self._Metrics, nil
end

function MetricCollection:SetStartTime(inEpochTime)
	assert(type(inEpochTime) == 'number')
	self._StartTime = inEpochTime
	self._StartCalendar = C_DateAndTime.GetCurrentCalendarTime()
	return self:GetStartTime()
end

function MetricCollection:GetStartTime()
	return self._StartTime
end

function MetricCollection:GetStartCalendar()
	return self._StartCalendar
end