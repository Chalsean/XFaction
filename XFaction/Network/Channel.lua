local XFG, G = unpack(select(2, ...))

Channel = Object:newChildConstructor()

function Channel:new()
    local _Object = Channel.parent.new(self)
    _Object.__name = 'Channel'
    _Object._ID = nil
    _Object._Password = nil
    return _Object
end

function Channel:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(self:GetObjectName(), "  _Password (" ..type(self._Password) .. "): ".. tostring(self._Password))
end

function Channel:GetID()
    return self._ID
end

function Channel:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Channel:GetPassword()
    return self._Password
end

function Channel:SetPassword(inPassword)
    assert(type(inPassword) == 'string')
    self._Password = inPassword
    return self:GetPassword()
end