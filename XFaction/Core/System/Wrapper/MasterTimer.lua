local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MasterTimer'

XFC.MasterTimer = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.MasterTimer:new()
    local object = XFC.MasterTimer.parent.new(self)
    object.__name = ObjectName
	object.handle = nil
    return object
end
--#endregion

--#region Initializers
function XFC.MasterTimer:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:Start()
		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.MasterTimer:IsRunning()
	return self.handle == nil or not self.handle:IsCancelled()
end

function XFC.MasterTimer:Start()
	if(not self:IsRunning()) then
		self.handle = XFF.TimerStart(XF.Settings.System.MasterTimer, 
		function (...)
			local now = XFF.TimeGetCurrent()
			for _, timer in XFO.Timers:Iterator() do
				if(timer:IsEnabled() and timer:GetLastRan() < now - timer:GetDelta()) then
					timer:Execute()
					if(not timer:IsRepeat()) then
						XF:Debug(self:GetObjectName(), 'Timer will stop due to not being a repeater')
						timer:Stop()
					elseif(timer:HasMaxAttempts() and timer:GetMaxAttempts() <= timer:GetAttempt()) then
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
	end
end

function XFC.MasterTimer:Stop()
	if(self:IsRunning()) then
		self.handle:Cancel()
		self.handle = nil
	end
end
--#endregion