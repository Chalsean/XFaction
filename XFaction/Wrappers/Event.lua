local XFG, G = unpack(select(2, ...))
local ObjectName = 'Event'

Event = Object:newChildConstructor()

--#region Constructors
function Event:new()
    local object = Event.parent.new(self)
    object.__name = ObjectName
    object.callback = nil
    object.isEnabled = false
    object.inInstance = false
    object.groupDelta = 0
    return object
end
--#endregion

--#region Print
function Event:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XFG:Debug(ObjectName, '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XFG:Debug(ObjectName, '  inInstance (' .. type(self.inInstance) .. '): ' .. tostring(self.inInstance))
    XFG:Debug(ObjectName, '  groupDelta (' .. type(self.groupDelta) .. '): ' .. tostring(self.groupDelta))
end
--#endregion

--#region Accessors
function Event:GetCallback()
    return self.callback
end

function Event:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self.callback = inCallback
end

function Event:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function Event:IsInstance(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.inInstance = inBoolean
    end
	return self.inInstance
end

function Event:IsGroup()
    return self.groupDelta > 0
end

function Event:GetGroupDelta()
    return self.groupDelta
end

function Event:SetGroupDelta(inGroupDelta)
    assert(type(inGroupDelta) == 'number')
    self.groupDelta = inGroupDelta
end
--#endregion

--#region Start/Stop
function Event:Start()
    self:IsEnabled(true)
    XFG:Debug(ObjectName, 'Started event listener [%s] for [%s]', self:GetKey(), self:GetName())
end

function Event:Stop()
    self:IsEnabled(false)
    XFG:Debug(ObjectName, 'Stopped event listener [%s] for [%s]', self:GetKey(), self:GetName())
end
--#endregion