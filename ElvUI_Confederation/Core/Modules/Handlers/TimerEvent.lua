local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'
local _OfflineDelta = 300  -- Seconds before you consider another unit offline

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
		CON:ScheduleTimer(self.CallbackChannelTimer, 15) -- config
        CON:ScheduleRepeatingTimer(self.CallbackGarbageTimer, 60) -- config
        CON:Info(LogCategory, "Scheduled memory garbage collection to occur every %d seconds", 60)
        CON:ScheduleRepeatingTimer(self.CallbackMailboxTimer, 60 * 5) -- config
        CON:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", 60 * 5)
        CON.Cache.CallbackTimerID = CON:ScheduleRepeatingTimer(self.CallbackLogin, 1) -- config
        CON:Info(LogCategory, "Scheduled initialization to occur once guild information is available")
        CON:ScheduleRepeatingTimer(self.CallbackOffline, _OfflineDelta) -- config
        CON:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", _OfflineDelta)
        CON:ScheduleRepeatingTimer(self.CallbackHeartbeat, 150) -- config
        CON:Info(LogCategory, "Scheduled heartbeat for %d seconds", 120)
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
    CON:SingleLine(LogCategory)
    CON:Debug(LogCategory, ObjectName .. " Object")
    CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

-- Wait for General chat to grab #1
function TimerEvent:CallbackChannelTimer()
    CON.Handlers.ChannelEvent = ChannelEvent:new(); CON.Handlers.ChannelEvent:Initialize()
    if(CON.Network.Sender:GetLocalChannel() == nil) then
        -- This will fire an event that ChannelEvent handler catches and updates
        JoinChannelByName(CON.Network.ChannelName)
    end
end

-- Force garbage cleanup
function TimerEvent:CallbackGarbageTimer()
    collectgarbage() -- This identifies objects to clean and calls finalizers
    collectgarbage() -- The second call actually deletes the objects
end

-- Force garbage cleanup
function TimerEvent:CallbackMailboxTimer()
    CON.Network.Mailbox:Purge()
end

-- WoW has funky timing about getting guild info on first login, its not before PLAYER_ENTERING_WORLD so have to poll
function TimerEvent:CallbackLogin(arg1)
    CON.Player.GuildName = GetGuildInfo('player')

    if(CON.Player.GuildName ~= nil) then
        CON:Info(LogCategory, "Successfully got guild info, disabling poller and continuing setup")
        CON:CancelTimer(CON.Cache.CallbackTimerID)
        table.RemoveKey(CON.Cache, 'CallbackTimerID')

        CON:Info(LogCategory, "Initializing local guild roster cache")
	    local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
	
        for i = 1, _TotalMembers do
            -- Until I can figure out how to hook the constructors, will have to call init explicitly
            local _UnitData = Unit:new()
            _UnitData:Initialize(i)		
            CON.Confederate:AddUnit(_UnitData)

            if(_UnitData:IsPlayer()) then
                CON.Player.Unit = _UnitData
                CON.Handlers.ChatEvent = ChatEvent:new(); CON.Handlers.ChatEvent:Initialize()
                CON.Player.Unit:Print()

                if(CON.UIReload == false) then
                    CON.Network.Sender:BroadcastUnitData(_UnitData)
                end
                CON.UIReload = false
            end
        end

        -- These event handlers have a dependency on player data being populated
        CON.Handlers.SpecEvent = SpecEvent:new(); CON.Handlers.SpecEvent:Initialize()
        CON.Handlers.CovenantEvent = CovenantEvent:new(); CON.Handlers.CovenantEvent:Initialize()
        CON.Handlers.SoulbindEvent = SoulbindEvent:new(); CON.Handlers.SoulbindEvent:Initialize()
        CON.Handlers.ProfessionEvent = ProfessionEvent:new(); CON.Handlers.ProfessionEvent:Initialize()
        CON.Handlers.GuildEvent = GuildEvent:new(); CON.Handlers.GuildEvent:Initialize()        
    end
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    CON.Confederate:OfflineUnits(_OfflineDelta)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(CON.Player.Unit:GetTimeStamp() + 120 < GetServerTime()) then
        CON:Debug(LogCategory, "Sending heartbeat")
        CON.Network.Sender:BroadcastUnitData(CON.Player.Unit)
    end
end