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
    
    return Object
end

function MetricCollection:Initialize()
	if(not self._Initialized) then
		for _MetricKey, _MetricName in pairs (XFG.Settings.Metric.Names) do
			local _NewMetric = Metric:new()
			_NewMetric:SetKey(_MetricKey)
			_NewMetric:SetName(_MetricName)
			self:AddMetric(_NewMetric)
		end
		self._Initialized = true
	end
	return self._Initialized
end

function MetricCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _MetricCount (' .. type(self._MetricCount) .. '): ' .. tostring(self._MetricCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
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