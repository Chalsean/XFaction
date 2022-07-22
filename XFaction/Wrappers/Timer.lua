local XFG, G = unpack(select(2, ...))
local ObjectName = 'Timer'
local LogCategory = 'WTimer'

Timer = {}

function Timer:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._ID = nil
    self._Delta = 0
    self._Callback = nil
    self._LastRan = 0
    self._Enabled = false
    self._Initialized = false
    self._Instance = false
    self._InstanceCombat = false
    
    return Object
end

function Timer:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Timer:Initialize()
	if(self:IsInitialized() == false) then
        if(self:GetName() ~= nil) then
            self:SetKey(self:GetName())
        end
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Timer:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. ' Object')
    XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
    XFG:Debug(LogCategory, '  _Name (' .. type(self._Name) .. '): ' .. tostring(self._Name))
    XFG:Debug(LogCategory, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    XFG:Debug(LogCategory, '  _Delta (' .. type(self._Delta) .. '): ' .. tostring(self._Delta))
    XFG:Debug(LogCategory, '  _Callback (' .. type(self._Callback) .. '): ' .. tostring(self._Callback))
    XFG:Debug(LogCategory, '  _LastRan (' .. type(self._LastRan) .. '): ' .. tostring(self._LastRan))
    XFG:Debug(LogCategory, '  _Enabled (' .. type(self._Enabled) .. '): ' .. tostring(self._Enabled))
    XFG:Debug(LogCategory, '  _Instance (' .. type(self._Instance) .. '): ' .. tostring(self._Instance))
    XFG:Debug(LogCategory, '  _InstanceCombat (' .. type(self._InstanceCombat) .. '): ' .. tostring(self._InstanceCombat))
    XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
end

function Timer:GetKey()
    return self._Key
end

function Timer:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Timer:GetName()
    return self._Name
end

function Timer:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
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
    XFG:Debug(LogCategory, 'Started timer [%s] for [%d] seconds', self:GetName(), self:GetDelta())
end

function Timer:Stop()
    XFG:CancelTimer(self._ID)
    self:IsEnabled(false)
    XFG:Debug(LogCategory, 'Stopped timer [%s]', self:GetName())
end