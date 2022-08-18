local XFG, G = unpack(select(2, ...))
local ObjectName = 'MetricCollection'

MetricCollection = ObjectCollection:newChildConstructor()

function MetricCollection:new()
	local _Object = MetricCollection.parent.new(self)
    _Object.__name = ObjectName
    _Object._StartTime = nil
	_Object._StartCalendar = nil
    return _Object
end

function MetricCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, _MetricName in pairs (XFG.Settings.Metric) do
			local _NewMetric = Metric:new()
			_NewMetric:SetKey(_MetricName)
			_NewMetric:SetName(_MetricName)
			self:AddObject(_NewMetric)
		end
		local _Time = C_DateAndTime.GetServerTimeLocal()
		self:SetStartTime(_Time)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function MetricCollection:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  _StartTime (' .. type(self._StartTime) .. '): ' .. tostring(self._StartTime))
	end
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