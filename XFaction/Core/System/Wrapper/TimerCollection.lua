local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TimerCollection'

XFC.TimerCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TimerCollection:new()
    local object = XFC.TimerCollection.parent.new(self)
	object.__name = ObjectName
    object.handle = nil
    return object
end
--#endregion

--#region Methods
function XFC.TimerCollection:Add(inArgs)
    assert(type(inArgs) == 'table')
    assert(type(inArgs.name) == 'string')
    assert(type(inArgs.delta) == 'number')
    assert(type(inArgs.callback) == 'function')
    assert(inArgs.repeater == nil or type(inArgs.repeater) == 'boolean')
    assert(inArgs.instance == nil or type(inArgs.instance) == 'boolean')
    assert(inArgs.start == nil or type(inArgs.start) == 'boolean')
    assert(inArgs.ttl == nil or type(inArgs.ttl) == 'number')
    assert(inArgs.maxAttempts == nil or type(inArgs.maxAttempts) == 'number')

    local timer = XFC.Timer:new()
    timer:Initialize()
    timer:Key(inArgs.name)
    timer:Name(timer:Key())
    timer:Delta(inArgs.delta)
    timer:Callback(inArgs.callback)
    timer:IsRepeat(inArgs.repeater)
    timer:IsInstance(inArgs.instance)
    if(inArgs.ttl ~= nil) then
        timer:TimeToLive(inArgs.ttl)
    end
    if(inArgs.maxAttempts ~= nil) then
        timer:MaxAttempts(inArgs.maxAttempts)
    end
    if(inArgs.start and (timer:IsInstance() or not XF.Player.InInstance)) then
        timer:Start()
    end

    self.parent.Add(self, timer)
end

function XFC.TimerCollection:Remove(inKey)
    if(self:Contains(inKey)) then
        self:Get(inKey):Stop()
        self.parent.Remove(self, inKey)
    end
end

function XFC.TimerCollection:EnterInstance()
    for _, timer in self:Iterator() do
        if(timer:IsEnabled() and not timer:IsInstance()) then
            timer:Stop()
        end
    end
end

function XFC.TimerCollection:LeaveInstance()
    self:EnableAll()
end

function XFC.TimerCollection:EnableAll()
    for _, timer in self:Iterator() do
        if(not timer:IsEnabled()) then
            timer:Start()
        end
    end
end

function XFC.TimerCollection:IsRunning()
	return not self.handle == nil and not self.handle:IsCancelled()
end

function XFC.TimerCollection:Start()
	if(not self:IsRunning()) then
		self.handle = XFF.TimerStart(XF.Settings.System.MasterTimer, 
		function ()
			local now = XFF.TimeGetCurrent()
			for _, timer in self:Iterator() do
				if(timer:IsEnabled() and timer:LastRan() < now - timer:Delta()) then
					timer:Execute()
					if(not timer:IsRepeat()) then
						XF:Trace(self:ObjectName(), 'Timer will stop due to not being a repeater')
						timer:Stop()
					elseif(timer:MaxAttempts() ~= nil and timer:MaxAttempts() <= timer:Attempt()) then
						XF:Trace(self:ObjectName(), 'Timer will stop due to attempt limit [' .. tostring(timer:MaxAttempts()) .. '] being reached: ' .. timer:Key())
						timer:Stop()
					elseif(timer:TimeToLive() ~= nil and timer:StartTime() + timer:TimeToLive() < now) then
						XF:Trace(self:ObjectName(), 'Timer will stop due to time limit [' .. tostring(timer:TimeToLive()) .. '] being reached: ' .. timer:Key())
						timer:Stop()
					else
						timer:Reset()
					end
				end
			end                
		end)
	end
end

function XFC.TimerCollection:Stop()
	if(self.handle ~= nil) then
        try(function()
		    self.handle:Cancel()
        end).
        catch(function(err) end).
        finally(function()
		    self.handle = nil
        end)
	end
end
--#endregion