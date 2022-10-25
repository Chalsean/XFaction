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

        XFG.Timers:Add('Login', 1, XFG.Handlers.TimerEvent.CallbackLogin, true, true, true)
		XFG.Timers:Add('Heartbeat', XFG.Settings.Player.Heartbeat, XFG.Handlers.TimerEvent.CallbackHeartbeat, true, true, false)
        XFG.Timers:Add('Links', XFG.Settings.Network.BNet.Link.Broadcast, XFG.Handlers.TimerEvent.CallbackLinks, true, true, false)		    		    
        XFG.Timers:Add('Roster', XFG.Settings.LocalGuild.ScanTimer, XFG.Handlers.TimerEvent.CallbackGuildRoster, true, true, false)		    				
        XFG.Timers:Add('Mailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackMailboxTimer, true, false, false)
        XFG.Timers:Add('Ping', XFG.Settings.Network.BNet.Ping.Timer, XFG.Handlers.TimerEvent.CallbackPingFriends, true, true, false)
        XFG.Timers:Add('StaleLinks', XFG.Settings.Network.BNet.Link.Scan, XFG.Handlers.TimerEvent.CallbackStaleLinks, true, true, false)
        XFG.Timers:Add('Offline', XFG.Settings.Confederate.UnitScan, XFG.Handlers.TimerEvent.CallbackOffline, true, true, false)
        XFG.Timers:Add('DelayedLogin', 7, XFG.Handlers.TimerEvent.CallbackDelayedLogin)

        self:IsInitialized(true)
    end
end

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