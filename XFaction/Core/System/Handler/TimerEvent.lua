local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'TimerEvent'
local GetCurrentTime = GetServerTime
local NewTicker = C_Timer.NewTicker

XFC.TimerEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.TimerEvent:new()
    local object = XFC.TimerEvent.parent.new(self)
    object.__name = ObjectName
	object.handle = nil
    return object
end
--#endregion

--#region Initializers
function XFC.TimerEvent:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.handle = NewTicker(XF.Settings.System.MasterTimer, 
                function (...)
					local now = GetCurrentTime()
					for _, timer in XFO.Timers:Iterate() do
						if(timer:IsEnabled() and timer:GetLastRan() < now - timer:GetDelta()) then
							timer:Execute()
							if(timer:HasMaxAttempts() and timer:GetMaxAttempts() <= timer:GetAttempt()) then
								XF:Debug(self:GetObjectName(), 'Timer will stop due to attempt limit [' .. tostring(timer:GetMaxAttempts()) .. '] being reached: ' .. timer:GetKey())
								timer:Stop()
							elseif(timer:HasTimeToLive() and timer:GetStartTime() + timer:GetTimeToLive() < now) then
								XF:Debug(self:GetObjectName(), 'Timer will stop due to time limit [' .. tostring(timer:GetTimeToLive()) .. '] being reached: ' .. timer:GetKey())
								timer:Stop()
							else
								timer:Reset()
							end
						end
					end                
                end)
		self:IsInitialized(true)
	end
end
--#endregion