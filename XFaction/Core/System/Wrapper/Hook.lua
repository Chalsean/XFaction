local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Hook'

XFC.Hook = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Hook:new()
    local object = XFC.Hook.parent.new(self)
    object.__name = ObjectName
    object.originalFunction = nil
    object.callback = nil
    object.isEnabled = false
    object.isPreHook = false
    return object
end
--#endregion

--#region Properties
function XFC.Hook:OriginalFunction(inFunction)
    assert(type(inFunction) == 'function' or inFunction == nil, 'argument must be function or nil')
    if(inFunction ~= nil) then
        self.originalFunction = inFunction
    end
    return self.originalFunction
end

function XFC.Hook:Callback(inCallback)
    assert(type(inCallback) == 'function' or inCallback == nil, 'argument must be function or nil')
    if(inCallback ~= nil) then
        self.callback = inCallback
    end
    return self.callback
end

function XFC.Hook:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function XFC.Hook:IsPreHook(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isPreHook = inBoolean
    end
	return self.isPreHook
end
--#endregion

--#region Methods
function XFC.Hook:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  originalFunction (' .. type(self.originalFunction) .. '): ' .. tostring(self.originalFunction))
    XF:Debug(self:ObjectName(), '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XF:Debug(self:ObjectName(), '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XF:Debug(self:ObjectName(), '  isPreHook (' .. type(self.isPreHook) .. '): ' .. tostring(self.isPreHook))
end

function XFC.Hook:Start()
    local callback = self:Callback()
    local original = self:OriginalFunction()
    if(self:IsPreHook()) then    
        _G[self:Name()] = function(...)
            callback(...)
            original(...)
        end            
    else
        hooksecurefunc(_G, self:Name(), callback)
    end
    self:IsEnabled(true)
    XF:Debug(self:ObjectName(), 'Started hook [%s]', self:Key())
end

function XFC.Hook:Stop()
    if(self:IsEnabled()) then
        _G[self:Name()] = self:OriginalFunction()
        self:IsEnabled(false)
        XF:Debug(self:ObjectName(), 'Stopped hook [%s]', self:Key())
    end
end
--#endregion