local XFG, G = unpack(select(2, ...))
local ObjectName = 'MetricCollection'

local ServerTime = C_DateAndTime.GetServerTimeLocal
local CalendarTime = C_DateAndTime.GetCurrentCalendarTime

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
			local _Metric = Metric:new()
			_Metric:SetKey(_MetricName)
			_Metric:SetName(_MetricName)
			self:Add(_Metric)
		end
		self:SetStartTime(ServerTime())
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
	self._StartCalendar = CalendarTime()
	return self:GetStartTime()
end

function MetricCollection:GetStartTime()
	return self._StartTime
end

function MetricCollection:GetStartCalendar()
	return self._StartCalendar
end