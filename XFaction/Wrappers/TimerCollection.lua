local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerCollection'
local LogCategory = 'WCTimer'

TimerCollection = {}

function TimerCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Timers = {}
	self._TimerCount = 0
	self._Initialized = false

    return Object
end

function TimerCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function TimerCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TimerCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _TimerCount (' .. type(self._TimerCount) .. '): ' .. tostring(self._TimerCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Realm in self:Iterator() do
		_Realm:Print()
	end
end

function TimerCollection:GetKey()
    return self._Key
end

function TimerCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function TimerCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Timers[inKey] ~= nil
end

function TimerCollection:GetTimer(inKey)
	assert(type(inKey) == 'string')
	return self._Timers[inKey]
end

function TimerCollection:AddTimer(inTimer)
    assert(type(inTimer) == 'table' and inTimer.__name ~= nil and inTimer.__name == 'Timer', 'argument must be Timer object')
	if(self:Contains(inTimer:GetKey()) == false) then
		self._TimerCount = self._TimerCount + 1
	end
	self._Timers[inTimer:GetKey()] = inTimer
	return self:Contains(inTimer:GetKey())
end

function TimerCollection:RemoveTimer(inTimer)
    assert(type(inTimer) == 'table' and inTimer.__name ~= nil and inTimer.__name == 'Timer', 'argument must be Timer object')
	if(self:Contains(inTimer:GetKey())) then
		self._TimerCount = self._TimerCount - 1
        self._Timers[inTimer:GetKey()] = nil
	end
	inTimer:Stop()
	return self:Contains(inTimer:GetKey())
end

function TimerCollection:Iterator()
	return next, self._Timers, nil
end

function TimerCollection:EnterInstance()
    for _, _Timer in self:Iterator() do
        if(_Timer:IsEnabled() and _Timer:IsInstance() == false) then
            _Timer:Stop()
        end
    end
end

function TimerCollection:LeaveInstance()
    for _, _Timer in self:Iterator() do
        if(_Timer:IsEnabled() == false) then
            _Timer:Start()
            if(_Timer:GetLastRan() < GetServerTime() - _Timer:GetDelta()) then
                local _Function = _Timer:GetCallback()
                _Function()
                _Timer:SetLastRan(GetServerTime())
            end
        end
    end
end

function TimerCollection:EnterCombat()
    for _, _Timer in self:Iterator() do
        if(_Timer:IsEnabled() and _Timer:IsInstanceCombat() == false) then
            _Timer:Stop()
        end
    end
end

function TimerCollection:LeaveCombat()
    for _, _Timer in self:Iterator() do
        if(_Timer:IsEnabled() == false and _Timer:IsInstance()) then
            _Timer:Start()
            if(_Timer:GetLastRan() < GetServerTime() - _Timer:GetDelta()) then
                local _Function = _Timer:GetCallback()
                _Function()
                _Timer:SetLastRan(GetServerTime())
            end
        end
    end
end

-- Stop everything
function TimerCollection:Stop()
	XFG:CancelAllTimers()
	for _, _Timer in self:Iterator() do
		_Timer:IsEnabled(false)
	end
end