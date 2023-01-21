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

--#region Initializers
function TimerCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        --#region Timers
        XFG.Timers:Add({name = 'Login', 
                        delta = 1, 
                        callback = XFG.Handlers.TimerEvent.CallbackLogin, 
                        repeater = true, 
                        instance = true,
                        start = false})
		XFG.Timers:Add({name = 'Heartbeat', 
                        delta = XFG.Settings.Player.Heartbeat, 
                        callback = XFG.Handlers.TimerEvent.CallbackHeartbeat, 
                        repeater = true, 
                        instance = true, 
                        start = false})
        XFG.Timers:Add({name = 'Links', 
                        delta = XFG.Settings.Network.BNet.Link.Broadcast, 
                        callback = XFG.Handlers.TimerEvent.CallbackLinks, 
                        repeater = true, 
                        instance = true, 
                        start = false})		    		    
        XFG.Timers:Add({name = 'Mailbox', 
                        delta = XFG.Settings.Network.Mailbox.Scan, 
                        callback = XFG.Handlers.TimerEvent.CallbackMailboxTimer, 
                        repeater = true, 
                        instance = false, 
                        start = false})
        XFG.Timers:Add({name = 'Ping', 
                        delta = XFG.Settings.Network.BNet.Ping.Timer, 
                        callback = XFG.Handlers.TimerEvent.CallbackPingFriends, 
                        repeater = true, 
                        instance = true, 
                        start = false})
        XFG.Timers:Add({name = 'StaleLinks', 
                        delta = XFG.Settings.Network.BNet.Link.Scan, 
                        callback = XFG.Handlers.TimerEvent.CallbackStaleLinks, 
                        repeater = true, 
                        instance = true, 
                        start = false})
        XFG.Timers:Add({name = 'Offline', 
                        delta = XFG.Settings.Confederate.UnitScan, 
                        callback = XFG.Handlers.TimerEvent.CallbackOffline, 
                        repeater = true, 
                        instance = true, 
                        start = false})
        --#endregion
        self:IsInitialized(true)
    end
end

--#region Hash
function TimerCollection:Add(inArgs)
    assert(type(inArgs) == 'table')
    assert(type(inArgs.name) == 'string')
    assert(type(inArgs.delta) == 'number')
    assert(type(inArgs.callback) == 'function')
    assert(inArgs.repeater == nil or type(inArgs.repeater) == 'boolean')
    assert(inArgs.instance == nil or type(inArgs.instance) == 'boolean')
    assert(inArgs.start == nil or type(inArgs.start) == 'boolean')

    local timer = Timer:new()
    timer:Initialize()
    timer:SetKey(inArgs.name)
    timer:SetName(timer:GetKey())
    timer:SetDelta(inArgs.delta)
    timer:SetCallback(inArgs.callback)
    timer:IsRepeat(inArgs.repeater)
    timer:IsInstance(inArgs.instance)
    if(inArgs.start and (timer:IsInstance() or not XFG.Player.InInstance)) then
        timer:Start()
    end
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