local XFG, G = unpack(select(2, ...))
local ObjectName = 'TimerEvent'
local ServerTime = GetServerTime
local GuildRosterEvent = C_GuildInfo.GuildRoster
local InGuild = IsInGuild
local GetGuildClubId = C_Club.GetGuildClubId

TimerEvent = Object:newChildConstructor()

--#region Constructors
function TimerEvent:new()
    local object = TimerEvent.parent.new(self)
    object.__name = ObjectName
	object.playerLoginAttempts = 0
    return object
end
--#endregion

--#region Initializers
function TimerEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		-- WoW Lua does not have a sleep function, so leverage timers for retry mechanics
		XFG.Timers:Add({name = 'LoginGuild', 
						delta = 1, 
						callback = XFG.Handlers.TimerEvent.CallbackLoginGuild, 
						repeater = true, 
						instance = true,
						ttl = XFG.Settings.LocalGuild.LoginTTL,
						start = true})
		XFG.Timers:Add({name = 'LoginPlayer', 
						delta = 1, 
						callback = XFG.Handlers.TimerEvent.CallbackLoginPlayer, 
						repeater = true, 
						instance = true,
						maxAttempts = XFG.Settings.Player.Retry})
		XFG.Timers:Add({name = 'Heartbeat', 
						delta = XFG.Settings.Player.Heartbeat, 
						callback = XFG.Handlers.TimerEvent.CallbackHeartbeat, 
						repeater = true, 
						instance = true})
		XFG.Timers:Add({name = 'Links', 
						delta = XFG.Settings.Network.BNet.Link.Broadcast, 
						callback = XFG.Handlers.TimerEvent.CallbackLinks, 
						repeater = true, 
						instance = true})		    		    
		XFG.Timers:Add({name = 'Mailbox', 
						delta = XFG.Settings.Network.Mailbox.Scan, 
						callback = XFG.Handlers.TimerEvent.CallbackMailboxTimer, 
						repeater = true})
		XFG.Timers:Add({name = 'Ping', 
						delta = XFG.Settings.Network.BNet.Ping.Timer, 
						callback = XFG.Handlers.TimerEvent.CallbackPingFriends, 
						repeater = true, 
						instance = true})
		XFG.Timers:Add({name = 'StaleLinks', 
						delta = XFG.Settings.Network.BNet.Link.Scan, 
						callback = XFG.Handlers.TimerEvent.CallbackStaleLinks, 
						repeater = true, 
						instance = true})
		XFG.Timers:Add({name = 'Offline', 
						delta = XFG.Settings.Confederate.UnitScan, 
						callback = XFG.Handlers.TimerEvent.CallbackOffline, 
						repeater = true, 
						instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
--#region Login Callbacks
function TimerEvent:CallbackLoginGuild()
	try(function ()
		-- For a time Blizz API says player is not in guild, even if they are
		-- Its not clear what event fires (if any) when this data is available, hence the poller
		if(InGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = GetGuildClubId()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XFG:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XFG.Timers:Remove('LoginGuild')

				-- Confederate setup via guild info
				XFG.Guilds:Initialize(guildID)
				XFG.Confederate:Initialize()
				XFG.Guilds:SetPlayerGuild()
				XFG.Targets:Initialize()	

				-- Frame inits were waiting on Confederate init
				XFG.Frames.Chat:Initialize()
				XFG.Frames.System:Initialize()

				-- Some of this data (spec) is like guild where its not available for a time after initial login
				-- Seems to align with guild data becoming available
				XFG.Races:Initialize()
				XFG.Classes:Initialize()
				XFG.Specs:Initialize()		    
				XFG.Professions:Initialize()

				-- Start network
				XFG.Channels:Initialize()
				XFG.Handlers.ChannelEvent:Initialize()
				XFG.Mailbox.Chat:Initialize()
				XFG.Nodes:Initialize()
				XFG.Links:Initialize()
				XFG.Friends:Initialize()				
				XFG.Mailbox.BNet:Initialize()
				
				if(XFG.Cache.UIReload) then
					XFG.Confederate:Restore() 
				end

				XFG.Timers:Get('LoginPlayer'):Start()
			end
		end
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
	end).
	finally(function ()			
		XFG:SetupMenus()
	end)
end

function TimerEvent:CallbackLoginPlayer()
	try(function ()
		-- Need the player data to continue setup
		local unitData = XFG.Confederate:Pop()
		unitData:Initialize()
		if(unitData:IsInitialized()) then
			XFG:Debug(ObjectName, 'Player info is loaded, proceeding with setup')
			XFG.Timers:Remove('LoginPlayer')

			XFG.Confederate:Add(unitData)
			XFG.Player.Unit:Print()

			-- By this point all the channels should have been joined
			if(not XFG.Channels:UseGuild()) then
				XFG.Channels:Sync()
				if(XFG.Channels:HasLocalChannel()) then
					XFG.Channels:SetLast(XFG.Channels:GetLocalChannel():GetKey())
				end
			end
			
			-- If reload, restore backup information
			if(XFG.Cache.UIReload) then
				XFG.Friends:Restore()
				XFG.Links:Restore()
				XFG.Cache.UIReload = false
			-- Otherwise send login message
			else
				XFG.Player.Unit:Broadcast(XFG.Enum.Message.LOGIN)
			end			

			-- Start all hooks, timers and events
			XFG.Handlers.SystemEvent:Initialize()
			XFG.Hooks:Start()
			XFG.Timers:Start()
			XFG.Events:Start()				
			XFG.Initialized = true

			-- Finish DT init
			XFG.DataText.Guild:PostInitialize()
			XFG.DataText.Links:PostInitialize()
			XFG.DataText.Metrics:PostInitialize()
			XFG.DataText.Orders:PostInitialize()

			-- For support reasons, it helps to know what addons are being used
			for i = 1, GetNumAddOns() do
				local name, _, _, enabled = GetAddOnInfo(i)
				XFG:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end

			XFG.Timers:Add({name = 'LoginChannelSync',
						    delta = XFG.Settings.Network.Channel.LoginChannelSyncTimer, 
						    callback = XFG.Handlers.TimerEvent.CallbackChannelSync,
						    repeater = true,
							maxAttempts = XFG.Settings.Network.Channel.LoginChannelSyncAttempts,
						    instance = true,
						    start = true})
		else
			XFG.Confederate:Push(unitData)
		end
	end).
	catch(function (inErrorMessage)
		XFG:Error(ObjectName, inErrorMessage)
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

function TimerEvent:CallbackChannelSync()
	try(function ()
		XFG.Channels:Sync()
		if(XFG.Channels:HasLocalChannel()) then
			XFG.Channels:SetLast(XFG.Channels:GetLocalChannel():GetKey())
		end
	end).
	catch(function (inErrorMessage)
		XFG:Warn(ObjectName, inErrorMessage)
	end)
end
--#endregion
--#endregion