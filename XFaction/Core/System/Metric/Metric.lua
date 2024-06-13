local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Metric'

Metric = XFC.Object:newChildConstructor()

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
    self:ParentPrint()
    XF:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
end
--#endregion

--#region Accessors
function Metric:Increment()
    self.count = self.count + 1
    if(self:Name() == XF.Enum.Metric.Messages or
       self:Name() == XF.Enum.Metric.Error or
       self:Name() == XF.Enum.Metric.Warning) then
        XF.DataText.Metrics:RefreshBroker()
    end
end

function Metric:Count()
    return self.count
end

function Metric:GetAverage(inPer)
    if(self:Count() == 0) then return 0 end
    assert(type(inPer) == 'number' or inPer == nil, 'argument must be number or nil')
    local delta = GetServerTime() - XF.Start
    if(inPer ~= nil) then
        delta = delta / inPer
    end
    return self:Count() / delta
end
--#endregion