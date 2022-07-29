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
        XFG.DataDB = LibStub('AceDB-3.0'):New('XFactionDB', XFG.Defaults, true)
        XFG.DB = XFG.DataDB.char
        XFG.Config = XFG.DataDB.profile
        if(XFG.DB.Backup == nil) then XFG.DB.Backup = {} end
        if(XFG.DB.UIReload == nil) then XFG.DB.UIReload = false end
		if(XFG.DB.Errors == nil) then XFG.DB.Errors = {} end
		if(XFG.Config.Channels == nil) then XFG.Config.Channels = {} end
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

			for _, _ErrorText in ipairs(XFG.DB.Errors) do
				XFG:Warn(LogCategory, _ErrorText)
			end
			XFG.DB.Errors = {}
			
			-- Critical path initialization, anything not caught needs to get bailed
			try(function ()

				XFG:Info(LogCategory, 'WoW client version [%s:%s]', XFG.WoW:GetName(), XFG.WoW:GetVersion():GetKey())
				XFG:Info(LogCategory, 'XFaction version [%s]', XFG.Version:GetKey())

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
						XFG:Info(LogCategory, 'Initializing confederate %s <%s>', _Name, _Initials)
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
						XFG:Info(LogCategory, 'Initializing realm [%s]', _RealmName)
						local _NewRealm = Realm:new()
						_NewRealm:SetKey(_RealmName)
						_NewRealm:SetName(_RealmName)
						_NewRealm:SetAPIName(string.gsub(_RealmName, '%s+', ''))
						_NewRealm:Initialize()
						XFG.Realms:AddRealm(_NewRealm)
						end
						local _Realm = XFG.Realms:GetRealm(_RealmName)                    
						local _Faction = XFG.Factions:GetFactionByName(_FactionInitial == 'A' and 'Alliance' or 'Horde')

						XFG:Info(LogCategory, 'Initializing guild %s <%s>', _GuildName, _GuildInitials)
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
						XFG:Info(LogCategory, 'Initializing alt rank [%s]', _AltRank)
						XFG.Settings.Confederate.AltRank = _AltRank
					elseif(string.find(_Line, 'XFt')) then
						local _TeamInitial, _TeamName = _Line:match('XFt:(%a):(%a+)')
						XFG:Info(LogCategory, 'Initializing team [%s][%s]', _TeamInitial, _TeamName)
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

				for _TeamInitial, _TeamName in pairs (XFG.Settings.Confederate.DefaultTeams) do
					if(not XFG.Teams:Contains(_TeamInitial)) then
						XFG:Info(LogCategory, 'Initializing default team [%s][%s]', _TeamInitial, _TeamName)
						local _NewTeam = Team:new()
						_NewTeam:SetInitials(_TeamInitial)
						_NewTeam:SetName(_TeamName)
						_NewTeam:Initialize()
						XFG.Teams:AddTeam(_NewTeam)
					end
				end

				-- Ensure player is on supported realm
				local _RealmName = GetRealmName()
				XFG.Player.Realm = XFG.Realms:GetRealm(_RealmName)
				if(XFG.Player.Realm == nil) then
					error('Player is not on a supported realm [%s]', _RealmName)
				end
				-- Ensure player is on supported guild
				XFG.Player.Guild = XFG.Guilds:GetGuildByRealmGuildName(XFG.Player.Realm, _GuildInfo.name)
				if(XFG.Player.Guild == nil) then
					error('Player is not in supported guild ' .. tostring(_GuildName))
				end
				XFG.Player.Guild:SetID(_GuildID)
				for _, _Stream in pairs (C_Club.GetStreams(_GuildID)) do
					if(_Stream.streamType == 1) then
						XFG.Player.Guild:SetStreamID(_Stream.streamId)
						break
					end
				end
						
				XFG.Targets = TargetCollection:new(); XFG.Targets:Initialize()

				-- Some of this data (spec) is like guild where its not available for a time after initial login
				-- Seems to align with guild data becoming available
				XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
				XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
				XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()		    
				XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()
				XFG.Continents = ContinentCollection:new(); XFG.Continents:Initialize()
				XFG.Zones = ZoneCollection:new(); XFG.Zones:Initialize()
						
				if(XFG.WoW:IsRetail()) then
					XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
					XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()
				end
				XFG.Media = MediaCollection:new(); XFG.Media:Initialize()

				-- Start the unit factory
				XFG.Factories.Unit = UnitFactory:new(); XFG.Factories.Unit:Initialize()
				XFG:Info(LogCategory, 'Initialized Unit factory')

				-- If this is a reload, restore non-local guild members
				try(function ()
					if(XFG.DB.UIReload) then
						XFG.Confederate:RestoreBackup()
					end
				end).
				catch(function (inErrorMessage)
					XFG:Warn(LogCategory, 'Failed to restore units from backup: ' .. inErrorMessage)
				end)				

				-- Scan local guild roster
				XFG:Info(LogCategory, 'Initializing local guild roster')
				for _, _MemberID in pairs (C_Club.GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
					local _UnitData = XFG.Factories.Unit:CheckOut()
					try(function ()			
						_UnitData:Initialize(_MemberID)
						if(_UnitData:IsOnline() and not XFG.Confederate:Contains(_UnitData:GetKey())) then
							XFG:Debug(LogCategory, 'Adding local guild unit [%s:%s]', _UnitData:GetGUID(), _UnitData:GetName())
							XFG.Confederate:AddUnit(_UnitData)
						else
							XFG.Factories.Unit:CheckIn(_UnitData)
						end
					end).
					catch(function (inErrorMessage)
						XFG:Warn(LogCategory, 'Failed to query for guild member [%d] on initialization: ' .. inErrorMessage, _MemberID)
					end).
					finally(function ()
						if(_UnitData and _UnitData:IsPlayer()) then
							_UnitData:Print()          
						end			
					end)
				end

				-- Start messaging factories
				XFG.Factories.GuildMessage = GuildMessageFactory:new(); XFG.Factories.GuildMessage:Initialize()
				XFG:Info(LogCategory, 'Initialized GuildMessage factory')
				XFG.Factories.Message = MessageFactory:new(); XFG.Factories.Message:Initialize()
				XFG:Info(LogCategory, 'Initialized Message factory')

				-- Start network setup
				XFG.Mailbox = Mailbox:new(); XFG.Mailbox:Initialize()
				XFG.Outbox = Outbox:new()
				XFG.Inbox = Inbox:new(); XFG.Inbox:Initialize()            
				XFG.BNet = BNet:new(); BNet:Initialize()
				XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()
				XFG.Friends = FriendCollection:new(); XFG.Friends:Initialize()
				XFG.Nodes = NodeCollection:new(); XFG.Nodes:Initialize()
				XFG.Links = LinkCollection:new(); XFG.Links:Initialize()      

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
				_NewChannel:SetName(_ChannelInfo.shortcut)
				XFG.Channels:AddChannel(_NewChannel)            
				XFG.Outbox:SetLocalChannel(_NewChannel)

				-- Start critical timers
				CreateTimer('Heartbeat', XFG.Settings.Player.Heartbeat, XFG.Handlers.TimerEvent.CallbackHeartbeat, true, false)
				CreateTimer('Links', XFG.Settings.Network.BNet.Link.Broadcast, XFG.Handlers.TimerEvent.CallbackLinks, true, false)		    		    
				CreateTimer('Roster', XFG.Settings.LocalGuild.ScanTimer, XFG.Handlers.TimerEvent.CallbackGuildRoster, true, false)		    

				-- Register event handlers
				XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()            
				XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
				XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()
				XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
				XFG.Handlers.PlayerEvent = PlayerEvent:new(); XFG.Handlers.PlayerEvent:Initialize()
			end).
			catch(function (inErrorMessage)
				XFG:Error(LogCategory, 'Failed critical path initialization of XFaction: ' .. inErrorMessage)
				XFG:CancelAllTimers()
				error(inErrorMessage)
			end)
	
			try(function ()
				-- If this is a reload, restore friends addon flag
				if(XFG.DB.UIReload) then
					XFG.Friends:RestoreBackup()
					XFG.Links:RestoreBackup()
				end
						
				local _InInstance, _InstanceType = IsInInstance()
				XFG.Player.InInstance = _InInstance
						
				-- Non-critcal path initialization
				CreateTimer('Mailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackMailboxTimer, false, false)
				CreateTimer('BNetMailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackBNetMailboxTimer, false, false)
				CreateTimer('Ping', XFG.Settings.Network.BNet.Ping.Timer, XFG.Handlers.TimerEvent.CallbackPingFriends, true, false)
				CreateTimer('StaleLinks', XFG.Settings.Network.BNet.Link.Scan, XFG.Handlers.TimerEvent.CallbackStaleLinks, true, false)
				CreateTimer('Offline', XFG.Settings.Confederate.UnitScan, XFG.Handlers.TimerEvent.CallbackOffline, true, false)
				CreateTimer('Factories', XFG.Settings.Factories.Scan, XFG.Handlers.TimerEvent.CallbackFactories, true, false)

				-- Ping friends to find out whos available for BNet
				if(not XFG.DB.UIReload) then                
					XFG.Handlers.TimerEvent:CallbackPingFriends()      
				end

				-- This is stuff waiting a few seconds for ping responses or Blizz setup to finish
				XFG:ScheduleTimer(XFG.Handlers.TimerEvent.CallbackDelayedStartTimer, 7)		    
			end).
			catch(function (inErrorMessage)
				XFG:Warn(LogCategory, 'Failed non-critical path initialization of XFaction: ' .. inErrorMessage)
			end).
			finally(function ()
				XFG.Initialized = true

				-- Refresh brokers (theyve been waiting on XFG.Initialized flag)
				XFG.DataText.Guild:RefreshBroker()
				XFG.DataText.Soulbind:RefreshBroker()
				XFG.DataText.Links:RefreshBroker()
				XFG.DataText.Metrics:RefreshBroker()
				wipe(XFG.DB.Backup)
			end)
        end
    end
end

function TimerEvent:CallbackDelayedStartTimer()
	try(function ()
		XFG.Frames.Chat:LoadElvUI()
		if(not XFG.DB.UIReload) then
			XFG.Channels:SetChannelLast(XFG.Outbox:GetLocalChannel():GetKey())
			XFG.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Settings.Network.Message.Subject.LOGIN)
			XFG.Links:BroadcastLinks()
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed delayed start initialization: ' .. inErrorMessage)
	end).
	finally(function ()
		XFG.DB.UIReload = false
	end)

	try(function ()
		-- For support reasons, it helps to know what addons are being used
		for i = 1, GetNumAddOns() do
			local _Name, _, _, _Enabled = GetAddOnInfo(i)
			XFG:Debug(LogCategory, 'Addon is loaded [%s] enabled [%s]', _Name, tostring(_Enabled))
		end
	end).
	catch(function (inErrorMessage)
		XFG:Debug(LogCategory, 'Failed to query for addon: ' .. inErrorMessage)
	end)
end

-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
	try(function ()
		local _EpochTime = GetServerTime() - XFG.Settings.Network.Mailbox.Stale
		XFG.Mailbox:Purge(_EpochTime)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to clean regular mailbox: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('Mailbox')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Cleanup BNet mailbox
function TimerEvent:CallbackBNetMailboxTimer()
	try(function ()
		local _EpochTime = GetServerTime() - XFG.Settings.Network.Mailbox.Stale
		XFG.BNet:Purge(_EpochTime)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to clean BNet mailbox: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('BNetMailbox')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
	try(function ()
		local _EpochTime = GetServerTime() - XFG.Settings.Confederate.UnitStale
		XFG.Confederate:OfflineUnits(_EpochTime)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to identify stale units: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('Offline')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
	try(function ()
		if(XFG.Initialized and XFG.Player.LastBroadcast < GetServerTime() - XFG.Settings.Player.Heartbeat) then
			XFG:Debug(LogCategory, "Sending heartbeat")
			XFG.Outbox:BroadcastUnitData(XFG.Player.Unit, XFG.Settings.Network.Message.Subject.DATA)
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to send heartbeat message: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('Heartbeat')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Periodically force a refresh
function TimerEvent:CallbackGuildRoster()
	try(function ()
		if(XFG.Initialized and IsInGuild()) then
			C_GuildInfo.GuildRoster()
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to call C_GuildInfo API: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('Roster')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Periodically ping friends to see who is running addon
function TimerEvent:CallbackPingFriends()
    try(function()
	    for _, _Friend in XFG.Friends:Iterator() do
			if(not _Friend:IsRunningAddon()) then
				XFG.BNet:PingFriend(_Friend)
			end
	    end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to ping friends: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('Ping')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
	try(function ()
    		XFG.Links:BroadcastLinks()
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to broadcast links: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('Links')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Periodically purge stale links
function TimerEvent:CallbackStaleLinks()
	try(function ()
		local _EpochTime = GetServerTime() - XFG.Settings.Network.BNet.Link.Stale
		XFG.Links:PurgeStaleLinks(_EpochTime)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(LogCategory, 'Failed to purge stale links: ' .. inErrorMessage)
	end).
	finally(function ()
		local _Timer = XFG.Timers:GetTimer('StaleLinks')
		_Timer:SetLastRan(GetServerTime())
	end)
end

-- Purge stale objects
function TimerEvent:CallbackFactories()
	local _PurgeTime = GetServerTime() - XFG.Settings.Factories.Purge
	XFG.Factories.GuildMessage:Purge(_PurgeTime)
	XFG.Factories.Message:Purge(_PurgeTime)
	XFG.Factories.Unit:Purge(_PurgeTime)
end