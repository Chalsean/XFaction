local XFG, G = unpack(select(2, ...))
local ObjectName = 'EventCollection'

EventCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function EventCollection:new()
    local object = EventCollection.parent.new(self)
	object.__name = ObjectName
    object.frame = nil
    return object
end
--#endregion

--#region Initializers
function EventCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.frame = CreateFrame('Frame')
        -- Handle the events as they happen
        self.frame:SetScript('OnEvent', function(self, inEvent, ...)
            -- Still actively listen for all events but only do something if enabled
            for _, event in XFG.Events:Iterator() do
                if(event:GetName() == inEvent and event:IsEnabled()) then
                    XFG:Trace(ObjectName, 'Event fired: %s', event:GetName())
                    if(event:IsGroup()) then
                        if(XFG.Timers:Contains(event:GetKey())) then
                            XFG.Timers:Get(event:GetKey()):Start()
                        else
                            XFG.Timers:Add({name = event:GetKey(),
                                            delta = event:GetGroupDelta(),
                                            callback = event:GetCallback(),
                                            repeater = false,
                                            instance = event:IsInstance(),
                                            start = true})
                        end
                    else
                        local _Function = event:GetCallback()
                        _Function(self, ...)
                    end
                end
            end
        end)
        self:IsInitialized(true)        
    end
end
--#endregion

--#region Hash
function EventCollection:Add(inArgs)
    assert(type(inArgs) == 'table')
    assert(type(inArgs.name) == 'string')
    assert(type(inArgs.event) == 'string')
    assert(type(inArgs.callback) == 'function')
    assert(inArgs.instance == nil or type(inArgs.instance) == 'boolean')
    assert(inArgs.start == nil or type(inArgs.start) == 'boolean')
    assert(inArgs.groupDelta == nil or type(inArgs.groupDelta) == 'number')

    local event = Event:new()
    event:SetKey(inArgs.name)
    event:SetName(inArgs.event)
    event:SetCallback(inArgs.callback)
    event:IsInstance(inArgs.instance)
    if(inArgs.groupDelta ~= nil) then
        event:SetGroupDelta(inArgs.groupDelta)
    end
    if(inArgs.start and (event:IsInstance() or not XFG.Player.InInstance)) then
        event:Start()
    end
    self.frame:RegisterEvent(event:GetName())
    self.parent.Add(self, event)
    XFG:Info('Event', 'Registered to receive [%s:%s] events', event:GetKey(), event:GetName())
end
--#endregion

--#region Start/Stop
function EventCollection:EnterInstance()
    for _, event in self:Iterator() do
        if(event:IsEnabled() and not event:IsInstance()) then
            event:Stop()
        end
    end
end

function EventCollection:LeaveInstance()
    for _, event in self:Iterator() do
        if(not event:IsEnabled()) then
            event:Start()
        end
    end
end

-- Start/Stop everything
function EventCollection:Start()
	for _, event in self:Iterator() do
        if(not event:IsEnabled()) then
            event:Start()
        end
	end
end

function EventCollection:Stop()
	for _, event in self:Iterator() do
        if(event:IsEnabled()) then
            event:Stop()
        end
	end
    self.frame:UnregisterAllEvents()
end
--#endregion