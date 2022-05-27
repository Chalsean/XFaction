local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'
local _OfflineDelta = 70  -- Seconds before you consider another unit offline

TimerEvent = {}

function TimerEvent:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Initialized = false
    end

    return Object
end

function TimerEvent:Initialize()
	if(self:IsInitialized() == false) then
		XFG:ScheduleTimer(self.CallbackChannelTimer, 15) -- config
        XFG:ScheduleRepeatingTimer(self.CallbackGarbageTimer, 60) -- config
        XFG:Info(LogCategory, "Scheduled memory garbage collection to occur every %d seconds", 60)
        XFG:ScheduleRepeatingTimer(self.CallbackMailboxTimer, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", 60 * 5)
        XFG.Cache.CallbackTimerID = XFG:ScheduleRepeatingTimer(self.CallbackLogin, 1) -- config
        XFG:Info(LogCategory, "Scheduled initialization to occur once guild information is available")
        XFG:ScheduleRepeatingTimer(self.CallbackOffline, _OfflineDelta) -- config
        XFG:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", _OfflineDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackHeartbeat, 60) -- config
        XFG:Info(LogCategory, "Scheduled heartbeat for %d seconds", 60)
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TimerEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function TimerEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

-- Wait for General chat to grab #1
function TimerEvent:CallbackChannelTimer()
    XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
    if(XFG.Network.Sender:GetLocalChannel() == nil) then
        -- This will fire an event that ChannelEvent handler catches and updates
        JoinChannelByName(XFG.Network.ChannelName)
    end
end

-- Force garbage cleanup
function TimerEvent:CallbackGarbageTimer()
    collectgarbage() -- This identifies objects to clean and calls finalizers
    collectgarbage() -- The second call actually deletes the objects
end

-- Force garbage cleanup
function TimerEvent:CallbackMailboxTimer()
    XFG.Network.Mailbox:Purge()
end

-- WoW has funky timing about getting guild info on first login, its not before PLAYER_ENTERING_WORLD so have to poll
function TimerEvent:CallbackLogin()
    XFG.Player.GuildName = GetGuildInfo('player')

    if(XFG.Player.GuildName ~= nil) then
        XFG:Info(LogCategory, "Successfully got guild info, disabling poller and continuing setup")
        XFG:CancelTimer(XFG.Cache.CallbackTimerID)
        table.RemoveKey(XFG.Cache, 'CallbackTimerID')

        XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
        XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
        XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()
        XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
        XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()
        XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()

        XFG:Info(LogCategory, "Initializing local guild roster cache")
	    local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
	
        for i = 1, _TotalMembers do
            local _UnitData = Unit:new()
            _UnitData:Initialize(i)
            if(_UnitData:IsOnline()) then
                XFG.Guild:AddUnit(_UnitData)

                if(_UnitData:IsPlayer()) then
                    XFG.Player.Unit = _UnitData                    
                    XFG.Player.Unit:Print()                    
                end
            end
        end

        XFG.Network.Sender = Sender:new()
	    XFG.Network.Receiver = Receiver:new(); XFG.Network.Receiver:Initialize()
        XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
        XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()

        -- These event handlers have a dependency on player data being populated
        XFG.Handlers.SpecEvent = SpecEvent:new(); XFG.Handlers.SpecEvent:Initialize()
        XFG.Handlers.CovenantEvent = CovenantEvent:new(); XFG.Handlers.CovenantEvent:Initialize()
        XFG.Handlers.SoulbindEvent = SoulbindEvent:new(); XFG.Handlers.SoulbindEvent:Initialize()
        XFG.Handlers.ProfessionEvent = ProfessionEvent:new(); XFG.Handlers.ProfessionEvent:Initialize()
        XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()

        if(XFG.UIReload == false) then
            XFG.Network.Sender:BroadcastUnitData(XFG.Player.Unit)
        end
        XFG.UIReload = false
        XFG.Initialized = true
        DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
        DT:ForceUpdate_DataText(XFG.DataText.Soulbind.Name)
    end
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    XFG.Guild:OfflineUnits(_OfflineDelta)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(XFG.Player.Unit:GetTimeStamp() + 60 < GetServerTime()) then
        XFG:Debug(LogCategory, "Sending heartbeat")
        XFG.Network.Sender:BroadcastUnitData(XFG.Player.Unit)
    end
end