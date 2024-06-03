local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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
    assert(type(inFunction) == 'function' or inFunction == nil)
    if(inFunction ~= nil) then
        --self.originalFunction = _G[inOriginal]
        self.originalFunction = inFunction
    end
    return self.originalFunction
end

function XFC.Hook:Callback(inFunction)
    assert(type(inFunction) == 'function' or inFunction == nil)
    if(inFunction ~= nil) then
        self.callback = inFunction
    end
    return self.callback
end

function XFC.Hook:IsEnabled(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function XFC.Hook:IsPreHook(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
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

function XFC.Hook:HasOriginalFunction()
    return self:OriginalFunction() ~= nil
end

function XFC.Hook:HasCallback()
    return self:Callback() ~= nil
end

function XFC.Hook:Start()
    if(self:HasOriginalFunction() and self:HasCallback()) then
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
end

function XFC.Hook:Stop()
    if(self:HasOriginalFunction() and self:IsEnabled()) then
        _G[self:Name()] = self:OriginalFunction()
        self:IsEnabled(false)
        XF:Debug(self:ObjectName(), 'Stopped hook [%s]', self:Key())
    end
end
--#endregion