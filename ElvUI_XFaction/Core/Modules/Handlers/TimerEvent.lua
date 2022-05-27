local EKX, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
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
		--EKX:ScheduleTimer(self.CallbackChannelTimer, 15) -- config
        --EKX:ScheduleRepeatingTimer(self.CallbackGarbageTimer, 60) -- config
        EKX:Info(LogCategory, "Scheduled memory garbage collection to occur every %d seconds", 60)
        EKX:ScheduleRepeatingTimer(self.CallbackMailboxTimer, 60 * 5) -- config
        EKX:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", 60 * 5)
        EKX.Cache.CallbackTimerID = EKX:ScheduleRepeatingTimer(self.CallbackLogin, 1) -- config
        EKX:Info(LogCategory, "Scheduled initialization to occur once guild information is available")
        EKX:ScheduleRepeatingTimer(self.CallbackOffline, _OfflineDelta) -- config
        EKX:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", _OfflineDelta)
        EKX:ScheduleRepeatingTimer(self.CallbackHeartbeat, 150) -- config
        EKX:Info(LogCategory, "Scheduled heartbeat for %d seconds", 120)
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
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

-- Wait for General chat to grab #1
function TimerEvent:CallbackChannelTimer()
    EKX.Handlers.ChannelEvent = ChannelEvent:new(); EKX.Handlers.ChannelEvent:Initialize()
    if(EKX.Network.Sender:GetLocalChannel() == nil) then
        -- This will fire an event that ChannelEvent handler catches and updates
        JoinChannelByName(EKX.Network.ChannelName)
    end
end

-- Force garbage cleanup
function TimerEvent:CallbackGarbageTimer()
    collectgarbage() -- This identifies objects to clean and calls finalizers
    collectgarbage() -- The second call actually deletes the objects
end

-- Force garbage cleanup
function TimerEvent:CallbackMailboxTimer()
    EKX.Network.Mailbox:Purge()
end

-- WoW has funky timing about getting guild info on first login, its not before PLAYER_ENTERING_WORLD so have to poll
function TimerEvent:CallbackLogin(arg1)
    EKX.Player.GuildName = GetGuildInfo('player')

    if(EKX.Player.GuildName ~= nil) then
        EKX:Info(LogCategory, "Successfully got guild info, disabling poller and continuing setup")
        EKX:CancelTimer(EKX.Cache.CallbackTimerID)
        table.RemoveKey(EKX.Cache, 'CallbackTimerID')

        EKX:Info(LogCategory, "Initializing local guild roster cache")
	    local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
	
        for i = 1, _TotalMembers do
            -- Until I can figure out how to hook the constructors, will have to call init explicitly
            local _UnitData = Unit:new()
            _UnitData:Initialize(i)
            if(_UnitData:IsOnline()) then
                EKX.Guild:AddUnit(_UnitData)

                if(_UnitData:IsPlayer()) then
                    EKX.Player.Unit = _UnitData
                    EKX.Handlers.ChatEvent = ChatEvent:new(); EKX.Handlers.ChatEvent:Initialize()
                    EKX.Player.Unit:Print()

                    if(EKX.UIReload == false) then
                        EKX.Network.Sender:BroadcastUnitData(_UnitData)
                    end
                    EKX.UIReload = false
                end
            end
        end

        -- These event handlers have a dependency on player data being populated
        EKX.Handlers.SpecEvent = SpecEvent:new(); EKX.Handlers.SpecEvent:Initialize()
        EKX.Handlers.CovenantEvent = CovenantEvent:new(); EKX.Handlers.CovenantEvent:Initialize()
        EKX.Handlers.SoulbindEvent = SoulbindEvent:new(); EKX.Handlers.SoulbindEvent:Initialize()
        EKX.Handlers.ProfessionEvent = ProfessionEvent:new(); EKX.Handlers.ProfessionEvent:Initialize()
        EKX.Handlers.GuildEvent = GuildEvent:new(); EKX.Handlers.GuildEvent:Initialize()

        EKX.Initialized = true
        DT:ForceUpdate_DataText(EKX.DataText.Guild.Name)
    end
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    EKX.Guild:OfflineUnits(_OfflineDelta)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(EKX.Player.Unit:GetTimeStamp() + 120 < GetServerTime()) then
        EKX:Debug(LogCategory, "Sending heartbeat")
        EKX.Network.Sender:BroadcastUnitData(EKX.Player.Unit)
    end
end