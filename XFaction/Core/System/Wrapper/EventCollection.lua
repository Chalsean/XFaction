local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'EventCollection'

XFC.EventCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.EventCollection:new()
    local object = XFC.EventCollection.parent.new(self)
	object.__name = ObjectName
    object.frame = nil
    return object
end

function XFC.EventCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.frame = CreateFrame('Frame')
        -- Handle the events as they happen
        self.frame:SetScript('OnEvent', function(self, inEvent, ...)
            -- Still actively listen for all events but only do something if enabled
            for _, event in XFO.Events:Iterator() do
                if(event:Name() == inEvent and event:IsEnabled()) then
                    XF:Trace(ObjectName, 'Event fired: %s', event:Name())
                    if(event:IsGroup()) then
                        if(XFO.Timers:Contains(event:Key())) then
                            XFO.Timers:Get(event:Key()):Start()
                        else
                            XFO.Timers:Add({name = event:Key(),
                                            delta = event:GroupDelta(),
                                            callback = event:Callback(),
                                            repeater = false,
                                            instance = event:IsInstance(),
                                            start = true})
                        end
                    else
                        local _Function = event:Callback()
                        _Function(self, ...)
                    end
                end
            end
        end)
        self:IsInitialized(true)        
    end
end
--#endregion

--#region Methods
function XFC.EventCollection:Add(inArgs)
    assert(type(inArgs) == 'table')
    assert(type(inArgs.name) == 'string')
    assert(type(inArgs.event) == 'string')
    assert(type(inArgs.callback) == 'function')
    assert(inArgs.instance == nil or type(inArgs.instance) == 'boolean')
    assert(inArgs.start == nil or type(inArgs.start) == 'boolean')
    assert(inArgs.groupDelta == nil or type(inArgs.groupDelta) == 'number')

    local event = XFC.Event:new()
    event:Key(inArgs.name)
    event:Name(inArgs.event)
    event:Callback(inArgs.callback)
    event:IsInstance(inArgs.instance)
    if(inArgs.groupDelta ~= nil) then
        event:GroupDelta(inArgs.groupDelta)
    end
    if(inArgs.start and (event:IsInstance() or not XF.Player.InInstance)) then
        event:Start()
    end
    self.frame:RegisterEvent(event:Name())
    self.parent.Add(self, event)
    XF:Info('Event', 'Registered to receive [%s:%s] events', event:Key(), event:Name())
end

function XFC.EventCollection:EnterInstance()
    for _, event in self:Iterator() do
        if(event:IsEnabled() and not event:IsInstance()) then
            event:Stop()
        end
    end
end

function XFC.EventCollection:LeaveInstance()
    for _, event in self:Iterator() do
        if(not event:IsEnabled()) then
            event:Start()
        end
    end
end

-- Start/Stop everything
function XFC.EventCollection:Start()
	for _, event in self:Iterator() do
        if(not event:IsEnabled()) then
            event:Start()
        end
	end
end

function XFC.EventCollection:Stop()
	for _, event in self:Iterator() do
        if(event:IsEnabled()) then
            event:Stop()
        end
	end
    self.frame:UnregisterAllEvents()
end
--#endregion