local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'TimerEvent'
local GetCurrentTime = GetServerTime
local InGuild = IsInGuild
local GetGuildId = C_Club.GetGuildClubId
local GetNumAddOns = C_Addons.GetNumAddOns
local GetAddOnInfo = C_Addons.GetAddOnInfo

XFC.TimerEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.TimerEvent:new()
    local object = XFC.TimerEvent.parent.new(self)
    object.__name = ObjectName
	object.playerLoginAttempts = 0
    return object
end
--#endregion

--#region Initializers
function XFC.TimerEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		-- WoW Lua does not have a sleep function, so leverage timers for retry mechanics
		XFO.Timers:Add({name = 'LoginGuild', 
						delta = 1, 
						callback = XFO.TimerEvent.CallbackLoginGuild, 
						repeater = true, 
						instance = true,
						ttl = XF.Settings.LocalGuild.LoginTTL,
						start = true})
		XFO.Timers:Add({name = 'LoginPlayer', 
						delta = 1, 
						callback = XFO.TimerEvent.CallbackLoginPlayer, 
						repeater = true, 
						instance = true,
						maxAttempts = XF.Settings.Player.Retry})
		XFO.Timers:Add({name = 'Heartbeat', 
						delta = XF.Settings.Player.Heartbeat, 
						callback = XFO.TimerEvent.CallbackHeartbeat, 
						repeater = true, 
						instance = true})
		XFO.Timers:Add({name = 'Links', 
						delta = XF.Settings.Network.BNet.Link.Broadcast, 
						callback = XFO.TimerEvent.CallbackLinks, 
						repeater = true, 
						instance = true})		    		    
		XFO.Timers:Add({name = 'Mailbox', 
						delta = XF.Settings.Network.Mailbox.Scan, 
						callback = XFO.TimerEvent.CallbackMailboxTimer, 
						repeater = true})
		XFO.Timers:Add({name = 'Ping', 
						delta = XF.Settings.Network.BNet.Ping.Timer, 
						callback = XFO.TimerEvent.CallbackPingFriends, 
						repeater = true, 
						instance = true})
		XFO.Timers:Add({name = 'StaleLinks', 
						delta = XF.Settings.Network.BNet.Link.Scan, 
						callback = XFO.TimerEvent.CallbackStaleLinks, 
						repeater = true, 
						instance = true})
		XFO.Timers:Add({name = 'Offline', 
						delta = XF.Settings.Confederate.UnitScan, 
						callback = XFO.TimerEvent.CallbackOffline, 
						repeater = true, 
						instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
--#region Login Callbacks
function XFC.TimerEvent:CallbackLoginGuild()
	try(function ()
		-- For a time Blizz API says player is not in guild, even if they are
		-- Its not clear what event fires (if any) when this data is available, hence the poller
		if(InGuild()) then
			-- Even though it says were in guild, theres a brief time where the following calls fails, hence the sanity check
			local guildID = GetGuildId()
			if(guildID ~= nil) then
				-- Now that guild info is available we can finish setup
				XF:Debug(self:GetObjectName(), 'Guild info is loaded, proceeding with setup')
				XFO.Timers:Remove('LoginGuild')

				-- Confederate setup via guild info
				XFO.Guilds:Initialize(guildID)
				XFO.Confederate:Initialize()
				XFO.Guilds:SetPlayerGuild()
				XFO.Targets:Initialize()	

				-- Frame inits were waiting on Confederate init
				XFO.ChatFrame:Initialize()
				XFO.SystemFrame:Initialize()

				-- Start network
				XFO.Channels:Initialize()
				XFO.ChannelEvent:Initialize()
				XFO.Chat:Initialize()
				XFO.Nodes:Initialize()
				XFO.Links:Initialize()
				XFO.Friends:Initialize()				
				XFO.BNet:Initialize()

				if(XF.Cache.UIReload) then
					XFO.Confederate:Restore()					
				end

				XFO.Timers:Get('LoginPlayer'):Start()
			end
		end
	end).
	catch(function (err)
		XF:Error(self:GetObjectName(), err)
	end).
	finally(function ()			
		XF:SetupMenus()
	end)
end

function XFC.TimerEvent:CallbackLoginPlayer()
	try(function ()
		-- Need the player data to continue setup
		local unit = XFO.Confederate:Pop()
		-- FIX: Dont have player id, this will throw or get wrong unit
		unit:Initialize()
		if(unit:IsInitialized()) then
			XF:Debug(self:GetObjectName(), 'Player info is loaded, proceeding with setup')
			XFO.Timers:Remove('LoginPlayer')

			XFO.Confederate:Add(unit)
			XF.Player.Unit:Print()

			-- By this point all the channels should have been joined
			if(not XFO.Channels:UseGuild()) then
				XFO.Channels:Sync()
				if(XFO.Channels:HasLocalChannel()) then
					XFO.Channels:SetLast(XFO.Channels:GetLocalChannel():GetKey())
				end
			end
			
			-- If reload, restore backup information
			if(XF.Cache.UIReload) then
				XFO.Friends:Restore()
				XFO.Links:Restore()
				-- FIX: Move to retail
				--XFO.Orders:Restore()
				XF.Cache.UIReload = false
				XF.Player.Unit:Broadcast()
			-- Otherwise send login message
			else
				XF.Player.Unit:Broadcast(XF.Enum.Message.LOGIN)
			end			

			-- Start all hooks, timers and events
			XFO.SystemEvent:Initialize()
			XFO.Hooks:Start()
			XFO.Timers:Start()
			XFO.Events:Start()				
			XF.Initialized = true

			-- Finish DT init
			XFO.DTGuild:PostInitialize()
			XFO.DTLinks:PostInitialize()
			XFO.DTMetrics:PostInitialize()

			-- For support reasons, it helps to know what addons are being used
			for i = 1, GetNumAddOns() do
				local name, _, _, enabled = GetAddOnInfo(i)
				XF:Debug(self:GetObjectName(), 'Addon is loaded [%s] enabled [%s]', name, tostring(enabled))
			end

			XFO.Timers:Add({name = 'LoginChannelSync',
						    delta = XF.Settings.Network.Channel.LoginChannelSyncTimer, 
						    callback = XFO.Channels.Sync,
						    repeater = true,
							maxAttempts = XF.Settings.Network.Channel.LoginChannelSyncAttempts,
						    instance = true,
						    start = true})
		else
			XFO.Confederate:Push(unit)
		end
	end).
	catch(function (err)
		XF:Error(self:GetObjectName(), err)
	end)
end
--#endregion

--#region Janitorial Callbacks
-- Cleanup mailbox
function XFC.TimerEvent:CallbackMailboxTimer()
	try(function ()
		XFO.Chat:Purge(GetCurrentTime() - XF.Settings.Network.Mailbox.Stale)
		XFO.BNet:Purge(GetCurrentTime() - XF.Settings.Network.Mailbox.Stale)
	end).
	catch(function (inErrorMessage)
		XF:Warn(self:GetObjectName(), inErrorMessage)
	end).
	finally(function ()
		XFO.Timers:Get('Mailbox'):SetLastRan(GetCurrentTime())
	end)
end

-- If you haven't heard from a unit in X minutes, set them to offline
function XFC.TimerEvent:CallbackOffline()
	try(function ()
		XFO.Confederate:OfflineUnits(GetCurrentTime() - XF.Settings.Confederate.UnitStale)
	end).
	catch(function (err)
		XF:Warn(self:GetObjectName(), err)
	end).
	finally(function ()
		XFO.Timers:Get('Offline'):SetLastRan(GetCurrentTime())
	end)
end

-- Periodically send update to avoid other considering you offline
function XFC.TimerEvent:CallbackHeartbeat()
	try(function ()
		if(XF.Initialized and XF.Player.LastBroadcast < GetCurrentTime() - XF.Settings.Player.Heartbeat) then
			XF:Debug(self:GetObjectName(), 'Sending heartbeat')
			XF.Player.Unit:Initialize(XF.Player.Unit:GetID())
			XF.Player.Unit:Broadcast()
		end
	end).
	catch(function (err)
		XF:Warn(self:GetObjectName(), err)
	end).
	finally(function ()
		XFO.Timers:Get('Heartbeat'):SetLastRan(GetCurrentTime())
	end)
end

-- Periodically ping friends to see who is running addon
function XFC.TimerEvent:CallbackPingFriends()
    try(function()
	    for _, friend in XFO.Friends:Iterator() do
			if(not friend:IsRunningAddon()) then
				friend:Ping()
			end
	    end
	end).
	catch(function (err)
		XF:Warn(self:GetObjectName(), err)
	end).
	finally(function ()
		XFO.Timers:Get('Ping'):SetLastRan(GetCurrentTime())
	end)
end

-- Periodically broadcast your links
function XFC.TimerEvent:CallbackLinks()
	try(function ()
    	XFO.Links:Broadcast()
	end).
	catch(function (inErrorMessage)
		XF:Warn(self:GetObjectName(), inErrorMessage)
	end).
	finally(function ()
		XFO.Timers:Get('Links'):SetLastRan(GetCurrentTime())
	end)
end

-- Periodically purge stale links
function XFC.TimerEvent:CallbackStaleLinks()
	try(function ()
		XFO.Links:Purge(GetCurrentTime() - XF.Settings.Network.BNet.Link.Stale)
	end).
	catch(function (err)
		XF:Warn(self:GetObjectName(), err)
	end).
	finally(function ()
		XFO.Timers:Get('StaleLinks'):SetLastRan(GetCurrentTime())
	end)
end
--#endregion
--#endregion