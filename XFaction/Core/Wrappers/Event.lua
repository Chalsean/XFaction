local XFG, G = unpack(select(2, ...))
local ObjectName = 'Event'
local LogCategory = 'WEvent'

Event = {}

function Event:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Delta = 0
    self._Callback = nil
    self._Enabled = false
    self._Initialized = false
    self._Instance = false
    self._InstanceCombat = false
    self._Bucket = false
    
    return Object
end

function Event:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then        
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Event:Initialize(inKey, inName, inCallback, inInstance, inInstanceCombat, inBucket, inDelta)
	if(self:IsInitialized() == false) then
        self:SetKey(inKey)
        self:SetName(inName)
        self:SetCallback(inCallback)
        self:IsInstance(inInstance)
        self:IsInstanceCombat(inInstanceCombat)
        if(inBucket ~= nil) then self:IsBucket(inBucket) end
        if(inDelta ~= nil) then self:SetDelta(inDelta) end
        self:Start()
        XFG.Events:AddEvent(self)
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Event:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _Delta (' .. type(self._Delta) .. '): ' .. tostring(self._Delta))
    XFG:Debug(LogCategory, '  _Callback (' .. type(self._Callback) .. '): ' .. tostring(self._Callback))
    XFG:Debug(LogCategory, '  _Enabled (' .. type(self._Enabled) .. '): ' .. tostring(self._Enabled))
    XFG:Debug(LogCategory, '  _Instance (' .. type(self._Instance) .. '): ' .. tostring(self._Instance))
    XFG:Debug(LogCategory, '  _InstanceCombat (' .. type(self._InstanceCombat) .. '): ' .. tostring(self._InstanceCombat))
    XFG:Debug(LogCategory, '  _Bucket (' .. type(self._Bucket) .. '): ' .. tostring(self._Bucket))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function Event:GetKey()
    return self._Key
end

function Event:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
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
    XFG:Debug(LogCategory, 'Started event listener [%s] for [%s]', self:GetKey(), self:GetName())
end

function Event:Stop()
    XFG:UnregisterEvent(self:GetName())
    self:IsEnabled(false)
    XFG:Debug(LogCategory, 'Stopped event listener [%s] for [%s]', self:GetKey(), self:GetName())
end