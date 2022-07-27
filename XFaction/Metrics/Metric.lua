local XFG, G = unpack(select(2, ...))
local ObjectName = 'Metric'
local LogCategory = 'MMetric'

Metric = {}

function Metric:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Count = 0
    
    return Object
end

function Metric:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
	XFG:Debug(LogCategory, '  _Count (' .. type(self._Count) .. '): ' .. tostring(self._Count))
end

function Metric:GetKey()
    return self._Key
end

function Metric:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Metric:GetName()
    return self._Name
end

function Metric:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Metric:Increment()
    self._Count = self._Count + 1
    if(self:GetName() == XFG.Settings.Metric.Messages) then
        XFG.DataText.Metrics:RefreshBroker()
    end
end

function Metric:GetCount()
    return self._Count
end

function Metric:GetAverage(inPer)
    if(self:GetCount() == 0) then return 0 end
    assert(type(inPer) == 'number' or inPer == nil, 'argument must be number or nil')
    local _Delta = GetServerTime() - XFG.Start
    if(inPer ~= nil) then
        _Delta = _Delta / inPer
    end
    return self:GetCount() / _Delta
end