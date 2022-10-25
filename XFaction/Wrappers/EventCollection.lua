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
            for _, event in XFG.Events:Iterator() do
                if(event:IsEnabled() and event:GetName() == inEvent) then
                    local _Function = event:GetCallback()
                    _Function(self, ...)
                end
            end
        end)
        self:IsInitialized(true)
    end
end
--#endregion

--#region Hash
function EventCollection:Add(inKey, inName, inCallback, inInstance, inInstanceCombat)
    local event = Event:new()
    event:SetKey(inKey)
    event:SetName(inName)
    event:SetCallback(inCallback)
    event:IsInstance(inInstance)
    event:IsInstanceCombat(inInstanceCombat)
    if(event:IsInstance() or not XFG.Player.InInstance) then
        event:Start()
    end
    self.frame:RegisterEvent(inName)
    self.parent.Add(self, event)
    XFG:Info('Event', 'Registered to receive %s events', inName)
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

function EventCollection:EnterCombat()
    for _, event in self:Iterator() do
        if(event:IsEnabled() and not event:IsInstanceCombat()) then
            event:Stop()
        end
    end
end

function EventCollection:LeaveCombat()
    for _, event in self:Iterator() do
        if(not event:IsEnabled() and event:IsInstance()) then
            event:Start()
        end
    end
end

-- Stop everything
function EventCollection:Stop()
	for _, event in XFG.Events:Iterator() do
        event:Stop()
	end
    self.frame:UnregisterAllEvents()
end
--#endregion