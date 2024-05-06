local XF, G = unpack(select(2, ...))
local ObjectName = 'Hook'

Hook = Object:newChildConstructor()

--#region Constructors
function Hook:new()
    local object = Hook.parent.new(self)
    object.__name = ObjectName
    object.original = nil
    object.originalFunction = nil
    object.callback = nil
    object.isEnabled = false
    object.isPreHook = false
    return object
end
--#endregion

--#region Print
function Hook:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  original (' .. type(self.original) .. '): ' .. tostring(self.original))
    XF:Debug(ObjectName, '  originalFunction (' .. type(self.originalFunction) .. '): ' .. tostring(self.originalFunction))
    XF:Debug(ObjectName, '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
    XF:Debug(ObjectName, '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    XF:Debug(ObjectName, '  isPreHook (' .. type(self.isPreHook) .. '): ' .. tostring(self.isPreHook))
end
--#endregion

--#region Accessors
function Hook:HasOriginal()
    return self.original ~= nil
end

function Hook:GetOriginal()
    return self.original
end

function Hook:GetOriginalFunction()
    return self.originalFunction
end

function Hook:SetOriginal(inOriginal)
    assert(type(inOriginal) == 'string')
    self.original = inOriginal
    self.originalFunction = _G[inOriginal]
end

function Hook:HasCallback()
    return self.callback ~= nil
end

function Hook:GetCallback()
    return self.callback
end

function Hook:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self.callback = inCallback
end

function Hook:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function Hook:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isEnabled = inBoolean
    end
	return self.isEnabled
end

function Hook:IsPreHook(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self.isPreHook = inBoolean
    end
	return self.isPreHook
end
--#endregion

--#region Start/Stop
function Hook:Start()
    if(self:HasOriginal() and self:HasCallback()) then
        local callback = self:GetCallback()
        local original = self:GetOriginalFunction()
        if(self:IsPreHook()) then    
            _G[self:GetOriginal()] = function(...)
                callback(...)
                original(...)
            end            
        else
            hooksecurefunc(_G, self:GetOriginal(), callback)
        end
        self:IsEnabled(true)
        XF:Debug(ObjectName, 'Started hook [%s]', self:GetKey())
    end
end

function Hook:Stop()
    if(self:HasOriginal() and self:IsEnabled()) then
        _G[self:GetOriginal()] = self:GetOriginalFunction()
        self:IsEnabled(false)
        XF:Debug(ObjectName, 'Stopped hook [%s]', self:GetKey())
    end
end
--#endregion