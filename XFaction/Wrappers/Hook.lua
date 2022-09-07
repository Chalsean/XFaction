local XFG, G = unpack(select(2, ...))
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
    return object
end
--#endregion

--#region Print
function Hook:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  original (' .. type(self.original) .. '): ' .. tostring(self.original))
        XFG:Debug(ObjectName, '  originalFunction (' .. type(self.originalFunction) .. '): ' .. tostring(self.originalFunction))
        XFG:Debug(ObjectName, '  callback (' .. type(self.callback) .. '): ' .. tostring(self.callback))
        XFG:Debug(ObjectName, '  isEnabled (' .. type(self.isEnabled) .. '): ' .. tostring(self.isEnabled))
    end
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
--#endregion

--#region Start/Stop
function Hook:Start()
    if(self:HasOriginal() and self:HasCallback()) then
        local callback = self:GetCallback()
        local original = self:GetOriginalFunction()
        _G[self:GetOriginal()] = function(...)
            callback(...)
            original(...)
        end
        self:IsEnabled(true)
        if(XFG.DebugFlag) then
            XFG:Debug(ObjectName, 'Started hook [%s]', self:GetKey())
        end
    end
end

function Hook:Stop()
    if(self:HasOriginal() and self:IsEnabled()) then
        _G[self:GetOriginal()] = self:GetOriginalFunction()
        self:IsEnabled(false)
        if(XFG.DebugFlag) then
            XFG:Debug(ObjectName, 'Stopped hook [%s]', self:GetKey())
        end
    end
end
--#endregion