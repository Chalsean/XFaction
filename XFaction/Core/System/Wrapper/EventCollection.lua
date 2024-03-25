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

--#region Hash
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
    event:SetKey(inArgs.name)
    event:SetName(inArgs.event)
    event:SetCallback(inArgs.callback)
    event:IsInstance(inArgs.instance)
    if(inArgs.groupDelta ~= nil) then
        event:SetGroupDelta(inArgs.groupDelta)
        XFO.Timers:Add({
            name = event:GetKey(),
            delta = event:GetGroupDelta(),
            callback = event:GetCallback(),
            repeater = false,
            instance = event:IsInstance(),
            start = false
        })
    end
    if(inArgs.start and (event:IsInstance() or not XF.Player.InInstance)) then
        event:Start()
    end
    self.parent.Add(self, event)
    XF:Info('Event', 'Registered to receive [%s:%s] events', event:GetKey(), event:GetName())
end
--#endregion

--#region Start/Stop
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
    self.frame = CreateFrame('Frame')
    -- Handle the events as they happen
    self.frame:SetScript('OnEvent', function(_, inEvent, ...)
        -- Still actively listen for all events but only do something if enabled
        for _, event in self:Iterator() do
            if(event:GetName() == inEvent and event:IsEnabled()) then
                XF:Trace(ObjectName, 'Event fired: %s', event:GetName())
                if(event:IsGroup()) then
                    XFO.Timers:Get(event:GetKey()):Start()
                else
                    local _Function = event:GetCallback()
                    _Function(self, ...)
                end
            end
        end
    end)

    for _, event in self:Iterator() do
        if(event:IsEnabled()) then
            self.frame:RegisterEvent(event:GetName())
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