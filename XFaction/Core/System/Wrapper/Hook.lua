local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Hook'

XFC.Hook = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Hook:new()
    local object = XFC.Hook.parent.new(self)
    object.__name = ObjectName
    object.original = nil
    object.originalFunction = nil
    object.callback = nil
    object.isEnabled = false
    object.isPreHook = false
    return object
end
--#endregion

--#region Properties
function XFC.Hook:Original(inOriginal)
    assert(type(inOriginal) == 'string' or inOriginal == nil)
    if(inOriginal ~= nil) then
        self.original = inOriginal
        self.originalFunction = _G[inOriginal]
    end
    return self.original
end

function XFC.Hook:Callback(inCallback)
    assert(type(inCallback) == 'function' or inCallback == nil)
    if(inCallback ~= nil) then
        self.callback = inCallback
    end
    return self.callback
end

function XFC.Hook:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function XFC.Hook:IsPreHook(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean')
    if(inBoolean ~= nil) then
        self.isPreHook = inBoolean
    end
	return self.isPreHook
end
--#endregion

--#region Methods
function XFC.Hook:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  original (' .. type(self.original) .. '): ' .. tostring(self.original))
    XF:Debug(self:ObjectName(), '  originalFunction (' .. type(self.originalFunction) .. '): ' .. tostring(self.originalFunction))
    XF:Debug(self:ObjectName(), '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XF:Debug(self:ObjectName(), '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XF:Debug(self:ObjectName(), '  isPreHook (' .. type(self.isPreHook) .. '): ' .. tostring(self.isPreHook))
end

function XFC.Hook:HasOriginal()
    return self.original ~= nil
end

function XFC.Hook:GetOriginalFunction()
    return self.originalFunction
end

function XFC.Hook:HasCallback()
    return self.callback ~= nil
end

function XFC.Hook:Start()
    if(self:HasOriginal() and self:HasCallback()) then
        local callback = self:Callback()
        local original = self:GetOriginalFunction()
        if(self:IsPreHook()) then    
            _G[self:Original()] = function(...)
                callback(...)
                original(...)
            end            
        else
            hooksecurefunc(_G, self:Original(), callback)
        end
        self:IsEnabled(true)
        XF:Debug(self:ObjectName(), 'Started hook [%s]', self:Key())
    end
end

function XFC.Hook:Stop()
    if(self:HasOriginal() and self:IsEnabled()) then
        _G[self:Original()] = self:GetOriginalFunction()
        self:IsEnabled(false)
        XF:Debug(self:ObjectName(), 'Stopped hook [%s]', self:Key())
    end
end
--#endregion