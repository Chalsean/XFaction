local XFG, G = unpack(select(2, ...))

Metric = Object:newChildConstructor()

function Metric:new()
    local _Object = Metric.parent.new(self)
    _Object.__name = 'Metric'
    _Object._Count = 0
    return _Object
end

function Metric:Print()
    self:ParentPrint()
	XFG:Debug(self:GetObjectName(), '  _Count (' .. type(self._Count) .. '): ' .. tostring(self._Count))
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