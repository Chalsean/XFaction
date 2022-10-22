local XFG, G = unpack(select(2, ...))
local ObjectName = 'Metric'

Metric = Object:newChildConstructor()

--#region Constructors
function Metric:new()
    local object = Metric.parent.new(self)
    object.__name = ObjectName
    object.count = 0
    return object
end
--#endregion

--#region Print
function Metric:Print()
    if(XFG.Verbosity) then
        self:ParentPrint()
	    XFG:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
    end
end
--#endregion

--#region Accessors
function Metric:Increment()
    self.count = self.count + 1
    if(self:GetName() == XFG.Settings.Metric.Messages) then
        XFG.DataText.Metrics:RefreshBroker()
    end
end

function Metric:GetCount()
    return self.count
end

function Metric:GetAverage(inPer)
    if(self:GetCount() == 0) then return 0 end
    assert(type(inPer) == 'number' or inPer == nil, 'argument must be number or nil')
    local delta = GetServerTime() - XFG.Start
    if(inPer ~= nil) then
        delta = delta / inPer
    end
    return self:GetCount() / delta
end
--#endregion