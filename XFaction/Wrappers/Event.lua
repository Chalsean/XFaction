local XFG, G = unpack(select(2, ...))
local ObjectName = 'Event'

Event = Object:newChildConstructor()

--#region Constructors
function Event:new()
    local object = Event.parent.new(self)
    object.__name = ObjectName
    object.delta = 0
    object.callback = nil
    object.isEnabled = false
    object.inInstance = false
    object.isIPC = false
    return object
end
--#endregion

--#region Print
function Event:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  delta (' .. type(self.delta) .. '): ' .. tostring(self.delta))
    XFG:Debug(ObjectName, '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XFG:Debug(ObjectName, '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XFG:Debug(ObjectName, '  inInstance (' .. type(self.inInstance) .. '): ' .. tostring(self.inInstance))
    XFG:Debug(ObjectName, '  isIPC (' .. type(self.isIPC) .. '): ' .. tostring(self.isIPC))
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

function Event:GetDelta()
    return self.delta
end

function Event:SetDelta(inDelta)
    assert(type(inDelta) == 'number')
    self.delta = inDelta
end

function Event:IsIPC(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isIPC = inBoolean
    end
	return self.isIPC
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