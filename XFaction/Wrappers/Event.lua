local XFG, G = unpack(select(2, ...))
local ObjectName = 'Event'

Event = Object:newChildConstructor()

function Event:new()
    local _Object = Event.parent.new(self)
    _Object.__name = ObjectName
    _Object._Name = nil
    _Object._Delta = 0
    _Object._Callback = nil
    _Object._Enabled = false
    _Object._Instance = false
    _Object._InstanceCombat = false
    return _Object
end

function Event:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
        XFG:Debug(ObjectName, '  _Delta (' .. type(self._Delta) .. '): ' .. tostring(self._Delta))
        XFG:Debug(ObjectName, '  _Callback (' .. type(self._Callback) .. '): ' .. tostring(self._Callback))
        XFG:Debug(ObjectName, '  _Enabled (' .. type(self._Enabled) .. '): ' .. tostring(self._Enabled))
        XFG:Debug(ObjectName, '  _Instance (' .. type(self._Instance) .. '): ' .. tostring(self._Instance))
        XFG:Debug(ObjectName, '  _InstanceCombat (' .. type(self._InstanceCombat) .. '): ' .. tostring(self._InstanceCombat))
        XFG:Debug(ObjectName, '  _Bucket (' .. type(self._Bucket) .. '): ' .. tostring(self._Bucket))
    end
end

function Event:GetName()
    return self._Name
end

function Event:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Event:GetName()
    return self._Name
end

function Event:GetCallback()
    return self._Callback
end

function Event:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self._Callback = inCallback
    return self:GetCallback()
end

function Event:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Enabled = inBoolean
    end
	return self._Enabled
end

function Event:IsInstance(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Instance = inBoolean
    end
	return self._Instance
end

function Event:GetDelta()
    return self._Delta
end

function Event:SetDelta(inDelta)
    assert(type(inDelta) == 'number')
    self._Delta = inDelta
    return self._Delta
end

function Event:IsInstanceCombat(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._InstanceCombat = inBoolean
    end
	return self._InstanceCombat
end

local function GetFrame()
    if(self._Frame == nil) then
        CreateFrame(self:GetKey())
    end
    return self._Frame
end

function Event:Start()
    self:IsEnabled(true)
    if(XFG.DebugFlag) then
        XFG:Debug(ObjectName, 'Started event listener [%s] for [%s]', self:GetKey(), self:GetName())
    end
end

function Event:Stop()
    self:IsEnabled(false)
    if(XFG.DebugFlag) then
        XFG:Debug(ObjectName, 'Stopped event listener [%s] for [%s]', self:GetKey(), self:GetName())
    end
end