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

local function CreateTimer(inName, inDelta, inCallback, inInstance, inInstanceCombat)
    local _Timer = Timer:new()
    _Timer:SetName(inName)
    _Timer:Initialize()
    _Timer:SetDelta(inDelta)
    _Timer:SetCallback(inCallback)
    _Timer:IsInstance(inInstance)
    _Timer:IsInstanceCombat(inInstanceCombat)
    _Timer:Start()
    XFG.Timers:AddTimer(_Timer)
end

function TimerEvent:Initialize()
	if(self:IsInitialized() == false) then
        XFG.Cache.LoginTimerStart = GetServerTime()
        CreateTimer('Login', 1, XFG.Handlers.TimerEvent.CallbackLogin, true, true)
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
    -- If havent gotten guild info after Xs, give up. probably not in a guild
    if(XFG.Cache.LoginTimerStart + XFG.Settings.LocalGuild.LoginGiveUp < GetServerTime()) then
        XFG:Error(LogCategory, 'Did not detect a guild')
        XFG.Timers:Stop()
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

    -- Ensure we get the player guid and faction without failure
    if(XFG.Player.GUID == nil) then
        XFG.Player.GUID = UnitGUID('player')
    end
    if(XFG.Player.Faction == nil) then
        XFG.Player.Faction = XFG.Factions:GetFactionByName(UnitFactionGroup('player'))
    end

    if(IsInGuild()) then
        -- Even though it says were in guild, the following call still may not work on initial login, hence the poller
        local _GuildID = C_Club.GetGuildClubId()
        -- Sanity check
        if(XFG.Player.GUID ~= nil and XFG.Player.Faction ~= nil and _GuildID ~= nil) then
            -- Now that guild info is available we can finish setup
            XFG:Debug(LogCategory, 'Guild info is loaded, proceeding with setup')
            local _Timer = XFG.Timers:GetTimer('Login')
            XFG.Timers:RemoveTimer(_Timer)

            XFG:Info(LogCategory, 'WoW client version [%s:%s]', XFG.WoW:GetName(), XFG.WoW:GetVersion():GetKey())
            XFG:Info(LogCategory, 'XFaction version [%s]', XFG.Version)

            local _GuildInfo = C_Club.GetClubInfo(_GuildID)
            XFG.Confederate = Confederate:new()    
            
            -- Parse out configuration from guild information so GMs have control
            local _XFData
            local _DataIn = string.match(_GuildInfo.description, 'XF:(.-):XF')
            if (_DataIn ~= nil) then
                -- Decompress and deserialize XFaction data
                local _Decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(_DataIn))
                local _, _Deserialized = XFG:Deserialize(_Decompressed)
                XFG:Debug(LogCategory, 'Data from config %s', _Deserialized)
                _XFData = _Deserialized
            else
                _XFData = _GuildInfo.description
            end

            for _, _Line in ipairs(string.Split(_XFData, '\n')) do
                -- Confederate information
                if(string.find(_Line, 'XFn')) then                    
                    local _Name, _Initials = _Line:match('XFn:(.-):(.+)')
                    XFG:Debug(LogCategory, 'Initializing confederate %s <%s>', _Name, _Initials)
                    Confederate:SetName(_Name)
                    Confederate:SetKey(_Initials)
                    XFG.Settings.Network.Message.Tag.LOCAL = _Initials .. 'XF'
                    XFG.Settings.Network.Message.Tag.BNET = _Initials .. 'BNET'
                -- Guild within the confederate
                elseif(string.find(_Line, 'XFg')) then
                    local _RealmNumber, _FactionInitial, _GuildName, _GuildInitials = _Line:match('XFg:(.-):(.-):(.-):(.+)')
                    local _, _RealmName = XFG.Lib.Realm:GetRealmInfoByID(_RealmNumber)
                    -- Create each realm once
                    if(XFG.Realms:Contains(_RealmName) == false) then
                        XFG:Debug(LogCategory, 'Initializing realm [%s]', _RealmName)
                        local _NewRealm = Realm:new()
                        _NewRealm:SetKey(_RealmName)
                        _NewRealm:SetName(_RealmName)
                        _NewRealm:SetAPIName(string.gsub(_RealmName, '%s+', ''))
                        _NewRealm:Initialize()
                        XFG.Realms:AddRealm(_NewRealm)
                    end
                    local _Realm = XFG.Realms:GetRealm(_RealmName)                    
                    local _Faction = XFG.Factions:GetFactionByName(_FactionInitial == 'A' and 'Alliance' or 'Horde')

                    XFG:Debug(LogCategory, 'Initializing guild %s <%s>', _GuildName, _GuildInitials)
                    local _NewGuild = Guild:new()
                    _NewGuild:Initialize()
                    _NewGuild:SetKey(_GuildInitials)
                    _NewGuild:SetName(_GuildName)
                    _NewGuild:SetFaction(_Faction)
                    _NewGuild:SetRealm(_Realm)
                    _NewGuild:SetInitials(_GuildInitials)
                    XFG.Guilds:AddGuild(_NewGuild)
                -- Local channel for same realm/faction communication
                elseif(string.find(_Line, 'XFc')) then
                    XFG.Settings.Network.Channel.Name, XFG.Settings.Network.Channel.Password = _Line:match('XFc:(.-):(.*)')
                -- If you keep your alts at a certain rank, this will flag them as alts in comms/DTs
                elseif(string.find(_Line, 'XFa')) then
                    local _AltRank = _Line:match('XFa:(.+)')
                    XFG.Settings.Confederate.AltRank = _AltRank
                elseif(string.find(_Line, 'XFt')) then
                    local _TeamInitial, _TeamName = _Line:match('XFt:(%a):(%a+)')
                    local _NewTeam = Team:new()
                    _NewTeam:SetName(_TeamName)
                    _NewTeam:SetInitials(_TeamInitial)
                    _NewTeam:Initialize()
                    XFG.Teams:AddTeam(_NewTeam)
                end
            end

            -- Backwards compat for EK
            if(XFG.Teams:GetCount() == 0) then
                XFG.Teams:Initialize()
            end

            -- Ensure player is on supported realm
            local _RealmName = GetRealmName()
            XFG.Player.Realm = XFG.Realms:GetRealm(_RealmName)
            if(XFG.Player.Realm == nil) then
                XFG:Error(LogCategory, 'Player is not on a supported realm [%s]', _RealmName)
                XFG:CancelAllTimers()
                return
            end
            -- Ensure player is on supported guild
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
            local _InInstance, _InstanceType = IsInInstance()
            XFG.Player.InInstance = _InInstance
            XFG.Targets = TargetCollection:new(); XFG.Targets:Initialize()

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
            XFG:Info(LogCategory, 'Initializing local guild roster')
            for _, _MemberID in pairs (C_Club.GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
                local _UnitData = Unit:new()
                if(pcall(function () _UnitData:Initialize(_MemberID) end)) then
                    if(_UnitData:IsOnline()) then
                        if(not XFG.Confederate:Contains(_UnitData:GetKey())) then
                            XFG.Confederate:AddUnit(_UnitData)
                        end
                        if(_UnitData:IsPlayer()) then
                            XFG.Player.Unit:Print()            
                        end
                    end
                end
            end
            if(XFG.Player.Unit == nil) then
                local _UnitData = Unit:new(); _UnitData:Initialize()
                XFG.Player.Unit = _UnitData
            end

            -- Start network setup
            XFG.Mailbox = Mailbox:new(); XFG.Mailbox:Initialize()            
            XFG.Outbox = Outbox:new()
            XFG.Inbox = Inbox:new(); XFG.Inbox:Initialize()            
            XFG.BNet = BNet:new(); BNet:Initialize()
            XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()
            XFG.Friends = FriendCollection:new(); XFG.Friends:Initialize()
            XFG.Nodes = NodeCollection:new(); XFG.Nodes:Initialize()
            XFG.Links = LinkCollection:new(); XFG.Links:Initialize()      

            -- If this is a reload, restore friends addon flag
            if(XFG.DB.UIReload) then
                XFG.Friends:RestoreBackup()
                XFG.Links:RestoreBackup()
            end

            -- Log into addon channel for realm/faction wide communication
            XFG.Channels = ChannelCollection:new(); XFG.Channels:Initialize()
            XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
            if(XFG.Settings.Network.Channel.Password == nil) then
                JoinChannelByName(XFG.Settings.Network.Channel.Name)
            else
                JoinChannelByName(XFG.Settings.Network.Channel.Name, XFG.Settings.Network.Channel.Password)
            end
            XFG:Info(LogCategory, 'Joined confederate channel [%s]', XFG.Settings.Network.Channel.Name)
            local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(XFG.Settings.Network.Channel.Name)
            local _NewChannel = Channel:new()
            _NewChannel:SetKey(_ChannelInfo.shortcut)
            _NewChannel:SetID(_ChannelInfo.localID)
            _NewChannel:SetShortName(_ChannelInfo.shortcut)
            XFG.Channels:AddChannel(_NewChannel)            
            XFG.Outbox:SetLocalChannel(_NewChannel)

            -- Start timers
            CreateTimer('Heartbeat', XFG.Settings.Player.Heartbeat, XFG.Handlers.TimerEvent.CallbackHeartbeat, true, false)
            CreateTimer('Links', XFG.Settings.Network.BNet.Link.Broadcast, XFG.Handlers.TimerEvent.CallbackLinks, true, false)
            CreateTimer('Mailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackMailboxTimer, false, false)
            CreateTimer('BNetMailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackBNetMailboxTimer, false, false)
            CreateTimer('Ping', XFG.Settings.Network.BNet.Ping.Timer, XFG.Handlers.TimerEvent.CallbackPingFriends, true, false)
            CreateTimer('Roster', XFG.Settings.LocalGuild.ScanTimer, XFG.Handlers.TimerEvent.CallbackGuildRoster, true, false)
            CreateTimer('StaleLinks', XFG.Settings.Network.BNet.Link.Scan, XFG.Handlers.TimerEvent.CallbackStaleLinks, true, false)
            CreateTimer('Offline', XFG.Settings.Confederate.UnitScan, XFG.Handlers.TimerEvent.CallbackOffline, true, false)

            -- Register event handlers
            XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()            
            XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
            XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()
            XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
            XFG.Handlers.PlayerEvent = PlayerEvent:new(); XFG.Handlers.PlayerEvent:Initialize()

            -- Ping friends to find out whos available for BNet
            if(XFG.DB.UIReload == false) then                
                XFG.Handlers.TimerEvent:CallbackPingFriends()      
            end
 
            -- This is stuff waiting a few seconds for ping responses or Blizz setup to finish
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
    if(not XFG.DB.UIReload) then
        XFG.Channels:SetChannelLast(XFG.Outbox:GetLocalChannel():GetKey())
        XFG.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Settings.Network.Message.Subject.LOGIN)
        XFG.Links:BroadcastLinks()
    end
    XFG.DB.UIReload = false
end

-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
    local _EpochTime = GetServerTime() - XFG.Settings.Network.Mailbox.Stale
    XFG.Mailbox:Purge(_EpochTime)
    local _Timer = XFG.Timers:GetTimer('Mailbox')
    _Timer:SetLastRan(GetServerTime())
end

-- Cleanup BNet mailbox
function TimerEvent:CallbackBNetMailboxTimer()
    local _EpochTime = GetServerTime() - XFG.Settings.Network.Mailbox.Stale
    XFG.BNet:Purge(_EpochTime)
    local _Timer = XFG.Timers:GetTimer('BNetMailbox')
    _Timer:SetLastRan(GetServerTime())
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
    local _EpochTime = GetServerTime() - XFG.Settings.Confederate.UnitStale
    XFG.Confederate:OfflineUnits(_EpochTime)
    local _Timer = XFG.Timers:GetTimer('Offline')
    _Timer:SetLastRan(GetServerTime())
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
    if(XFG.Initialized and XFG.Player.LastBroadcast < GetServerTime() - XFG.Settings.Player.Heartbeat) then
        XFG:Debug(LogCategory, "Sending heartbeat")
        XFG.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Settings.Network.Message.Subject.DATA)
    end
    local _Timer = XFG.Timers:GetTimer('Heartbeat')
    _Timer:SetLastRan(GetServerTime())
end

-- Periodically force a refresh
function TimerEvent:CallbackGuildRoster()
    if(XFG.Initialized and IsInGuild()) then
        C_GuildInfo.GuildRoster()
    end
    local _Timer = XFG.Timers:GetTimer('Roster')
    _Timer:SetLastRan(GetServerTime())
end

-- Periodically ping friends to see who is running addon
function TimerEvent:CallbackPingFriends()
    for _, _Friend in XFG.Friends:Iterator() do
        if(not _Friend:IsRunningAddon()) then
            XFG.BNet:PingFriend(_Friend)
        end
    end
    local _Timer = XFG.Timers:GetTimer('Ping')
    _Timer:SetLastRan(GetServerTime())
end

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
    XFG.Links:BroadcastLinks()
    local _Timer = XFG.Timers:GetTimer('Links')
    _Timer:SetLastRan(GetServerTime())
end

-- Periodically purge stale links
function TimerEvent:CallbackStaleLinks()
    local _EpochTime = GetServerTime() - XFG.Settings.Network.BNet.Link.Stale
    XFG.Links:PurgeStaleLinks(_EpochTime)
    local _Timer = XFG.Timers:GetTimer('StaleLinks')
    _Timer:SetLastRan(GetServerTime())
end