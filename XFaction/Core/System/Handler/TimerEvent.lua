local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TimerEvent'
local ServerTime = GetServerTime
local GuildRosterEvent = C_GuildInfo.GuildRoster
local InGuild = IsInGuild
local GetGuildClubId = C_Club.GetGuildClubId
local RequestMapsFromServer = C_MythicPlus.RequestMapInfo

TimerEvent = XFC.Object:newChildConstructor()

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
		XF.Timers:Add({name = 'LoginGuild', 
						delta = 1, 
						callback = XF.Handlers.TimerEvent.CallbackLoginGuild, 
						repeater = true, 
						instance = true,
						ttl = XF.Settings.LocalGuild.LoginTTL,
						start = true})
		XF.Timers:Add({name = 'LoginPlayer', 
						delta = 1, 
						callback = XF.Handlers.TimerEvent.CallbackLoginPlayer, 
						repeater = true, 
						instance = true,
						maxAttempts = XF.Settings.Player.Retry})
		XF.Timers:Add({name = 'Heartbeat', 
						delta = XF.Settings.Player.Heartbeat, 
						callback = XF.Handlers.TimerEvent.CallbackHeartbeat, 
						repeater = true, 
						instance = true})
		XF.Timers:Add({name = 'Links', 
						delta = XF.Settings.Network.BNet.Link.Broadcast, 
						callback = XF.Handlers.TimerEvent.CallbackLinks, 
						repeater = true, 
						instance = true})		    		    
		XF.Timers:Add({name = 'Mailbox', 
						delta = XF.Settings.Network.Mailbox.Scan, 
						callback = XF.Handlers.TimerEvent.CallbackMailboxTimer, 
						repeater = true})
		XF.Timers:Add({name = 'Offline', 
						delta = XF.Settings.Confederate.UnitScan, 
						callback = XF.Handlers.TimerEvent.CallbackOffline, 
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
				XF:Debug(ObjectName, 'Guild info is loaded, proceeding with setup')
				XF.Timers:Remove('LoginGuild')

				-- Confederate setup via guild info
				XFO.Guilds:Initialize(guildID)
				XFO.Confederate:Initialize()
				XFO.Guilds:SetPlayerGuild()
				XFO.Targets:Initialize()	

				-- Frame inits were waiting on Confederate init
				XF.Frames.Chat:Initialize()
				XF.Frames.System:Initialize()

				-- Start network
				XFO.Channels:Initialize()
				XF.Mailbox.Chat:Initialize()
				XFO.Friends:Initialize()				
				XF.Mailbox.BNet:Initialize()

				if(XF.Cache.UIReload) then
					XFO.Confederate:Restore()					
				end

				XF.Timers:Get('LoginPlayer'):Start()
			end
		end
	end).
	catch(function (err)
		XF:Error(ObjectName, err)
	end).
	finally(function ()			
		XF:SetupMenus()
	end)
end

function TimerEvent:CallbackLoginPlayer()
	try(function ()
		-- Far as can tell does not fire event, so call and pray it loads before we query for the data
		RequestMapsFromServer()

		-- Need the player data to continue setup
		local unitData = XFO.Confederate:Pop()
		unitData:Initialize()
		if(unitData:IsInitialized()) then
			XF:Debug(ObjectName, 'Player info is loaded, proceeding with setup')
			XF.Timers:Remove('LoginPlayer')

			XFO.Confederate:Add(unitData)
			XF.Player.Unit:Print()

			-- By this point all the channels should have been joined
			if(not XFO.Channels:UseGuild()) then
				XFO.Channels:CallbackSync()
				if(XFO.Channels:HasLocalChannel()) then
					XFO.Channels:SetLast(XFO.Channels:LocalChannel():Key())
				end
			end
			
			-- If reload, restore backup information
			if(XF.Cache.UIReload) then
				XFO.Friends:Restore()
				XFO.Links:Restore()
				XFO.Orders:Restore()
				XF.Cache.UIReload = false
				XF.Mailbox.Chat:SendDataMessage(XF.Player.Unit)
			-- Otherwise send login message
			else
				XF.Mailbox.Chat:SendLoginMessage(XF.Player.Unit)
			end			

			-- Start all hooks, timers and events
			XF.Handlers.SystemEvent:Initialize()
			XF.Hooks:Start()
			XF.Timers:Start()
			XF.Events:Start()				
			XF.Initialized = true

			-- Finish DT init
			XF.DataText.Guild:PostInitialize()
			XF.DataText.Links:PostInitialize()
			XF.DataText.Metrics:PostInitialize()

			-- For support reasons, it helps to know what addons are being used
			for i = 1, GetNumAddOns() do
				local name, _, _, enabled = GetAddOnInfo(i)
				XF:Debug(ObjectName, 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end		

			XF.Timers:Add({
				name = 'LoginChannelSync',
				delta = XF.Settings.Network.Channel.LoginChannelSyncTimer, 
				callback = XFO.Channels.CallbackSync,
				repeater = true,
				maxAttempts = XF.Settings.Network.Channel.LoginChannelSyncAttempts,
				instance = true,
				start = true
			})
		else
			XFO.Confederate:Push(unitData)
		end
	end).
	catch(function (err)
		XF:Error(ObjectName, err)
	end)
end
--#endregion

--#region Janitorial Callbacks
-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
	try(function ()
		XF.Mailbox.Chat:Purge(ServerTime() - XF.Settings.Network.Mailbox.Stale)
		XF.Mailbox.BNet:Purge(ServerTime() - XF.Settings.Network.Mailbox.Stale)
	end).
	catch(function (err)
		XF:Warn(ObjectName, err)
	end).
	finally(function ()
		XF.Timers:Get('Mailbox'):SetLastRan(ServerTime())
	end)
end

-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
	try(function ()
		XFO.Confederate:OfflineUnits(ServerTime() - XF.Settings.Confederate.UnitStale)
	end).
	catch(function (err)
		XF:Warn(ObjectName, err)
	end).
	finally(function ()
		XF.Timers:Get('Offline'):SetLastRan(ServerTime())
	end)
end

-- Periodically send update to avoid other considering you offline
function TimerEvent:CallbackHeartbeat()
	try(function ()
		if(XF.Initialized and XF.Player.LastBroadcast < ServerTime() - XF.Settings.Player.Heartbeat) then
			XF:Debug(ObjectName, 'Sending heartbeat')
			XF.Mailbox.Chat:SendDataMessage(XF.Player.Unit)
		end
	end).
	catch(function (err)
		XF:Warn(ObjectName, err)
	end).
	finally(function ()
		XF.Timers:Get('Heartbeat'):SetLastRan(ServerTime())
	end)
end

-- Periodically ping friends to see who is running addon
function TimerEvent:CallbackPingFriends()
    try(function()
	    for _, friend in XF.Friends:Iterator() do
			if(not friend:IsRunningAddon()) then
				friend:Ping()
			end
	    end
	end).
	catch(function (err)
		XF:Warn(ObjectName, err)
	end).
	finally(function ()
		XF.Timers:Get('Ping'):SetLastRan(ServerTime())
	end)
end

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
	try(function ()
		XF.Mailbox.Chat:SendLinkMessage(XFO.Links:LegacySerialize())
	end).
	catch(function (err)
		XF:Warn(ObjectName, err)
	end).
	finally(function ()
		XF.Timers:Get('Links'):SetLastRan(ServerTime())
	end)
end
--#endregion
--#endregion