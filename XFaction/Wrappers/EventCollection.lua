local XFG, G = unpack(select(2, ...))
local ObjectName = 'EventCollection'

EventCollection = ObjectCollection:newChildConstructor()

function EventCollection:new()
    local _Object = EventCollection.parent.new(self)
	_Object.__name = ObjectName
    return _Object
end

function EventCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self._Frame = CreateFrame('Frame')
        -- Handle the events as they happen
        self._Frame:SetScript('OnEvent', function(self, inEvent, ...)
            for _, _Event in XFG.Events:Iterator() do
                if(_Event:IsEnabled() and _Event:GetName() == inEvent) then
                    local _Function = _Event:GetCallback()
                    _Function(self, ...)
                end
            end
        end)
        self:IsInitialized(true)
    end
end

function EventCollection:Add(inKey, inName, inCallback, inInstance, inInstanceCombat)
    local _Event = Event:new()
    _Event:SetKey(inKey)
    _Event:SetName(inName)
    _Event:SetCallback(inCallback)
    _Event:IsInstance(inInstance)
    _Event:IsInstanceCombat(inInstanceCombat)
    if(_Event:IsInstance() or not XFG.Player.InInstance) then
        _Event:Start()
    end
    self._Frame:RegisterEvent(inName)
    self.parent.Add(self, _Event)
    XFG:Info('Event', 'Registered to receive %s events', inName)
end

function EventCollection:EnterInstance()
    for _, _Event in self:Iterator() do
        if(_Event:IsEnabled() and not _Event:IsInstance()) then
            _Event:Stop()
        end
    end
end

function EventCollection:LeaveInstance()
    for _, _Event in self:Iterator() do
        -- Can only change covenant in Oribos
        if(not _Event:IsEnabled() and _Event:GetName() ~= 'Covenant') then
            _Event:Start()
        end
    end
end

function EventCollection:EnterCombat()
    for _, _Event in self:Iterator() do
        if(_Event:IsEnabled() and not _Event:IsInstanceCombat()) then
            _Event:Stop()
        end
    end
end

function EventCollection:LeaveCombat()
    for _, _Event in self:Iterator() do
        if(not _Event:IsEnabled() and _Event:IsInstance()) then
            _Event:Start()
        end
    end
end

-- Stop everything
function EventCollection:Stop()
	for _, _Event in XFG.Events:Iterator() do
        _Event:Stop()
	end
    self._Frame:UnregisterAllEvents()
end