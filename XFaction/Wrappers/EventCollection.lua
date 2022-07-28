local XFG, G = unpack(select(2, ...))
local ObjectName = 'EventCollection'
local LogCategory = 'WCEvent'

EventCollection = {}

function EventCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Events = {}
	self._EventCount = 0
	self._Initialized = false

    return Object
end

function EventCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function EventCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function EventCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _EventCount (' .. type(self._EventCount) .. '): ' .. tostring(self._EventCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Event in self:Iterator() do
		_Event:Print()
	end
end

function EventCollection:GetKey()
    return self._Key
end

function EventCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function EventCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Events[inKey] ~= nil
end

function EventCollection:GetEvent(inKey)
	assert(type(inKey) == 'string')
	return self._Events[inKey]
end

function EventCollection:AddEvent(inEvent)
    assert(type(inEvent) == 'table' and inEvent.__name ~= nil and inEvent.__name == 'Event', 'argument must be Event object')
	if(self:Contains(inEvent:GetKey()) == false) then
		self._EventCount = self._EventCount + 1
	end
	self._Events[inEvent:GetKey()] = inEvent
	return self:Contains(inEvent:GetKey())
end

function EventCollection:Iterator()
	return next, self._Events, nil
end

function EventCollection:EnterInstance()
    for _, _Event in self:Iterator() do
        if(_Event:IsEnabled() and _Event:IsInstance() == false) then
            _Event:Stop()
        end
    end
end

function EventCollection:LeaveInstance()
    for _, _Event in self:Iterator() do
        if(_Event:IsEnabled() == false and _Event:GetName() ~= 'Covenant') then
            _Event:Start()
        end
    end
end

function EventCollection:EnterCombat()
    for _, _Event in self:Iterator() do
        if(_Event:IsEnabled() and _Event:IsInstanceCombat() == false) then
            _Event:Stop()
        end
    end
end

function EventCollection:LeaveCombat()
    for _, _Event in self:Iterator() do
        if(_Event:IsEnabled() == false and _Event:IsInstance()) then
            _Event:Start()
        end
    end
end

-- Stop everything
function EventCollection:Stop()
	for _, _Event in XFG.Events:Iterator() do
        _Event:Stop()
		_Event:IsEnabled(false)
	end
end