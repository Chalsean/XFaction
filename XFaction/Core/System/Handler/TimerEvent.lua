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
		XF.Timers:Add({name = 'Ping', 
						delta = XF.Settings.Network.BNet.Ping.Timer, 
						callback = XF.Handlers.TimerEvent.CallbackPingFriends, 
						repeater = true, 
						instance = true})
		XF.Timers:Add({name = 'StaleLinks', 
						delta = XF.Settings.Network.BNet.Link.Scan, 
						callback = XF.Handlers.TimerEvent.CallbackStaleLinks, 
						repeater = true, 
						instance = true})
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

function TimerEvent:CallbackLoginPlayer()
	
end
--#endregion

--#region Janitorial Callbacks
-- Cleanup mailbox
function TimerEvent:CallbackMailboxTimer()
	try(function ()
		XF.Mailbox.Chat:Purge(ServerTime() - XF.Settings.Network.Mailbox.Stale)
		XF.Mailbox.BNet:Purge(ServerTime() - XF.Settings.Network.Mailbox.Stale)
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
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
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
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
			XF.Player.Unit:Initialize(XF.Player.Unit:ID())
			XF.Player.Unit:Broadcast()
		end
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
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
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XF.Timers:Get('Ping'):SetLastRan(ServerTime())
	end)
end

-- Periodically broadcast your links
function TimerEvent:CallbackLinks()
	try(function ()
    	XF.Links:Broadcast()
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XF.Timers:Get('Links'):SetLastRan(ServerTime())
	end)
end

-- Periodically purge stale links
function TimerEvent:CallbackStaleLinks()
	try(function ()
		XF.Links:Purge(ServerTime() - XF.Settings.Network.BNet.Link.Stale)
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XF.Timers:Get('StaleLinks'):SetLastRan(ServerTime())
	end)
end
--#endregion
--#endregion