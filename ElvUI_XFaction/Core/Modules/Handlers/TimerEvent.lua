local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'
local _OfflineTimer = 60       -- Seconds between checks if someone is offline
local _HeartbeatDelta = 60 * 2 -- Seconds between sending your own status, regardless if things have changed
local _GuildRosterDelta = 30   -- Seconds between local guild scans
local _PingFriends = 60 * 5    -- Seconds between pinging friends

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
		XFG:ScheduleTimer(self.CallbackDelayedStartTimer, 15) -- config
        XFG:ScheduleRepeatingTimer(self.CallbackMailboxTimer, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", 60 * 5)
        XFG:ScheduleRepeatingTimer(self.CallbackBNetMailboxTimer, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled BNet mailbox purge to occur every %d seconds", 60 * 5)
        XFG.Cache.CallbackTimerID = XFG:ScheduleRepeatingTimer(self.CallbackLogin, 1) -- config
        XFG:Info(LogCategory, "Scheduled initialization to occur once guild information is available")
        XFG:ScheduleRepeatingTimer(self.CallbackOffline, _OfflineTimer) -- config
        XFG:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", _OfflineTimer)
        XFG:ScheduleRepeatingTimer(self.CallbackHeartbeat, _HeartbeatDelta) -- config
        XFG:Info(LogCategory, "Scheduled heartbeat for %d seconds", _HeartbeatDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackGuildRoster, _GuildRosterDelta) -- config
        XFG:Info(LogCategory, "Scheduled forcing local guild roster updates for %d seconds", _GuildRosterDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackPingFriends, XFG.Network.BNet.PingTimer) -- config
        XFG:Info(LogCategory, "Scheduled to ping friends every %d seconds", XFG.Network.BNet.PingTimer)
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

function TimerEvent:CallbackDelayedStartTimer()
    if(XFG.Initialized and XFG.Network.Outbox:GetLocalChannel() == nil) then
        -- This will fire an event that ChannelEvent handler catches and updates
        JoinChannelByName(XFG.Network.ChannelName)
    end

    -- This is here as to get ping responses first and know who is running addon
    if(XFG.DB.UIReload == false) then
        XFG.Network.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Network.Message.Subject.LOGIN)
    end
    XFG.DB.UIReload = false
end

-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
    XFG.Network.Mailbox:Purge()
end

-- Cleanup BNet mailbox
function TimerEvent:CallbackBNetMailboxTimer()
    XFG.Network.BNet.Comm:Purge()
end

-- WoW has funky timing about getting guild and race info on first login, its not before PLAYER_ENTERING_WORLD so have to poll
function TimerEvent:CallbackLogin()

    local _, _, _RaceName = GetPlayerInfoByGUID(XFG.Player.GUID)

    if(IsAddOnLoaded(XFG.AddonName) and _RaceName ~= nil) then
        XFG:Info(LogCategory, "Addon is loaded, disabling poller and continuing setup")
        XFG:CancelTimer(XFG.Cache.CallbackTimerID)
        table.RemoveKey(XFG.Cache, 'CallbackTimerID')

        XFG.Player.Account = C_BattleNet.GetAccountInfoByGUID(XFG.Player.GUID)

        -- Is the player in a guild?
        local _GuildName = GetGuildInfo('player')
        if(_GuildName == nil) then
            XFG:CancelAllTimers()
            return
        end
        XFG.Player.Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildName)

        -- Is the player in a supported guild?
        if(XFG.Player.Guild == nil) then
            XFG:CancelAllTimers()
            return
        end

        XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
        XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
        XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()
        XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
        XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()
        XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()
        
        -- Leverage AceDB is persist remote unit information
        XFG.DataDB = LibStub("AceDB-3.0"):New("XFactionDataDB", defaults, true)
        XFG.DB = XFG.DataDB.char
        if(XFG.DB.Backup == nil) then XFG.DB.Backup = {} end
        XFG.ConfigDB = LibStub("AceDB-3.0"):New("XFactionConfigDB", defaults, true)
        XFG.Config = XFG.ConfigDB.profile

        XFG.Confederate = Confederate:new()
        XFG.Confederate:SetName('Eternal Kingdom')
        XFG.Confederate:SetKey('EK')
        XFG.Confederate:SetMainRealmName('Proudmoore')
        XFG.Confederate:SetMainGuildName('Eternal Kingdom')

        -- If this is a reload, restore non-local guild members
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
            elseif(_UnitData:GetKey() ~= nil and XFG.Confederate:Contains(_UnitData:GetKey())) then
                XFG.Confederate:RemoveUnit(_UnitData:GetKey())
            end
        end
        
        XFG.Network.Outbox = Outbox:new()
	    XFG.Network.Inbox = Inbox:new(); XFG.Network.Inbox:Initialize()
        XFG.Network.BNet.Comm = BNet:new(); BNet:Initialize()
        XFG.Network.BNet.Friends = FriendCollection:new(); XFG.Network.BNet.Friends:Initialize()
        XFG.Network.BNet.Links = LinkCollection:new(); XFG.Network.BNet.Links:Initialize()

        -- If this is a reload, restore friends addon flag
        if(XFG.DB.UIReload) then
            XFG.Network.BNet.Friends:RestoreBackup()
        end

        XFG.Network.Channels = ChannelCollection:new(); XFG.Network.Channels:Initialize()
        XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
        XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()        
	    XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
        XFG.Handlers.SpecEvent = SpecEvent:new(); XFG.Handlers.SpecEvent:Initialize()
        XFG.Handlers.CovenantEvent = CovenantEvent:new(); XFG.Handlers.CovenantEvent:Initialize()
        XFG.Handlers.SoulbindEvent = SoulbindEvent:new(); XFG.Handlers.SoulbindEvent:Initialize()
        XFG.Handlers.ProfessionEvent = ProfessionEvent:new(); XFG.Handlers.ProfessionEvent:Initialize()
        XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
        XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()

        -- Broadcast login, refresh DTs and ready to roll        
        wipe(XFG.Cache)
        wipe(XFG.DB.Backup)
        XFG.Initialized = true
        if(XFG.DB.UIReload == false) then
            XFG.Network.BNet.Comm:PingFriends()            
        end        
        DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
        DT:ForceUpdate_DataText(XFG.DataText.Soulbind.Name)
        DT:ForceUpdate_DataText(XFG.DataText.Links.Name)        
    end
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    local _EpochTime = GetServerTime()
    XFG.Confederate:OfflineUnits(_EpochTime)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(XFG.Initialized and XFG.Player.Unit:GetTimeStamp() + _HeartbeatDelta < GetServerTime()) then
        XFG:Debug(LogCategory, "Sending heartbeat")
        XFG.Network.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Network.Message.Subject.DATA)
    end
end

-- Periodically force a refresh
function TimerEvent:CallbackGuildRoster()
    if(XFG.Initialized) then
        C_GuildInfo.GuildRoster()
    end
end

-- Periodically ping friends to see who is running addon
function TimerEvent:CallbackPingFriends()
    XFG.Network.BNet.Comm:PingFriends()
end