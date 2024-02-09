local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Timer'
local NewTicker = C_Timer.NewTicker
local NewTimer = C_Timer.NewTimer
local Now = GetServerTime

XFC.Timer = Object:newChildConstructor()

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

--#region Print
function XFC.Timer:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  startTime (' .. type(self.startTime) .. '): ' .. tostring(self.startTime))
    XF:Debug(ObjectName, '  delta (' .. type(self.delta) .. '): ' .. tostring(self.delta))
    XF:Debug(ObjectName, '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XF:Debug(ObjectName, '  lastRan (' .. type(self.lastRan) .. '): ' .. tostring(self.lastRan))
    XF:Debug(ObjectName, '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XF:Debug(ObjectName, '  isRepeat (' .. type(self.isRepeat) .. '): ' .. tostring(self.isRepeat))
    XF:Debug(ObjectName, '  inInstance (' .. type(self.inInstance) .. '): ' .. tostring(self.inInstance))
    XF:Debug(ObjectName, '  ttl (' .. type(self.ttl) .. '): ' .. tostring(self.ttl))
    XF:Debug(ObjectName, '  maxAttempts (' .. type(self.maxAttempts) .. '): ' .. tostring(self.maxAttempts))
    XF:Debug(ObjectName, '  attempt (' .. type(self.attempt) .. '): ' .. tostring(self.attempt))
end
--#endregion

--#region Accessors
function XFC.Timer:GetStartTime()
    return self.startTime
end

function XFC.Timer:SetStartTime(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.startTime = inEpochTime
end

function XFC.Timer:GetDelta()
    return self.delta
end

function XFC.Timer:SetDelta(inDelta)
    assert(type(inDelta) == 'number')
    self.delta = inDelta
end

function XFC.Timer:GetCallback()
    return self.callback
end

function XFC.Timer:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self.callback = inCallback
    return self:GetCallback()
end

function XFC.Timer:GetLastRan()
    return self.lastRan
end

function XFC.Timer:SetLastRan(inLastRan)
    assert(type(inLastRan) == 'number')
    self.lastRan = inLastRan
end

function XFC.Timer:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function XFC.Timer:IsRepeat(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRepeat = inBoolean
    end
	return self.isRepeat
end

function XFC.Timer:IsInstance(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.inInstance = inBoolean
    end
	return self.inInstance
end

function XFC.Timer:HasTimeToLive()
    return self.ttl ~= nil
end

function XFC.Timer:GetTimeToLive()
    return self.ttl
end

function XFC.Timer:SetTimeToLive(inTime)
    assert(type(inTime) == 'number')
    self.ttl = inTime
end

function XFC.Timer:HasMaxAttempts()
    return self.maxAttempts ~= nil
end

function XFC.Timer:GetMaxAttempts()
    return self.maxAttempts
end

function XFC.Timer:SetMaxAttempts(inCount)
    assert(type(inCount) == 'number')
    self.maxAttempts = inCount
end

function XFC.Timer:GetAttempt()
    return self.attempt
end

function XFC.Timer:SetAttempt(inCount)
    assert(type(inCount) == 'number')
    self.attempt = inCount
end
--#endregion

--#region Start/Stop
function XFC.Timer:Start()
    if(not self:IsEnabled()) then
        local callback = self:GetCallback()
        if(self:IsRepeat()) then
            self.handle = NewTicker(self:GetDelta(), 
                function (...)
                    if(self:HasTimeToLive() and self:GetStartTime() + self:GetTimeToLive() < Now()) then
                        XF:Debug(ObjectName, 'Timer will stop due to time limit [' .. tostring(self:GetTimeToLive()) .. '] being reached: ' .. self:GetKey())
                        self:Stop()
                    elseif(self:HasMaxAttempts() and self:GetMaxAttempts() < self:GetAttempt()) then
                        XF:Debug(ObjectName, 'Timer will stop due to attempt limit [' .. tostring(self:GetMaxAttempts()) .. '] being reached: ' .. self:GetKey())
                        self:Stop()
                    elseif(callback(...)) then
                        self:Stop()
                    else
                        self:SetAttempt(self:GetAttempt() + 1)
                    end                    
                end)
        else
            self.handle = NewTimer(self:GetDelta(), 
                function (...) 
                    callback(...)
                    self:IsEnabled(false) 
                end)
        end
        self:SetStartTime(Now())        
        self:IsEnabled(true)
        XF:Debug(ObjectName, 'Started timer [%s] for [%d] seconds', self:GetName(), self:GetDelta())
    end
end

function XFC.Timer:Stop()
    if(self:IsEnabled()) then
        if(self.handle ~= nil and not self.handle:IsCancelled()) then
            self.handle:Cancel()
        end
        self:IsEnabled(false)
        XF:Debug(ObjectName, 'Stopped timer [%s]', self:GetName())
    end
end
--#endregion