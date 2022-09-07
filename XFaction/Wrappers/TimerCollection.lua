local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerCollection'
local ServerTime = GetServerTime

TimerCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function TimerCollection:new()
    local object = TimerCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Hash
function TimerCollection:Add(inName, inDelta, inCallback, inRepeat, inInstance, inInstanceCombat)
    local timer = Timer:new()
    timer:Initialize()
    timer:SetKey(inName)
    timer:SetName(inName)
    timer:SetDelta(inDelta)
    timer:SetCallback(inCallback)
    timer:IsRepeat(inRepeat)
    timer:IsInstance(inInstance)
    timer:IsInstanceCombat(inInstanceCombat)
    self.parent.Add(self, timer)
end

function TimerCollection:Remove(inKey)
    if(self:Contains(inKey)) then
        self:Get(inKey):Stop()
        self.parent.Remove(self, inKey)
    end
end
--#endregion

--#region Start/Stop
function TimerCollection:EnterInstance()
    for _, timer in self:Iterator() do
        if(timer:IsEnabled() and not timer:IsInstance()) then
            timer:Stop()
        end
    end
end

function TimerCollection:LeaveInstance()
    for _, timer in self:Iterator() do
        if(not timer:IsEnabled()) then
            timer:Start()
            local now = ServerTime()
            if(timer:GetLastRan() < now - timer:GetDelta()) then
                local _Function = timer:GetCallback()
                _Function()
                timer:SetLastRan(now)
            end
        end
    end
end

function TimerCollection:EnterCombat()
    for _, timer in self:Iterator() do
        if(timer:IsEnabled() and not timer:IsInstanceCombat()) then
            timer:Stop()
        end
    end
end

function TimerCollection:LeaveCombat()
    for _, timer in self:Iterator() do
        if(not timer:IsEnabled() and timer:IsInstance()) then
            timer:Start()
            local now = ServerTime()
            if(timer:GetLastRan() < now - timer:GetDelta()) then
                local _Function = timer:GetCallback()
                _Function()
                timer:SetLastRan(now)
            end
        end
    end
end

-- Start everything
function TimerCollection:Start()
	for _, timer in self:Iterator() do
        timer:Start()
	end
end

-- Stop everything
function TimerCollection:Stop()
	for _, timer in self:Iterator() do
        timer:Stop()
	end
end
--#endregion