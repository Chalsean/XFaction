local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Timer'

XFC.Timer = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Timer:new()
    local object = XFC.Timer.parent.new(self)
    object.__name = ObjectName
    object.startTime = nil
    object.handle = nil
    object.delta = 0
    object.callback = nil
    object.lastRan = 0
    object.isEnabled = false
    object.isRepeat = false
    object.inInstance = false
    object.ttl = nil
    object.maxAttempts = nil
    object.attempt = 1
    return object
end
--#endregion

--#region Properties
function XFC.Timer:StartTime(inEpochTime)
    assert(type(inEpochTime) == 'number' or inEpochTime == nil)
    if(inEpochTime ~= nil) then
        self.startTime = inEpochTime
    end
    return self.startTime
end

function XFC.Timer:Delta(inDelta)
    assert(type(inDelta) == 'number' or inDelta == nil)
    if(inDelta ~= nil) then
        self.delta = inDelta
    end
    return self.delta
end

function XFC.Timer:Callback(inCallback)
    assert(type(inCallback) == 'function' or inCallback == nil)
    if(inCallback ~= nil) then
        self.callback = inCallback
    end
    return self.callback
end

function XFC.Timer:IsEnabled(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function XFC.Timer:IsRepeat(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isRepeat = inBoolean
    end
	return self.isRepeat
end

function XFC.Timer:IsInstance(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.inInstance = inBoolean
    end
	return self.inInstance
end

function XFC.Timer:LastRan(inLastRan)
    assert(type(inLastRan) == 'number' or inLastRan == nil)
    if(inLastRan ~= nil) then
        self.lastRan = inLastRan
    end
    return self.lastRan
end

function XFC.Timer:TimeToLive(inTime)
    assert(type(inTime) == 'number' or inTime == nil)
    if(inTime ~= nil) then
        self.ttl = inTime
    end
    return self.ttl
end

function XFC.Timer:MaxAttempts(inCount)
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.maxAttempts = inCount
    end
    return self.maxAttempts
end

function XFC.Timer:Attempt(inCount)
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.attempt = inCount
    end
    return self.attempt
end
--#endregion

--#region Methods
function XFC.Timer:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  startTime (' .. type(self.startTime) .. '): ' .. tostring(self.startTime))
    XF:Debug(self:ObjectName(), '  delta (' .. type(self.delta) .. '): ' .. tostring(self.delta))
    XF:Debug(self:ObjectName(), '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XF:Debug(self:ObjectName(), '  lastRan (' .. type(self.lastRan) .. '): ' .. tostring(self.lastRan))
    XF:Debug(self:ObjectName(), '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XF:Debug(self:ObjectName(), '  isRepeat (' .. type(self.isRepeat) .. '): ' .. tostring(self.isRepeat))
    XF:Debug(self:ObjectName(), '  inInstance (' .. type(self.inInstance) .. '): ' .. tostring(self.inInstance))
    XF:Debug(self:ObjectName(), '  ttl (' .. type(self.ttl) .. '): ' .. tostring(self.ttl))
    XF:Debug(self:ObjectName(), '  maxAttempts (' .. type(self.maxAttempts) .. '): ' .. tostring(self.maxAttempts))
    XF:Debug(self:ObjectName(), '  attempt (' .. type(self.attempt) .. '): ' .. tostring(self.attempt))
end

function XFC.Timer:HasTimeToLive()
    return self.ttl ~= nil
end

function XFC.Timer:HasMaxAttempts()
    return self.maxAttempts ~= nil
end

function XFC.Timer:Start()
    if(not self:IsEnabled()) then
        local callback = self:Callback()
        if(self:IsRepeat()) then
            self.handle = XFF.RepeatTimerStart(self:Delta(), 
                function (...)
                    if(self:HasTimeToLive() and self:StartTime() + self:TimeToLive() < XFF.TimeCurrent()) then
                        XF:Debug(ObjectName, 'Timer will stop due to time limit [' .. tostring(self:TimeToLive()) .. '] being reached: ' .. self:Key())
                        self:Stop()
                    elseif(self:HasMaxAttempts() and self:MaxAttempts() < self:Attempt()) then
                        XF:Debug(ObjectName, 'Timer will stop due to attempt limit [' .. tostring(self:MaxAttempts()) .. '] being reached: ' .. self:Key())
                        self:Stop()
                    elseif(callback(...)) then
                        self:Stop()
                    else
                        self:Attempt(self:Attempt() + 1)
                    end                    
                end)
        else
            self.handle = XFF.TimerStart(self:Delta(), 
                function (...) 
                    callback(...)
                    self:IsEnabled(false) 
                end)
        end
        self:StartTime(XFF.TimeCurrent())        
        self:IsEnabled(true)
        XF:Debug(self:ObjectName(), 'Started timer [%s] for [%d] seconds', self:Name(), self:Delta())
    end
end

function XFC.Timer:Stop()
    if(self:IsEnabled()) then
        if(self.handle ~= nil and not self.handle:IsCancelled()) then
            self.handle:Cancel()
        end
        self:IsEnabled(false)
        XF:Debug(ObjectName, 'Stopped timer [%s]', self:Name())
    end
end
--#endregion