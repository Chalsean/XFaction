local XFG, G = unpack(select(2, ...))
local ObjectName = 'Timer'

Timer = Object:newChildConstructor()

function Timer:new()
    local _Object = Timer.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = nil
    _Object._Delta = 0
    _Object._Callback = nil
    _Object._LastRan = 0
    _Object._Enabled = false
    _Object._Instance = false
    _Object._InstanceCombat = false
    return _Object
end

function Timer:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        XFG:Debug(ObjectName, '  _Delta (' .. type(self._Delta) .. '): ' .. tostring(self._Delta))
        XFG:Debug(ObjectName, '  _Callback (' .. type(self._Callback) .. '): ' .. tostring(self._Callback))
        XFG:Debug(ObjectName, '  _LastRan (' .. type(self._LastRan) .. '): ' .. tostring(self._LastRan))
        XFG:Debug(ObjectName, '  _Enabled (' .. type(self._Enabled) .. '): ' .. tostring(self._Enabled))
        XFG:Debug(ObjectName, '  _Instance (' .. type(self._Instance) .. '): ' .. tostring(self._Instance))
        XFG:Debug(ObjectName, '  _InstanceCombat (' .. type(self._InstanceCombat) .. '): ' .. tostring(self._InstanceCombat))
    end
end

function Timer:GetID()
    return self._ID
end

function Timer:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Timer:GetDelta()
    return self._Delta
end

function Timer:SetDelta(inDelta)
    assert(type(inDelta) == 'number')
    self._Delta = inDelta
    return self:GetDelta()
end

function Timer:GetCallback()
    return self._Callback
end

function Timer:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self._Callback = inCallback
    return self:GetCallback()
end

function Timer:GetLastRan()
    return self._LastRan
end

function Timer:SetLastRan(inLastRan)
    assert(type(inLastRan) == 'number')
    self._LastRan = inLastRan
    return self:GetLastRan()
end

function Timer:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Enabled = inBoolean
    end
	return self._Enabled
end

function Timer:IsInstance(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Instance = inBoolean
    end
	return self._Instance
end

function Timer:IsInstanceCombat(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._InstanceCombat = inBoolean
    end
	return self._InstanceCombat
end

function Timer:Start()
    self._ID = XFG:ScheduleRepeatingTimer(self:GetCallback(), self:GetDelta())
    self:IsEnabled(true)
    if(XFG.DebugFlag) then
        XFG:Debug(ObjectName, 'Started timer [%s] for [%d] seconds', self:GetName(), self:GetDelta())
    end
end

function Timer:Stop()
    XFG:CancelTimer(self._ID)
    self:IsEnabled(false)
    if(XFG.DebugFlag) then
        XFG:Debug(ObjectName, 'Stopped timer [%s]', self:GetName())
    end
end