local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'
local _OfflineTimer = 60       -- Seconds between checks if someone is offline
local _HeartbeatDelta = 60 * 2 -- Seconds between sending your own status, regardless if things have changed
local _GuildRosterDelta = 30   -- Seconds between local guild scans
local _PingFriends = 60 * 1    -- Seconds between pinging friends
local _StaleLinks = 60 * 10    -- Seconds until considering a link stale

TimerEvent = {}

function TimerEvent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Initialized = false

    return Object
end

function TimerEvent:Initialize()
	if(self:IsInitialized() == false) then
        XFG.Cache.LoginTimerStart = GetServerTime()

        XFG.Cache.LoginTimerID = XFG:ScheduleRepeatingTimer(self.CallbackLogin, 1) -- config
        XFG:Info(LogCategory, "Scheduled monitor for guild information becoming available")
        
        XFG:ScheduleRepeatingTimer(self.CallbackMailboxTimer, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", 60 * 5)
        XFG:ScheduleRepeatingTimer(self.CallbackBNetMailboxTimer, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled BNet mailbox purge to occur every %d seconds", 60 * 5)        
        XFG:ScheduleRepeatingTimer(self.CallbackOffline, _OfflineTimer) -- config
        XFG:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", _OfflineTimer)
        XFG:ScheduleRepeatingTimer(self.CallbackHeartbeat, _HeartbeatDelta) -- config
        XFG:Info(LogCategory, "Scheduled heartbeat for %d seconds", _HeartbeatDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackGuildRoster, _GuildRosterDelta) -- config
        XFG:Info(LogCategory, "Scheduled forcing local guild roster updates for %d seconds", _GuildRosterDelta)
        XFG:ScheduleRepeatingTimer(self.CallbackPingFriends, XFG.Network.BNet.PingTimer) -- config
        XFG:Info(LogCategory, "Scheduled to ping friends every %d seconds", XFG.Network.BNet.PingTimer)
        XFG:ScheduleRepeatingTimer(self.CallbackLinks, 60 * 5) -- config
        XFG:Info(LogCategory, "Scheduled to broadcast links every %d seconds", 60 * 5)
        XFG:ScheduleRepeatingTimer(self.CallbackStaleLinks, _StaleLinks) -- config
        XFG:Info(LogCategory, "Scheduled to remove stale links after %d seconds", _StaleLinks)

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

function TimerEvent:CallbackLogin()
    -- If havent gotten guild info after 30s, give up. probably not in a guild
    -- 10s is probably feasible but trying to be safe for lesser hardware or slow connections
    if(XFG.Cache.LoginTimerStart + 30 < GetServerTime()) then
        XFG:CancelTimer(XFG.Cache.LoginTimerID)
        return
    end

    -- Get AceDB up and running as early as possible, its not available until addon is loaded
    if(IsAddOnLoaded(XFG.AddonName) and XFG.Config == nil) then        
        XFG.DataDB = LibStub("AceDB-3.0"):New("XFactionDB", XFG.Defaults, true)
        XFG.DB = XFG.DataDB.char
        XFG.Config = XFG.DataDB.profile
        if(XFG.DB.Backup == nil) then XFG.DB.Backup = {} end
        if(XFG.DB.UIReload == nil) then XFG.DB.UIReload = false end
        XFG:LoadConfigs()
    end

    if(IsInGuild()) then
        -- Even though it says were in guild, the following call still may not work on initial login, hence the poller
        local _GuildID = C_Club.GetGuildClubId()
        if(_GuildID ~= nil) then
            -- Now that guild info is available we can finish setup
            XFG:Debug(LogCategory, 'Guild info is loaded, proceeding with setup')
            XFG:CancelTimer(XFG.Cache.LoginTimerID)

            local _GuildInfo = C_Club.GetClubInfo(_GuildID)
            XFG.Player.Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildInfo.name)
            if(XFG.Player.Guild == nil) then
                XFG:Error(LogCategory, 'Player is not in supported guild ' .. tostring(_GuildName))
                XFG:CancelAllTimers()
                return
            end
            XFG.Player.Guild:SetID(_GuildID)
            for _, _Stream in pairs (C_Club.GetStreams(_GuildID)) do
                if(_Stream.streamType == 1) then
                    XFG.Player.Guild:SetStreamID(_Stream.streamId)
                    break
                end
            end

            XFG:Debug(LogCategory, 'Player realm [%s]', XFG.Player.Realm:GetName())
            XFG:Debug(LogCategory, 'Player guild [%s]', XFG.Player.Guild:GetName())

            XFG.Confederate = Confederate:new()
            XFG.Confederate:SetName(XFG.Settings.Confederate.Name)
            XFG.Confederate:SetKey(XFG.Settings.Confederate.Initials)
            XFG:Debug(LogCategory, 'Player confederate [%s]', XFG.Confederate:GetName())
            XFG.Ranks = RankCollection:new(); XFG.Ranks:Initialize()

            -- Some of this data (spec) is like guild where its not available for a time after initial login
            -- Seems to align with guild data becoming available
            XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
            XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
            XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()
            XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
            XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()
            XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()

            -- If this is a reload, restore non-local guild members
            if(XFG.DB.UIReload) then
                XFG.Confederate:RestoreBackup()
            end

            -- Scan local guild roster
            XFG:Info(LogCategory, "Initializing local guild roster cache")
            for _, _MemberID in pairs (C_Club.GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
                local _UnitData = Unit:new()
                _UnitData:Initialize(_MemberID)
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

            -- Start network setup
            XFG.Network.Outbox = Outbox:new()
            XFG.Network.Inbox = Inbox:new(); XFG.Network.Inbox:Initialize()
            
            XFG.Network.BNet.Comm = BNet:new(); BNet:Initialize()
            XFG.Network.BNet.Friends = FriendCollection:new(); XFG.Network.BNet.Friends:Initialize()
            XFG.Network.BNet.Links = LinkCollection:new(); XFG.Network.BNet.Links:Initialize()      

            -- If this is a reload, restore friends addon flag
            if(XFG.DB.UIReload) then
                XFG.Network.BNet.Friends:RestoreBackup()
                XFG.Network.BNet.Links:RestoreBackup()
            end
            XFG.Network.Channels = ChannelCollection:new(); XFG.Network.Channels:Initialize()

            -- Use temporary so if they stop using addon, the channel goes away
            if(XFG.Network.Outbox:HasLocalChannel() == false) then
                local _GuildInfo = C_Club.GetClubInfo(XFG.Player.Guild:GetID())
                local _Lines = string.Split(_GuildInfo.description, '\n')
                for _, _Line in pairs (_Lines) do
                    local _Parts = string.Split(_Line, ':')
                    if(_Parts[1] == 'XFc') then
                        XFG.Network.Channel.Name = _Parts[2]
                        XFG.Network.Channel.Password = _Parts[3]
                    end
                end
                JoinTemporaryChannel(XFG.Network.Channel.Name, XFG.Network.Channel.Password)
                XFG:Info(LogCategory, 'Joined temporary confederate channel [%s]', XFG.Network.Channel.Name)
                XFG.Network.Channels:SyncChannels()
            end

            -- Register handlers
            XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
            XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()        
            XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
            XFG.Handlers.SpecEvent = SpecEvent:new(); XFG.Handlers.SpecEvent:Initialize()
            XFG.Handlers.CovenantEvent = CovenantEvent:new(); XFG.Handlers.CovenantEvent:Initialize()
            XFG.Handlers.SoulbindEvent = SoulbindEvent:new(); XFG.Handlers.SoulbindEvent:Initialize()
            XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
            XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()
            XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()

            -- Broadcast locally, its not dependent upon BNet

            -- Ping friends to find out whos available for BNet
            if(XFG.DB.UIReload == false) then
                XFG.Network.BNet.Comm:PingFriends()                 
            end

            -- This is stuff waiting a few seconds for ping responses
            XFG:ScheduleTimer(XFG.Handlers.TimerEvent.CallbackDelayedStartTimer, 10)

            XFG.Initialized = true

            -- Refresh brokers (theyve been waiting on XFG.Initialized flag)
            XFG.DataText.Guild:RefreshBroker()
            XFG.DataText.Soulbind:RefreshBroker()
            XFG.DataText.Links:RefreshBroker()

            wipe(XFG.DB.Backup)
        end
    end
end

function TimerEvent:CallbackDelayedStartTimer()
    -- Message just to BNet, already broadcasted locally
    if(XFG.DB.UIReload == false) then
        XFG.Network.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Network.Message.Subject.LOGIN)
        XFG.Network.BNet.Links:BroadcastLinks()
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

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
    XFG.Network.BNet.Links:BroadcastLinks()
end

-- Periodically purge stale links
function TimerEvent:CallbackStaleLinks()
    local _EpochTime = GetServerTime() - _StaleLinks
    XFG.Network.BNet.Links:PurgeStaleLinks(_EpochTime)
end