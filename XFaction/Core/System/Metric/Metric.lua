local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Metric'

XFC.Metric = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Metric:new()
    local object = XFC.Metric.parent.new(self)
    object.__name = ObjectName
    object.count = 0
    return object
end
--#endregion

--#region Properties
function XFC.Metric:Count(inCount)
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.count = self.count + inCount
        XFO.DTMetrics:RefreshBroker()
    end
    return self.count
end
--#endregion

--#region Methods
function XFC.Metric:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
end

function XFC.Metric:GetAverage(inPer)
    if(self:Count() == 0) then return 0 end
    assert(type(inPer) == 'number' or inPer == nil)
    local delta = XFF.TimeCurrent() - XF.Start
    if(inPer ~= nil) then
        delta = delta / inPer
    end
    return self:Count() / delta
end
--#endregion