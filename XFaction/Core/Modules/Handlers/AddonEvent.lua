local XFG, G = unpack(select(2, ...))
local ObjectName = 'AddonEvent'
local LogCategory = 'HEAddon'
local _OfflineTimer = 60       -- Seconds between checks if someone is offline
local _HeartbeatDelta = 60 * 2 -- Seconds between sending your own status, regardless if things have changed
local _GuildRosterDelta = 30   -- Seconds between local guild scans
local _PingFriends = 60 * 1    -- Seconds between pinging friends

AddonEvent = {}

function AddonEvent:new(inObject)
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

function AddonEvent:Initialize()
	if(self:IsInitialized() == false) then
        XFG:RegisterEvent('ADDON_LOADED', self.CallbackLoaded)
        XFG:Info(LogCategory, "Registered for ADDON_LOADED events")
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function AddonEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function AddonEvent:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function AddonEvent:CallbackLoaded(inAddonName)
    print('--------------')
    print('[' .. inAddonName .. ']')
    print('[' .. XFG.AddonName .. ']')
    if(inAddonName == XFG.AddonName) then
        print('got here')
        XFG:Info(LogCategory, "Addon is loaded, disabling poller and continuing setup")
       -- XFG:CancelTimer(XFG.Cache.CallbackTimerID)
       -- table.RemoveKey(XFG.Cache, 'CallbackTimerID')

        XFG.Player.Account = C_BattleNet.GetAccountInfoByGUID(XFG.Player.GUID)

        local _GuildID = C_Club.GetGuildClubId()
        if(_GuildID == nil) then
            XFG.Error(LogCategory, 'Player is not in a guild')
            XFG:CancelAllTimers()
            return
        end
        local _GuildInfo = C_Club.GetClubInfo(_GuildID)
        XFG.Player.Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildInfo.name)
        if(XFG.Player.Guild == nil) then
            XFG.Error(LogCategory, 'Player is not in supported guild ' .. tostring(_GuildName))
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

        XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
        XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
        XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()
        XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
        XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()
        XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()
        
        -- Leverage AceDB for persist remote unit information and configs
        XFG.DataDB = LibStub("AceDB-3.0"):New("XFactionDB", XFG.Defaults, true)
        XFG.DB = XFG.DataDB.char
        XFG.Config = XFG.DataDB.profile
        if(XFG.DB.Backup == nil) then XFG.DB.Backup = {} end
        if(XFG.DB.UIReload == nil) then XFG.DB.UIReload = false end
        XFG:LoadConfigs()        

        XFG.Confederate = Confederate:new()
        XFG.Confederate:SetName(XFG.Cache.Confederate.Name)
        XFG.Confederate:SetKey(XFG.Cache.Confederate.Initials)

        -- If this is a reload, restore non-local guild members
        if(XFG.DB.UIReload) then
            XFG.Confederate:RestoreBackup()
        end

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
        XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
        XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()        
	    XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
        XFG.Handlers.SpecEvent = SpecEvent:new(); XFG.Handlers.SpecEvent:Initialize()
        XFG.Handlers.CovenantEvent = CovenantEvent:new(); XFG.Handlers.CovenantEvent:Initialize()
        XFG.Handlers.SoulbindEvent = SoulbindEvent:new(); XFG.Handlers.SoulbindEvent:Initialize()
        XFG.Handlers.ProfessionEvent = ProfessionEvent:new(); XFG.Handlers.ProfessionEvent:Initialize()
        XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
        XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()

        if(XFG.Network.Outbox:HasLocalChannel() == false) then
            JoinTemporaryChannel(XFG.Network.Channel.Name)
        end

        -- Broadcast login, refresh DTs and ready to roll        
        --wipe(XFG.Cache)
        wipe(XFG.DB.Backup)

        XFG.Initialized = true
        if(XFG.DB.UIReload == false) then
            XFG.Network.BNet.Comm:PingFriends()                 
        end
        XFG:ScheduleTimer(XFG.Handlers.TimerEvent.CallbackDelayedStartTimer, 5)
        
        XFG.DataText.Guild:RefreshBroker()
        XFG.DataText.Soulbind:RefreshBroker()
        XFG.DataText.Links:RefreshBroker()
    end
end