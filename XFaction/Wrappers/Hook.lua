local XFG, G = unpack(select(2, ...))
local ObjectName = 'Hook'

Hook = Object:newChildConstructor()

function Hook:new()
    local _Object = Hook.parent.new(self)
    _Object.__name = ObjectName
    _Object._Original = nil
    _Object._OriginalFunction = nil
    _Object._Callback = nil
    _Object._Enabled = false
    return _Object
end

function Hook:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _Original (' .. type(self._Original) .. '): ' .. tostring(self._Original))
        XFG:Debug(ObjectName, '  _Callback (' .. type(self._Callback) .. '): ' .. tostring(self._Callback))
        XFG:Debug(ObjectName, '  _Enabled (' .. type(self._Enabled) .. '): ' .. tostring(self._Enabled))
    end
end

function Hook:HasOriginal()
    return self._Original ~= nil
end

function Hook:GetOriginal()
    return self._Original
end

function Hook:GetOriginalFunction()
    return self._OriginalFunction
end

function Hook:SetOriginal(inOriginal)
    assert(type(inOriginal) == 'string')
    self._Original = inOriginal
    self._OriginalFunction = _G[inOriginal]
end

function Hook:HasCallback()
    return self._Callback ~= nil
end

function Hook:GetCallback()
    return self._Callback
end

function Hook:SetCallback(inCallback)
    assert(type(inCallback) == 'function')
    self._Callback = inCallback
end

function Hook:IsEnabled(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Enabled = inBoolean
    end
	return self._Enabled
end

function Hook:Start()
    if(self:HasOriginal() and self:HasCallback()) then
        local _Callback = self:GetCallback()
        local _Original = self:GetOriginalFunction()
        _G[self:GetOriginal()] = function(...)
            _Callback(...)
            _Original(...)
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