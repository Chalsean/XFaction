local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'EventCollection'

XFC.EventCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.EventCollection:new()
    local object = XFC.EventCollection.parent.new(self)
	object.__name = ObjectName
    object.frame = nil
    return object
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
    event:Initialize()
    event:Key(inArgs.name)
    event:Name(inArgs.event)
    event:Callback(inArgs.callback)
    event:IsInstance(inArgs.instance)
    if(inArgs.groupDelta ~= nil) then
        event:GroupDelta(inArgs.groupDelta)
        XFO.Timers:Add({
            name = event:Key(),
            delta = event:GroupDelta(),
            callback = event:Callback(),
            repeater = false,
            instance = event:IsInstance(),
            start = false
        })
    end
    if(inArgs.start and (event:IsInstance() or not XF.Player.InInstance)) then
        event:Start()
    end
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
    self:EnableAll()
end

function XFC.EventCollection:EnableAll()
    for _, event in self:Iterator() do
        if(not event:IsEnabled()) then
            event:Start()
        end
    end
end

function XFC.EventCollection:Start()
    self.frame = CreateFrame('Frame')
    -- Handle the events as they happen
    self.frame:SetScript('OnEvent', function(_, inEvent, ...)
        -- Still actively listen for all events but only do something if enabled
        for _, event in self:Iterator() do
            if(event:Name() == inEvent and event:IsEnabled()) then
                XF:Trace(ObjectName, 'Event fired: %s', event:Name())
                if(event:IsGroup()) then
                    XFO.Timers:Get(event:Key()):Start()
                else
                    local _Function = event:Callback()
                    _Function(self, ...)
                end
            end
        end
    end)

    for _, event in self:Iterator() do
        if(event:IsEnabled()) then
            self.frame:RegisterEvent(event:Name())
        end
    end
end

function XFC.EventCollection:Stop()
	if(self.frame ~= nil) then
        try(function()
            self.frame:UnregisterAllEvents()
        end).
        catch(function(err) end).
        finally(function()
            self.frame = nil
        end)
    end
end
--#endregion