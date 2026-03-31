local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'TimerCollection'

XFC.TimerCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.TimerCollection:new()
    local object = XFC.TimerCollection.parent.new(self)
	object.__name = ObjectName
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
    for _, timer in self:Iterator() do
        if(not timer:IsEnabled()) then
            timer:Start()
            if(timer:LastRan() < XFF.TimeCurrent() - timer:Delta()) then
                local _Function = timer:Callback()
                _Function()
                timer:LastRan(XFF.TimeCurrent())
            end
        end
    end
end

-- Start everything
function XFC.TimerCollection:Start()
	for _, timer in self:Iterator() do
        timer:Start()
	end
end

-- Stop everything
function XFC.TimerCollection:Stop()
	for _, timer in self:Iterator() do
        timer:Stop()
	end
end
--#endregion