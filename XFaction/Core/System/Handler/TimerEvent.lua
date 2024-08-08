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
		
		XFO.Timers:Add({name = 'Heartbeat', 
						delta = XF.Settings.Player.Heartbeat, 
						callback = XF.Handlers.TimerEvent.CallbackHeartbeat, 
						repeater = true, 
						instance = true})    		    
		
		XFO.Timers:Add({name = 'Offline', 
						delta = XF.Settings.Confederate.UnitScan, 
						callback = XF.Handlers.TimerEvent.CallbackOffline, 
						repeater = true, 
						instance = true})
		self:IsInitialized(true)
	end
end
--#endregion

--#region Janitorial Callbacks
-- If you haven't heard from a unit in X minutes, set them to offline
function TimerEvent:CallbackOffline()
	try(function ()
		XFO.Confederate:OfflineUnits(ServerTime() - XF.Settings.Confederate.UnitStale)
	end).
	catch(function (inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
	end).
	finally(function ()
		XFO.Timers:Get('Offline'):SetLastRan(ServerTime())
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
		XFO.Timers:Get('Heartbeat'):SetLastRan(ServerTime())
	end)
end
--#endregion
--#endregion