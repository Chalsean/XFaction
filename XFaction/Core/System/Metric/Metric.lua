local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Metric'

XFC.Metric = Object:newChildConstructor()

--#region Constructors
function XFC.Metric:new()
    local object = XFC.Metric.parent.new(self)
    object.__name = ObjectName
    object.count = 0
    return object
end
--#endregion

--#region Print
function XFC.Metric:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  count (' .. type(self.count) .. '): ' .. tostring(self.count))
end
--#endregion

--#region Accessors
function XFC.Metric:Increment()
    self.count = self.count + 1
    if(self:GetName() == XF.Enum.Metric.Messages or
       self:GetName() == XF.Enum.Metric.Error or
       self:GetName() == XF.Enum.Metric.Warning) then
        XFO.DataText.Metrics:RefreshBroker()
    end
end

function XFC.Metric:GetCount()
    return self.count
end

function XFC.Metric:GetAverage(inPer)
    if(self:GetCount() == 0) then return 0 end
    assert(type(inPer) == 'number' or inPer == nil, 'argument must be number or nil')
    local delta = GetServerTime() - XF.Start
    if(inPer ~= nil) then
        delta = delta / inPer
    end
    return self:GetCount() / delta
end
--#endregion