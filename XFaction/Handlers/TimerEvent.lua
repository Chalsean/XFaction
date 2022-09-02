local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'

local ServerTime = GetServerTime
local GuildRosterEvent = C_GuildInfo.GuildRoster
local InGuild = IsInGuild

TimerEvent = Object:newChildConstructor()

function TimerEvent:new()
    local _Object = TimerEvent.parent.new(self)
    _Object.__name = ObjectName
    return _Object
end

function TimerEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
        XFG.Cache.LoginTimerStart = ServerTime()
        XFG.Timers:Add('Login', 1, XFG.Handlers.TimerEvent.CallbackLogin, false, true, true)
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TimerEvent:CallbackLogin()
    -- If havent gotten guild info after Xs, give up. probably not in a guild
    if(XFG.Cache.LoginTimerStart + XFG.Settings.LocalGuild.LoginGiveUp < ServerTime()) then
        XFG:Error(ObjectName, 'Did not detect a guild')
        XFG.Timers:Stop()
        return
    end

    -- Get AceDB up and running as early as possible, its not available until addon is loaded
    if(IsAddOnLoaded(XFG.AddonName) and XFG.Config == nil) then        
        XFG.DataDB = LibStub('AceDB-3.0'):New('XFactionDB', XFG.Defaults, true)
        XFG.DB = XFG.DataDB.char
        XFG.Config = XFG.DataDB.profile
		XFG.DebugFlag = XFG.Config.Debug.Enable
        if(XFG.DB.Backup == nil) then XFG.DB.Backup = {} end
        if(XFG.DB.UIReload == nil) then XFG.DB.UIReload = false end
		if(XFG.DB.Errors == nil) then XFG.DB.Errors = {} end
		if(XFG.Config.Channels == nil) then XFG.Config.Channels = {} end
        XFG:LoadConfigs() 

		-- Cache it because on shutdown, XFG.Config gets unloaded while we're still logging
		XFG.Cache.Verbosity = XFG.Config.Debug.Verbosity
		
		-- Monitor other addons loading
		XFG.Handlers.AddonEvent = AddonEvent:new(); XFG.Handlers.AddonEvent:Initialize()

		XFG.DataText.Guild:SetFont()
    end

    -- Ensure we get the player guid and faction without failure
    if(XFG.Player.GUID == nil) then
        XFG.Player.GUID = UnitGUID('player')
    end
    if(XFG.Player.Faction == nil) then
        XFG.Player.Faction = XFG.Factions:GetByName(UnitFactionGroup('player'))
    end

    if(InGuild()) then
        -- Even though it says were in guild, the following call still may not work on initial login, hence the poller
        local _GuildID = C_Club.GetGuildClubId()
        -- Sanity check
        if(XFG.Player.GUID ~= nil and XFG.Player.Faction ~= nil and _GuildID ~= nil) then
            -- Now that guild info is available we can finish setup
            XFG:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
			XFG.Timers:Remove('Login')
			Confederate:Initialize()

			-- Log any reloadui errors encountered
			for _, _ErrorText in ipairs(XFG.DB.Errors) do
				XFG:Warn(ObjectName, _ErrorText)
			end
			XFG.DB.Errors = {}
			
			-- Critical path initialization, anything not caught needs to get bailed
			try(function ()

				XFG:Info(ObjectName, 'WoW client version [%s:%s]', XFG.WoW:GetName(), XFG.WoW:GetVersion():GetKey())
				XFG:Info(ObjectName, 'XFaction version [%s]', XFG.Version:GetKey())

				local _GuildInfo = C_Club.GetClubInfo(_GuildID)
				
				-- Parse out configuration from guild information so GMs have control
				local _XFData
				local _DataIn = string.match(_GuildInfo.description, 'XF:(.-):XF')
				if (_DataIn ~= nil) then
					-- Decompress and deserialize XFaction data
					local _Decompressed = XFG.Lib.Deflate:DecompressDeflate(XFG.Lib.Deflate:DecodeForPrint(_DataIn))
					local _, _Deserialized = XFG:Deserialize(_Decompressed)
					XFG:Debug(ObjectName, 'Data from config %s', _Deserialized)
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
					XFG:Debug(ObjectName, 'Data from config %s', _Deserialized)
					_XFData = _Deserialized
				else
					_XFData = _GuildInfo.description
				end

				for _, _Line in ipairs(string.Split(_XFData, '\n')) do
					-- Confederate information
					if(string.find(_Line, 'XFn')) then                    
						local _Name, _Initials = _Line:match('XFn:(.-):(.+)')
						XFG:Info(ObjectName, 'Initializing confederate %s <%s>', _Name, _Initials)
						Confederate:SetName(_Name)
						Confederate:SetKey(_Initials)
						XFG.Settings.Network.Message.Tag.LOCAL = _Initials .. 'XF'
						XFG.Settings.Network.Message.Tag.BNET = _Initials .. 'BNET'
					-- Guild within the confederate
					elseif(string.find(_Line, 'XFg')) then
						local _RealmNumber, _FactionID, _GuildName, _GuildInitials = _Line:match('XFg:(.-):(.-):(.-):(.+)')
						local _Realm = XFG.Realms:GetByID(tonumber(_RealmNumber))
						local _Faction = XFG.Factions:GetByID(_FactionID)

						XFG:Info(ObjectName, 'Initializing guild %s <%s>', _GuildName, _GuildInitials)
						local _NewGuild = Guild:new()
						_NewGuild:Initialize()
						_NewGuild:SetKey(_GuildInitials)
						_NewGuild:SetName(_GuildName)
						_NewGuild:SetFaction(_Faction)
						_NewGuild:SetRealm(_Realm)
						_NewGuild:SetInitials(_GuildInitials)						
						XFG.Guilds:Add(_NewGuild)
					-- Local channel for same realm/faction communication
					elseif(string.find(_Line, 'XFc')) then
						XFG.Settings.Network.Channel.Name, XFG.Settings.Network.Channel.Password = _Line:match('XFc:(.-):(.*)')
					-- If you keep your alts at a certain rank, this will flag them as alts in comms/DTs
					elseif(string.find(_Line, 'XFa')) then
						local _AltRank = _Line:match('XFa:(.+)')
						XFG:Info(ObjectName, 'Initializing alt rank [%s]', _AltRank)
						XFG.Settings.Confederate.AltRank = _AltRank
					elseif(string.find(_Line, 'XFt')) then
						local _TeamInitial, _TeamName = _Line:match('XFt:(%a):(%a+)')
						XFG:Info(ObjectName, 'Initializing team [%s][%s]', _TeamInitial, _TeamName)
						local _NewTeam = Team:new()
						_NewTeam:Initialize()
						_NewTeam:SetName(_TeamName)
						_NewTeam:SetInitials(_TeamInitial)
						_NewTeam:SetKey(_TeamInitial)
						XFG.Teams:Add(_NewTeam)
					end
				end

				-- Setup default realms (Torghast)
				for _RealmID, _RealmName in pairs (XFG.Settings.Confederate.DefaultRealms) do
					local _NewRealm = Realm:new()
					_NewRealm:SetKey(_RealmName)
					_NewRealm:SetName(_RealmName)
					_NewRealm:SetAPIName(_RealmName)
					_NewRealm:SetIDs({_RealmID})
					XFG.Realms:Add(_NewRealm)
				end

				-- Backwards compat for EK
				if(XFG.Teams:GetCount() == 0) then
					XFG.Teams:EKInitialize()
				end

				for _TeamInitial, _TeamName in pairs (XFG.Settings.Confederate.DefaultTeams) do
					if(not XFG.Teams:Contains(_TeamInitial)) then
						XFG:Info(ObjectName, 'Initializing default team [%s][%s]', _TeamInitial, _TeamName)
						local _NewTeam = Team:new()
						_NewTeam:Initialize()
						_NewTeam:SetInitials(_TeamInitial)
						_NewTeam:SetName(_TeamName)
						_NewTeam:SetKey(_TeamInitial)
						XFG.Teams:Add(_NewTeam)
					end
				end

				-- Ensure player is on supported realm
				local _RealmName = GetRealmName()
				local _LocalRealm = XFG.Realms:Get(_RealmName)
				for _, _RealmID in _LocalRealm:IDIterator() do
					local _ConnectedRealm = XFG.Realms:GetByID(_RealmID)
					for _, _Guild in XFG.Guilds:Iterator() do
						if(_Guild:GetRealm():Equals(_ConnectedRealm) and _Guild:GetFaction():Equals(XFG.Player.Faction)) then
							if(not _LocalRealm:Equals(_ConnectedRealm)) then
								XFG:Info(ObjectName, 'Switching from local realm [%s] to connected realm [%s]', _LocalRealm:GetName(), _ConnectedRealm:GetName())
							end
							XFG.Player.Realm = _ConnectedRealm
							break
						end
					end
				end
				if(XFG.Player.Realm == nil) then
					error('Player is not on a supported realm: ' .. tostring(_RealmName))
				end
				-- Ensure player is on supported guild
				XFG.Player.Guild = XFG.Guilds:GetByRealmGuildName(XFG.Player.Realm, _GuildInfo.name)
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
				XFG.Covenants = CovenantCollection:new(); XFG.Covenants:Initialize()
				XFG.Soulbinds = SoulbindCollection:new(); XFG.Soulbinds:Initialize()

				-- If this is a reload, restore non-local guild members
				try(function ()
					if(XFG.DB.UIReload) then
						XFG.Confederate:Restore()
					end
				end).
				catch(function (inErrorMessage)
					XFG:Warn(ObjectName, 'Failed to restore units from backup: ' .. inErrorMessage)
				end)

				-- Scan local guild roster
				XFG:Info(ObjectName, 'Initializing local guild roster')
				for _, _MemberID in pairs (C_Club.GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
					local _UnitData = nil
					try(function ()		
						_UnitData = XFG.Confederate:Pop()
						_UnitData:Initialize(_MemberID)
						if(_UnitData:IsInitialized()) then
							XFG.Cache.FirstScan[_MemberID] = true
							if(_UnitData:IsOnline()) then
								XFG:Debug(ObjectName, 'Adding local guild unit [%s:%s]', _UnitData:GetGUID(), _UnitData:GetName())
								XFG.Confederate:Add(_UnitData)
							else
								XFG.Confederate:Push(_UnitData)
							end
						else
							XFG.Confederate:Push(_UnitData)
						end						
					end).
					catch(function (inErrorMessage)
						XFG:Debug(ObjectName, inErrorMessage)
					end).
					finally(function ()
						if(_UnitData and _UnitData:IsPlayer()) then
							_UnitData:Print()          
						end
					end)
				end

				-- Start network setup
				XFG.Mailbox.Chat = Chat:new(); XFG.Mailbox.Chat:Initialize()
				XFG.Mailbox.BNet = BNet:new(); XFG.Mailbox.BNet:Initialize()
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
				XFG:Info(ObjectName, 'Joined confederate channel [%s]', XFG.Settings.Network.Channel.Name)
				local _ChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(XFG.Settings.Network.Channel.Name)
				local _NewChannel = Channel:new()
				_NewChannel:SetKey(_ChannelInfo.shortcut)
				_NewChannel:SetID(_ChannelInfo.localID)
				_NewChannel:SetName(_ChannelInfo.shortcut)
				if(XFG.Settings.Network.Channel.Password ~= nil) then
					_NewChannel:SetPassword(XFG.Settings.Network.Channel.Password)
				end
				XFG.Channels:Add(_NewChannel)
				XFG.Channels:SetLocalChannel(_NewChannel)
				XFG.Channels:SetLast(_NewChannel:GetKey())

				-- Start critical timers
				XFG.Timers:Add('Heartbeat', XFG.Settings.Player.Heartbeat, XFG.Handlers.TimerEvent.CallbackHeartbeat, true, true, false)
				XFG.Timers:Add('Links', XFG.Settings.Network.BNet.Link.Broadcast, XFG.Handlers.TimerEvent.CallbackLinks, true, true, false)		    		    
				XFG.Timers:Add('Roster', XFG.Settings.LocalGuild.ScanTimer, XFG.Handlers.TimerEvent.CallbackGuildRoster, true, true, false)		    

				-- Register event handlers
				XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()            
				XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
				XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()
				XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
				XFG.Handlers.PlayerEvent = PlayerEvent:new(); XFG.Handlers.PlayerEvent:Initialize()

				-- On initial login, the roster returned is incomplete, you have to force Blizz to do a guild roster refresh
				try(function ()
					if(not XFG.DB.UIReload) then
						GuildRosterEvent()
					end
				end).
				catch(function (inErrorMessage)
					XFG:Warn(ObjectName, 'GuildRoster API call failed: ' .. inErrorMessage)
				end)
			end).
			catch(function (inErrorMessage)
				XFG:Error(ObjectName, inErrorMessage)
				--print(XFG.Title .. ': Failed to start properly. ' .. inErrorMessage)
				XFG.Timers:Stop()
				return
			end)
	
			try(function ()
				-- If this is a reload, restore friends addon flag
				if(XFG.DB.UIReload) then
					XFG.Friends:Restore()
					XFG.Links:Restore()
				end
						
				local _InInstance, _InstanceType = IsInInstance()
				XFG.Player.InInstance = _InInstance
						
				-- Non-critcal path initialization
				XFG.Timers:Add('Mailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackMailboxTimer, true, false, false)
				XFG.Timers:Add('Ping', XFG.Settings.Network.BNet.Ping.Timer, XFG.Handlers.TimerEvent.CallbackPingFriends, true, true, false)
				XFG.Timers:Add('StaleLinks', XFG.Settings.Network.BNet.Link.Scan, XFG.Handlers.TimerEvent.CallbackStaleLinks, true, true, false)
				XFG.Timers:Add('Offline', XFG.Settings.Confederate.UnitScan, XFG.Handlers.TimerEvent.CallbackOffline, true, true, false)

				-- Ping friends to find out whos available for BNet
				if(not XFG.DB.UIReload) then                
					XFG.Handlers.TimerEvent:CallbackPingFriends()      
				end

				-- This is stuff waiting a few seconds for ping responses or Blizz setup to finish
				XFG.Timers:Add('DelayedStart', 7, XFG.Handlers.TimerEvent.CallbackDelayedStartTimer)
			end).
			catch(function (inErrorMessage)
				XFG:Warn(ObjectName, 'Failed non-critical path initialization of XFaction: ' .. inErrorMessage)
			end).
			finally(function ()
				XFG.Initialized = true
				
				-- Refresh brokers (theyve been waiting on XFG.Initialized flag)
				XFG.DataText.Guild:SetFont()
				XFG.DataText.Guild:RefreshBroker()
				XFG.DataText.Links:SetFont()
				XFG.DataText.Links:RefreshBroker()
				XFG.DataText.Metrics:SetFont()
				XFG.DataText.Metrics:RefreshBroker()
				XFG.DataText.Soulbind:RefreshBroker()				
				
				--XFG:InitializeSetup()
				wipe(XFG.DB.Backup)
			end)
        end
    end
end

function TimerEvent:CallbackDelayedStartTimer()
	try(function ()
		if(not XFG.DB.UIReload) then
			XFG.Player.Unit:Broadcast(XFG.Settings.Network.Message.Subject.LOGIN)
			XFG.Links:Broadcast()
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.DB.UIReload = false
	end)

	try(function ()
		-- For support reasons, it helps to know what addons are being used
		for i = 1, GetNumAddOns() do
			local _Name, _, _, _Enabled = GetAddOnInfo(i)
			XFG:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', _Name, tostring(_Enabled))
		end
	end).
	catch(function (inErrorMessage)
		XFG:Debug(ObjectName, inErrorMessage)
	end)
end

-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
	try(function ()
		XFG.Mailbox.Chat:Purge(ServerTime() - XFG.Settings.Network.Mailbox.Stale)
		XFG.Mailbox.BNet:Purge(ServerTime() - XFG.Settings.Network.Mailbox.Stale)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('Mailbox'):SetLastRan(ServerTime())
	end)
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
	try(function ()
		XFG.Confederate:OfflineUnits(ServerTime() - XFG.Settings.Confederate.UnitStale)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('Offline'):SetLastRan(ServerTime())
	end)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
	try(function ()
		if(XFG.Initialized and XFG.Player.LastBroadcast < ServerTime() - XFG.Settings.Player.Heartbeat) then
			XFG:Debug(ObjectName, 'Sending heartbeat')
			XFG.Player.Unit:Broadcast()
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('Heartbeat'):SetLastRan(ServerTime())
	end)
end

-- Periodically force a refresh
function TimerEvent:CallbackGuildRoster()
	try(function ()
		if(XFG.Initialized and XFG.Player.Guild) then
			GuildRosterEvent()
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('Roster'):SetLastRan(ServerTime())
	end)
end

-- Periodically ping friends to see who is running addon
function TimerEvent:CallbackPingFriends()
    try(function()
	    for _, _Friend in XFG.Friends:Iterator() do
			if(not _Friend:IsRunningAddon()) then
				_Friend:Ping()
			end
	    end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('Ping'):SetLastRan(ServerTime())
	end)
end

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
	try(function ()
    	XFG.Links:Broadcast()
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('Links'):SetLastRan(ServerTime())
	end)
end

-- Periodically purge stale links
function TimerEvent:CallbackStaleLinks()
	try(function ()
		XFG.Links:Purge(ServerTime() - XFG.Settings.Network.BNet.Link.Stale)
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Timers:Get('StaleLinks'):SetLastRan(ServerTime())
	end)
end