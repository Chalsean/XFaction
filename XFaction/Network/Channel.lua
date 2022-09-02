local XFG, G = unpack(select(2, ...))
local ObjectName = 'Channel'

Channel = Object:newChildConstructor()

function Channel:new()
    local _Object = Channel.parent.new(self)
    _Object.__name = 'Channel'
    _Object._ID = nil
    _Object._Password = nil
    _Object._Community = false
    return _Object
end

function Channel:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
        XFG:Debug(ObjectName, "  _Community (" ..type(self._Community) .. "): ".. tostring(self._Community))
    end
end

function Channel:GetID()
    return self._ID
end

function Channel:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
end

function Channel:GetPassword()
    return self._Password
end

function Channel:SetPassword(inPassword)
    assert(type(inPassword) == 'string')
    self._Password = inPassword
end

function Channel:IsCommunity(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self._Community = inBoolean
    end
    return self._Community
end