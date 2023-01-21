local XFG, G = unpack(select(2, ...))
local ObjectName = 'Timer'
local NewTicker = C_Timer.NewTicker
local NewTimer = C_Timer.NewTimer

Timer = Object:newChildConstructor()

--#region Constructors
function Timer:new()
    local object = Timer.parent.new(self)
    object.__name = ObjectName
    object.handle = nil
    object.delta = 0
    object.callback = nil
    object.lastRan = 0
    object.isEnabled = false
    object.isRepeat = false
    object.inInstance = false
    return object
end
--#endregion

--#region Print
function Timer:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  delta (' .. type(self.delta) .. '): ' .. tostring(self.delta))
    XFG:Debug(ObjectName, '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XFG:Debug(ObjectName, '  lastRan (' .. type(self.lastRan) .. '): ' .. tostring(self.lastRan))
    XFG:Debug(ObjectName, '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XFG:Debug(ObjectName, '  isRepeat (' .. type(self.isRepeat) .. '): ' .. tostring(self.isRepeat))
    XFG:Debug(ObjectName, '  inInstance (' .. type(self.inInstance) .. '): ' .. tostring(self.inInstance))
end
--#endregion

--#region Accessors
function Timer:GetDelta()
    return self.delta
end

function Timer:SetDelta(inDelta)
    assert(type(inDelta) == 'number')
    self.delta = inDelta
end

function Timer:GetCallback()
    return self.callback
end

function Timer:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self.callback = inCallback
    return self:GetCallback()
end

function Timer:GetLastRan()
    return self.lastRan
end

function Timer:SetLastRan(inLastRan)
    assert(type(inLastRan) == 'number')
    self.lastRan = inLastRan
end

function Timer:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function Timer:IsRepeat(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRepeat = inBoolean
    end
	return self.isRepeat
end

function Timer:IsInstance(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.inInstance = inBoolean
    end
	return self.inInstance
end
--#endregion

--#region Start/Stop
function Timer:Start()
    if(not self:IsEnabled()) then
        if(self:IsRepeat()) then
            self.handle = NewTicker(self:GetDelta(), self:GetCallback())
        else
            local callback = self:GetCallback()
            self.handle = NewTimer(self:GetDelta(), function (...) callback(...); self:IsEnabled(false) end)
        end
        self:IsEnabled(true)
        XFG:Debug(ObjectName, 'Started timer [%s] for [%d] seconds', self:GetName(), self:GetDelta())
    end
end

function Timer:Stop()
    if(self:IsEnabled()) then
        if(self.handle ~= nil and not self.handle:IsCancelled()) then
            self.handle:Cancel()
        end
        self:IsEnabled(false)
        XFG:Debug(ObjectName, 'Stopped timer [%s]', self:GetName())
    end
end
--#endregion