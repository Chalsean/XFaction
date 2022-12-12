local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local ServerTime = GetServerTime
local GuildRosterEvent = C_GuildInfo.GuildRoster
local InGuild = IsInGuild
local GetGuildClubId = C_Club.GetGuildClubId
local LoginTime = ServerTime()

TimerEvent = Object:newChildConstructor()

--#region Constructors
function TimerEvent:new()
    local object = TimerEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Callbacks
--#region Login Callbacks
function TimerEvent:CallbackLogin()
	try(function ()
		-- For a time Blizz API says player is not in guild, even if they are
		-- Its not clear what event fires (if any) when this data is available, hence the poller
		if(InGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = GetGuildClubId()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XFG:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XFG.Timers:Remove('Login')

				-- Confederate setup via guild info
				XFG.Guilds:Initialize(guildID)
				XFG.Confederate:Initialize()
				XFG.Guilds:SetPlayerGuild()
				XFG.Teams:Default()	
				XFG.Targets:Initialize()	

				-- Chat channel setup via guild info, player will start to receive messaging via chat channel
				XFG.Channels:Initialize()
				XFG.Handlers.ChannelEvent:Initialize()
				XFG.Mailbox.Chat:Initialize()
				
				-- BNet setup, player will start to receive messaging via bnet
				-- We want this to be after chat channel setup so we can forward messages
				XFG.Nodes:Initialize()
				XFG.Links:Initialize()
				XFG.Friends:Initialize()
				XFG.Handlers.BNetEvent:Initialize()
				XFG.Mailbox.BNet:Initialize()
				
				-- Some of this data (spec) is like guild where its not available for a time after initial login
				-- Seems to align with guild data becoming available
				XFG.Races:Initialize()
				XFG.Classes:Initialize()
				XFG.Specs:Initialize()		    
				XFG.Professions:Initialize()

				-- Restore guild members from backup
				if(XFG.Cache.UIReload) then	XFG.Confederate:Restore() end

				-- Scan local guild, player unit information is now available
				XFG.Handlers.GuildEvent:Initialize()
				XFG.Handlers.SystemEvent:Initialize()
				XFG.Handlers.PlayerEvent:Initialize()

				-- Restore links from backup
				if(XFG.Cache.UIReload) then XFG.Links:Restore() end

				-- Player will start sending guild chat and achievement messages
				-- We want this after player unit information is available because its included in the messages				
				XFG.Handlers.ChatEvent:Initialize()
				XFG.Handlers.AchievementEvent:Initialize()
				
				-- Start all timers
				XFG.Timers:Start()
			
				-- Broadcast IPC message that were g2g
				XFG.Initialized = true
				XFG.Lib.Event:SendMessage(XFG.Settings.Network.Message.IPC.INITIALIZED)
				XFG.DataText.Metrics:SetFont()				
				XFG.DataText.Metrics:RefreshBroker()

				-- Low priority populate setup menus
				XFG:SetupMenus()
			end
		end
		-- If havent gotten guild info after X seconds, give up. probably not in a guild
		if(LoginTime + XFG.Settings.LocalGuild.LoginGiveUp < ServerTime()) then
			error('Did not detect a guild')
		end
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
		XFG:Stop()
	end)
end

function TimerEvent:CallbackDelayedLogin()
	try(function ()
		XFG.Timers:Remove('DelayedLogin')
		if(not XFG.Cache.UIReload) then
			-- These are delayed to see if we get any ping responses before broadcasting
			XFG.Player.Unit:Broadcast(XFG.Settings.Network.Message.Subject.LOGIN)
			--XFG.Links:Broadcast()
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
		XFG.Cache.Backup = {
			Confederate = {},
			Friends = {},
		}
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