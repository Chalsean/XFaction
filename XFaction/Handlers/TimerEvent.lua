local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local ServerTime = GetServerTime
local GuildRosterEvent = C_GuildInfo.GuildRoster
local InGuild = IsInGuild
local LoginTime = ServerTime()

TimerEvent = Object:newChildConstructor()

--#region Constructors
function TimerEvent:new()
    local object = TimerEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function TimerEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		XFG.Timers:Add('Login', 1, XFG.Handlers.TimerEvent.CallbackLogin, true, true, true)
		XFG.Timers:Add('Heartbeat', XFG.Settings.Player.Heartbeat, XFG.Handlers.TimerEvent.CallbackHeartbeat, true, true, false)
        XFG.Timers:Add('Links', XFG.Settings.Network.BNet.Link.Broadcast, XFG.Handlers.TimerEvent.CallbackLinks, true, true, false)		    		    
        XFG.Timers:Add('Roster', XFG.Settings.LocalGuild.ScanTimer, XFG.Handlers.TimerEvent.CallbackGuildRoster, true, true, false)		    				
        XFG.Timers:Add('Mailbox', XFG.Settings.Network.Mailbox.Scan, XFG.Handlers.TimerEvent.CallbackMailboxTimer, true, false, false)
        XFG.Timers:Add('Ping', XFG.Settings.Network.BNet.Ping.Timer, XFG.Handlers.TimerEvent.CallbackPingFriends, true, true, false)
        XFG.Timers:Add('StaleLinks', XFG.Settings.Network.BNet.Link.Scan, XFG.Handlers.TimerEvent.CallbackStaleLinks, true, true, false)
        XFG.Timers:Add('Offline', XFG.Settings.Confederate.UnitScan, XFG.Handlers.TimerEvent.CallbackOffline, true, true, false)
        XFG.Timers:Add('DelayedLogin', 7, XFG.Handlers.TimerEvent.CallbackDelayedStartTimer)
        XFG.Timers:Get('Login'):Start()

        self:IsInitialized(true)
	end
	return self:IsInitialized()
end
--#endregion

--#region Callbacks
--#region Login Callbacks
function TimerEvent:CallbackLogin()
    -- If havent gotten guild info after X seconds, give up. probably not in a guild
    if(LoginTime + XFG.Settings.LocalGuild.LoginGiveUp < ServerTime()) then
        XFG:Error(ObjectName, 'Did not detect a guild')
        XFG.Timers:Stop()
        return
    end

	-- For a time Blizz API says player is not in guild, even if they are
	-- Its not clear what event fires (if any) when this data is available, hence the poller
    if(InGuild()) then
        -- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
        local guildID = C_Club.GetGuildClubId()
        if(guildID ~= nil) then
			-- Critical path initialization, anything not caught needs to get bailed
			try(function ()
				-- Now that guild info is available we can finish setup
				XFG:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XFG.Timers:Remove('Login')

				-- Confederate setup via guild info
				XFG.Confederate:Initialize()
				XFG.Guilds = GuildCollection:new(); XFG.Guilds:Initialize(guildID)
				XFG.Realms:SetPlayerRealm()
				XFG.Guilds:SetPlayerGuild()
				XFG.Teams = TeamCollection:new(); XFG.Teams:Initialize()						
				XFG.Targets = TargetCollection:new(); XFG.Targets:Initialize()

				-- Chat channel setup via guild info, player will start to receive messaging via chat channel
				XFG.Channels = ChannelCollection:new(); XFG.Channels:Initialize()
				XFG.Handlers.ChannelEvent = ChannelEvent:new(); XFG.Handlers.ChannelEvent:Initialize()
				XFG.Mailbox.Chat = Chat:new(); XFG.Mailbox.Chat:Initialize()
				XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
				
				-- BNet setup, player will start to receive messaging via bnet
				-- We want this to be after chat channel setup so we can forward messages
				XFG.Nodes = NodeCollection:new(); XFG.Nodes:Initialize()
				XFG.Links = LinkCollection:new(); XFG.Links:Initialize()
				XFG.Friends = FriendCollection:new(); XFG.Friends:Initialize()
				XFG.Handlers.BNetEvent = BNetEvent:new(); XFG.Handlers.BNetEvent:Initialize()
				XFG.Mailbox.BNet = BNet:new(); XFG.Mailbox.BNet:Initialize()
				
				-- Some of this data (spec) is like guild where its not available for a time after initial login
				-- Seems to align with guild data becoming available
				XFG.Races = RaceCollection:new(); XFG.Races:Initialize()
				XFG.Classes = ClassCollection:new(); XFG.Classes:Initialize()
				XFG.Specs = SpecCollection:new(); XFG.Specs:Initialize()		    
				XFG.Professions = ProfessionCollection:new(); XFG.Professions:Initialize()

				-- Scan local guild, player unit information is now available
				XFG.Handlers.GuildEvent = GuildEvent:new(); XFG.Handlers.GuildEvent:Initialize()
				XFG.Handlers.SystemEvent = SystemEvent:new(); XFG.Handlers.SystemEvent:Initialize()
				XFG.Handlers.PlayerEvent = PlayerEvent:new(); XFG.Handlers.PlayerEvent:Initialize()

				-- Player will start sending guild chat and achievement messages
				-- We want this after player unit information is available because its included in the messages				
				XFG.Handlers.ChatEvent = ChatEvent:new(); XFG.Handlers.ChatEvent:Initialize()
				XFG.Handlers.AchievementEvent = AchievementEvent:new(); XFG.Handlers.AchievementEvent:Initialize()				
				
				-- Start all timers
				XFG.Timers:Start()
				XFG.Initialized = true
			end).
			catch(function (inErrorMessage)
				XFG:Error(ObjectName, inErrorMessage)
				--print(XFG.Title .. ': Failed to start properly. ' .. inErrorMessage)
				XFG.Timers:Stop()
				return
			end)
        end
    end
end

function TimerEvent:CallbackDelayedStartTimer()
	try(function ()
		if(not XFG.Cache.UIReload) then
			XFG.Player.Unit:Broadcast(XFG.Settings.Network.Message.Subject.LOGIN)
			XFG.Links:Broadcast()
		end
		-- For support reasons, it helps to know what addons are being used
		for i = 1, GetNumAddOns() do
			local name, _, _, enabled = GetAddOnInfo(i)
			XFG:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFG.Cache.UIReload = false
	end)
end
--#endregion

--#region Janitorial Callbacks
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
	    for _, friend in XFG.Friends:Iterator() do
			if(not friend:IsRunningAddon()) then
				friend:Ping()
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
--#endregion
--#endregion