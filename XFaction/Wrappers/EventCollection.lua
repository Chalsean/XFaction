local XFG, G = unpack(select(2, ...))

EventCollection = ObjectCollection:newChildConstructor()

function EventCollection:new()
    local _Object = EventCollection.parent.new(self)
	_Object.__name = 'EventCollection'
    return _Object
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
		_Event:IsEnabled(false)
	end
end