local XFG, G = unpack(select(2, ...))

Event = Object:newChildConstructor()

function Event:new()
    local _Object = Event.parent.new(self)
    _Object.__name = 'Event'
    _Object._Name = nil
    _Object._Delta = 0
    _Object._Callback = nil
    _Object._Enabled = false
    _Object._Instance = false
    _Object._InstanceCombat = false
    _Object._Bucket = false
    return _Object
end

function Event:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(self:GetObjectName(), '  _Delta (' .. type(self._Delta) .. '): ' .. tostring(self._Delta))
    XFG:Debug(self:GetObjectName(), '  _Callback (' .. type(self._Callback) .. '): ' .. tostring(self._Callback))
    XFG:Debug(self:GetObjectName(), '  _Enabled (' .. type(self._Enabled) .. '): ' .. tostring(self._Enabled))
    XFG:Debug(self:GetObjectName(), '  _Instance (' .. type(self._Instance) .. '): ' .. tostring(self._Instance))
    XFG:Debug(self:GetObjectName(), '  _InstanceCombat (' .. type(self._InstanceCombat) .. '): ' .. tostring(self._InstanceCombat))
    XFG:Debug(self:GetObjectName(), '  _Bucket (' .. type(self._Bucket) .. '): ' .. tostring(self._Bucket))
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

function Event:IsBucket(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Bucket = inBoolean
    end
	return self._Bucket
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

function Event:Start()
    if(self:IsBucket()) then
        XFG:RegisterBucketEvent({self:GetName()}, self:GetDelta(), self:GetCallback(), self:GetName())
    else
        XFG:RegisterEvent(self:GetName(), self:GetCallback(), self:GetName())
    end
    self:IsEnabled(true)
    XFG:Debug(self:GetObjectName(), 'Started event listener [%s] for [%s]', self:GetKey(), self:GetName())
end

function Event:Stop()
    XFG:UnregisterEvent(self:GetName())
    self:IsEnabled(false)
    XFG:Debug(self:GetObjectName(), 'Stopped event listener [%s] for [%s]', self:GetKey(), self:GetName())
end

function XFG:CreateEvent(inKey, inName, inCallback, inInstance, inInstanceCombat, inBucket, inDelta)
    local _Event = Event:new()
    _Event:SetKey(inKey)
    _Event:SetName(inName)
    _Event:SetCallback(inCallback)
    _Event:IsInstance(inInstance)
    _Event:IsInstanceCombat(inInstanceCombat)
    if(inBucket ~= nil) then _Event:IsBucket(inBucket) end
    if(inDelta ~= nil) then _Event:SetDelta(inDelta) end
    if(_Event:IsInstance() or XFG.Player.InInstance == false) then
        _Event:Start()
    end
    XFG.Events:AddObject(_Event)
end