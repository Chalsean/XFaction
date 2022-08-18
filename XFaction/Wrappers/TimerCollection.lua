local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerCollection'

TimerCollection = ObjectCollection:newChildConstructor()

function TimerCollection:new()
    local _Object = TimerCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function TimerCollection:AddTimer(inName, inDelta, inCallback, inInstance, inInstanceCombat)
    local _Timer = Timer:new()
    _Timer:Initialize()
    _Timer:SetKey(inName)
    _Timer:SetName(inName)
    _Timer:SetDelta(inDelta)
    _Timer:SetCallback(inCallback)
    _Timer:IsInstance(inInstance)
    _Timer:IsInstanceCombat(inInstanceCombat)
    _Timer:Start()
    self:AddObject(_Timer)
end

function TimerCollection:RemoveTimer(inKey)
    if(self:Contains(inKey)) then
        self:GetObject(inKey):Stop()
        self:RemoveObject(inKey)
    end
end

function TimerCollection:EnterInstance()
    for _, _Timer in self:Iterator() do
        if(_Timer:IsEnabled() and not _Timer:IsInstance()) then
            _Timer:Stop()
        end
    end
end

function TimerCollection:LeaveInstance()
    for _, _Timer in self:Iterator() do
        if(not _Timer:IsEnabled()) then
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
        if(_Timer:IsEnabled() and not _Timer:IsInstanceCombat()) then
            _Timer:Stop()
        end
    end
end

function TimerCollection:LeaveCombat()
    for _, _Timer in self:Iterator() do
        if(not _Timer:IsEnabled() and _Timer:IsInstance()) then
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