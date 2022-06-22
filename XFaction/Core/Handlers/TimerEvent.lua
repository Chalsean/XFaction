local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local LogCategory = 'HETimer'

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
        XFG.Cache.LoginTimerID = XFG:ScheduleRepeatingTimer(self.CallbackLogin, 1)
        XFG:Info(LogCategory, "Scheduled monitor for guild information becoming available")        
        XFG:ScheduleRepeatingTimer(self.CallbackMailboxTimer, XFG.Settings.Network.Mailbox.Scan)
        XFG:Info(LogCategory, "Scheduled mailbox purge to occur every %d seconds", XFG.Settings.Network.Mailbox.Scan)
        XFG:ScheduleRepeatingTimer(self.CallbackBNetMailboxTimer, XFG.Settings.Network.Mailbox.Scan)
        XFG:Info(LogCategory, "Scheduled BNet mailbox purge to occur every %d seconds", XFG.Settings.Network.Mailbox.Scan)        
        XFG:ScheduleRepeatingTimer(self.CallbackOffline, XFG.Settings.Confederate.UnitScan)
        XFG:Info(LogCategory, "Scheduled to offline players not heard from in %d seconds", XFG.Settings.Confederate.UnitScan)
        XFG:ScheduleRepeatingTimer(self.CallbackHeartbeat, XFG.Settings.Player.Heartbeat)
        XFG:Info(LogCategory, "Scheduled heartbeat for %d seconds", XFG.Settings.Player.Heartbeat)
        XFG:ScheduleRepeatingTimer(self.CallbackGuildRoster, XFG.Settings.LocalGuild.ScanTimer)
        XFG:Info(LogCategory, "Scheduled forcing local guild roster updates for %d seconds", XFG.Settings.LocalGuild.ScanTimer)
        XFG:ScheduleRepeatingTimer(self.CallbackPingFriends, XFG.Settings.Network.BNet.Ping.Timer)
        XFG:Info(LogCategory, "Scheduled to ping friends every %d seconds", XFG.Settings.Network.BNet.Ping.Timer)
        XFG:ScheduleRepeatingTimer(self.CallbackLinks, XFG.Settings.Network.BNet.Link.Broadcast)
        XFG:Info(LogCategory, "Scheduled to broadcast links every %d seconds", XFG.Settings.Network.BNet.Link.Broadcast)
        XFG:ScheduleRepeatingTimer(self.CallbackStaleLinks, XFG.Settings.Network.BNet.Link.Scan)
        XFG:Info(LogCategory, "Scheduled to remove stale links after %d seconds", XFG.Settings.Network.BNet.Link.Scan)
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
        XFG:Error(LogCategory, 'Did not detect a guild')
        XFG:CancelAllTimers()
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
            XFG.Outbox = Outbox:new()
            XFG.Inbox = Inbox:new(); XFG.Inbox:Initialize()
            
            XFG.BNet = BNet:new(); BNet:Initialize()
            XFG.Friends = FriendCollection:new(); XFG.Friends:Initialize()
            XFG.Links = LinkCollection:new(); XFG.Links:Initialize()      

            -- If this is a reload, restore friends addon flag
            if(XFG.DB.UIReload) then
                XFG.Friends:RestoreBackup()
                XFG.Links:RestoreBackup()
            end
            XFG.Channels = ChannelCollection:new(); XFG.Channels:Initialize()

            -- Log into addon channel for realm/faction wide communication
            if(XFG.Outbox:HasLocalChannel() == false) then
                local _GuildInfo = C_Club.GetClubInfo(XFG.Player.Guild:GetID())
                local _Lines = string.Split(_GuildInfo.description, '\n')
                for _, _Line in pairs (_Lines) do
                    local _Parts = string.Split(_Line, ':')
                    if(_Parts[1] == 'XFc') then
                        XFG.Settings.Network.Channel.Name = _Parts[2]
                        XFG.Settings.Network.Channel.Password = _Parts[3]
                    end
                end
                -- Use temporary channel so if they stop using addon, the channel goes away
                if(XFG.Settings.Network.Channel.Password == nil) then
                    JoinChannelByName(XFG.Settings.Network.Channel.Name)
                else
                    JoinChannelByName(XFG.Settings.Network.Channel.Name, XFG.Settings.Network.Channel.Password)
                end
                XFG:Info(LogCategory, 'Joined temporary confederate channel [%s]', XFG.Settings.Network.Channel.Name)
                local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(XFG.Settings.Network.Channel.Name)
                local _NewChannel = Channel:new()
			    _NewChannel:SetKey(_ChannelInfo.shortcut)
			    _NewChannel:SetID(_ChannelInfo.localID)
			    _NewChannel:SetShortName(_ChannelInfo.shortcut)
			    XFG.Channels:AddChannel(_NewChannel)
                if(_NewChannel:GetKey() == XFG.Settings.Network.Channel.Name) then
                    XFG.Outbox:SetLocalChannel(_NewChannel)
                end
            end

            -- Register handlers
            XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
            XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()        
            XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
            XFG.Handlers.PlayerEvent = PlayerEvent:new(); XFG.Handlers.PlayerEvent:Initialize()
            XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
            XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()
            XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
            
            if(XFG.DB.UIReload == false) then
                -- Ping friends to find out whos available for BNet
                XFG.BNet:PingFriends()                 
            end

            -- This is stuff waiting a few seconds for ping responses
            XFG:ScheduleTimer(XFG.Handlers.TimerEvent.CallbackDelayedStartTimer, 7)

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
    if(XFG.DB.UIReload == false) then
        XFG.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Settings.Network.Message.Subject.LOGIN)
        XFG.Links:BroadcastLinks()
    end
    XFG.DB.UIReload = false
end

-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
    local _EpochTime = GetServerTime() - XFG.Settings.Network.Mailbox.Stale
    XFG.Mailbox:Purge(_EpochTime)
end

-- Cleanup BNet mailbox
function TimerEvent:CallbackBNetMailboxTimer()
    local _EpochTime = GetServerTime() - XFG.Settings.Network.Mailbox.Stale
    XFG.BNet:Purge(_EpochTime)
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    local _EpochTime = GetServerTime() - XFG.Settings.Confederate.UnitStale
    XFG.Confederate:OfflineUnits(_EpochTime)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(XFG.Initialized and XFG.Player.LastBroadcast < GetServerTime() - XFG.Settings.Player.Heartbeat) then
        XFG:Debug(LogCategory, "Sending heartbeat")
        XFG.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Settings.Network.Message.Subject.DATA)
    end
end

-- Periodically force a refresh
function TimerEvent:CallbackGuildRoster()
    if(XFG.Initialized and IsInGuild()) then
        C_GuildInfo.GuildRoster()
    end
end

-- Periodically ping friends to see who is running addon
function TimerEvent:CallbackPingFriends()
    XFG.BNet:PingFriends()
end

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
    XFG.Links:BroadcastLinks()
end

-- Periodically purge stale links
function TimerEvent:CallbackStaleLinks()
    local _EpochTime = GetServerTime() - XFG.Settings.Network.BNet.Link.Stale
    XFG.Links:PurgeStaleLinks(_EpochTime)
end