local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'
local _OfflineDelta = 60 * 5   -- Seconds before you consider another unit offline
local _HeartbeatDelta = 60 * 2 -- Seconds between sending your own status, regardless if things have changed
local _GuildRosterDelta = 30   -- Seconds between local guild scans

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
		--XFG:ScheduleTimer(self.CallbackChannelTimer, 15) -- config
        XFG:ScheduleRepeatingTimer(self.CallbackGarbageTimer, 60) -- config
        XFG:Info(LogCategory, "Scheduled memory garbage collection to occur every %d seconds", 60)
        XFG:ScheduleRepeatingTimer(self.CallbackMailboxTimer, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", 60 * 5)
        XFG.Cache.CallbackTimerID = XFG:ScheduleRepeatingTimer(self.CallbackLogin, 1) -- config
        XFG:Info(LogCategory, "Scheduled initialization to occur once guild information is available")
        XFG:ScheduleRepeatingTimer(self.CallbackOffline, _OfflineDelta) -- config
        XFG:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", _OfflineDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackHeartbeat, _HeartbeatDelta) -- config
        XFG:Info(LogCategory, "Scheduled heartbeat for %d seconds", _HeartbeatDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackGuildRoster, _GuildRosterDelta) -- config
        XFG:Info(LogCategory, "Scheduled forcing guild roster updates for %d seconds", _GuildRosterDelta)
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

-- WoW has funky timing about getting guild and race info on first login, its not before PLAYER_ENTERING_WORLD so have to poll
function TimerEvent:CallbackLogin()

    local _, _, _RaceName = GetPlayerInfoByGUID(XFG.Player.GUID)

    if(IsAddOnLoaded(XFG.AddonName) and _RaceName ~= nil) then
        XFG:Info(LogCategory, "Addon is loaded, disabling poller and continuing setup")
        XFG:CancelTimer(XFG.Cache.CallbackTimerID)
        table.RemoveKey(XFG.Cache, 'CallbackTimerID')

        XFG.Player.Guild = XFG.Guilds:GetGuildByFactionGuildName(XFG.Player.Faction, GetGuildInfo('player'))

        XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
        XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
        XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()
        XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
        XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()
        XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()
        
        -- Leverage AceDB is persist remote unit information
        XFG.DataDB = LibStub("AceDB-3.0"):New("XFactionDataDB", defaults, true)
        XFG.DB = XFG.DataDB.char
        XFG.ConfigDB = LibStub("AceDB-3.0"):New("XFactionConfigDB", defaults, true)
        XFG.Config = XFG.ConfigDB.profile

        XFG.Confederate = Confederate:new()
        XFG.Confederate:SetName('Eternal Kingdom')
        XFG.Confederate:SetKey('EK')
        XFG.Confederate:SetMainRealmName('Proudmoore')
        XFG.Confederate:SetMainGuildName('Eternal Kingdom')

        -- If this is a reload, restore backup
        if(XFG.DB.UIReload) then
            XFG.Confederate:RestoreBackup()
        end
  
        XFG:Info(LogCategory, "Initializing local guild roster cache")
	    local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
	
        for i = 1, _TotalMembers do
            local _UnitData = Unit:new()
            _UnitData:Initialize(i)
            if(_UnitData:IsOnline()) then
                XFG.Confederate:AddUnit(_UnitData)

                if(_UnitData:IsPlayer()) then
                    XFG.Player.Unit = _UnitData                    
                    XFG.Player.Unit:Print()                    
                end
            elseif(XFG.Confederate:Contains(_UnitData:GetKey())) then
                XFG.Confederate:RemoveUnit(_UnitData:GetKey())
            end
        end

        XFG.Network.Sender = Sender:new()
	    XFG.Network.Receiver = Receiver:new(); XFG.Network.Receiver:Initialize()
        XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
        XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()
        XFG.Network.Channels = ChannelCollection:new(); XFG.Network.Channels:Initialize()
	    XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()

        -- These event handlers have a dependency on player data being populated
        XFG.Handlers.SpecEvent = SpecEvent:new(); XFG.Handlers.SpecEvent:Initialize()
        XFG.Handlers.CovenantEvent = CovenantEvent:new(); XFG.Handlers.CovenantEvent:Initialize()
        XFG.Handlers.SoulbindEvent = SoulbindEvent:new(); XFG.Handlers.SoulbindEvent:Initialize()
        XFG.Handlers.ProfessionEvent = ProfessionEvent:new(); XFG.Handlers.ProfessionEvent:Initialize()
        XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()

        -- Broadcast login, refresh DTs and ready to roll
        XFG.Network.Sender:BroadcastUnitData(XFG.Player.Unit)
        XFG.DB.UIReload = false
        XFG.Initialized = true
        DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
        DT:ForceUpdate_DataText(XFG.DataText.Soulbind.Name)

        --XFG.Frames.Whisper = WhisperFrame:new(); XFG.Frames.Whisper:Initialize()
    end
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    XFG.Confederate:OfflineUnits(_OfflineDelta)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(XFG.Initialized and XFG.Player.Unit:GetTimeStamp() + _HeartbeatDelta < GetServerTime()) then
        XFG:Debug(LogCategory, "Sending heartbeat")
        XFG.Network.Sender:BroadcastUnitData(XFG.Player.Unit)
    end
end

-- Periodically force a refresh
function TimerEvent:CallbackGuildRoster()
    if(XFG.Initialized) then
        C_GuildInfo.GuildRoster()
    end
end