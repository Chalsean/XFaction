local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Metric'

XF.Enum.Metric = {
    BNetSend = XF.Lib.Locale['DTMETRICS_BNET_SEND'],
    BNetReceive = XF.Lib.Locale['DTMETRICS_BNET_RECEIVE'],
    ChannelSend = XF.Lib.Locale['DTMETRICS_CHANNEL_SEND'],
    ChannelReceive = XF.Lib.Locale['DTMETRICS_CHANNEL_RECEIVE'],
    Error = XF.Lib.Locale['DTMETRICS_ERROR'],
    Warning = XF.Lib.Locale['DTMETRICS_WARNING'],
    GuildSend = XF.Lib.Locale['DTMETRICS_GUILD_SEND'],
    GuildReceive = XF.Lib.Locale['DTMETRICS_GUILD_RECEIVE']
}

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
    local delta = time() - XF.Start
    if(inPer ~= nil) then
        delta = delta / inPer
    end
    return self:Count() / delta
end
--#endregion