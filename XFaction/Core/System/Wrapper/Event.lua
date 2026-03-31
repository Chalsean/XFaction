local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Event'

XFC.Event = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Event:new()
    local object = XFC.Event.parent.new(self)
    object.__name = ObjectName
    object.callback = nil
    object.isEnabled = false
    object.inInstance = false
    object.isRestricted = false
    return object
end
--#endregion

--#region Properties
function XFC.Event:Callback(inCallback)
    assert(type(inCallback) == 'function' or inCallback == nil)
    if(inCallback ~= nil) then
        self.callback = inCallback
    end
    return self.callback
end

function XFC.Event:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function XFC.Event:IsInstance(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.inInstance = inBoolean
    end
	return self.inInstance
end

function XFC.Event:IsRestricted(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRestricted = inBoolean
    end
	return self.isRestricted
end
--#endregion

--#region Methods
function XFC.Event:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XF:Debug(self:ObjectName(), '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XF:Debug(self:ObjectName(), '  inInstance (' .. type(self.inInstance) .. '): ' .. tostring(self.inInstance))
    XF:Debug(self:ObjectName(), '  IsRestricted (' .. type(self.IsRestricted) .. '): ' .. tostring(self.IsRestricted))
end

function XFC.Event:Start()
    if(not self:IsEnabled()) then
        self:IsEnabled(true)
        XF:Debug(self:ObjectName(), 'Started event listener [%s] for [%s]', self:Key(), self:Name())
    end
end

function XFC.Event:Stop()
    if(self:IsEnabled()) then
        self:IsEnabled(false)
        XF:Debug(self:ObjectName(), 'Stopped event listener [%s] for [%s]', self:Key(), self:Name())
    end
end
--#endregion