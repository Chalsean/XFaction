local XFG, G = unpack(select(2, ...))
local ObjectName = 'Spec'

Spec = Object:newChildConstructor()

function Spec:new()
    local _Object = Spec.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = nil
    _Object._IconID = nil
    return _Object
end

function Spec:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        XFG:Debug(ObjectName, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
    end
end

function Spec:GetID()
    return self._ID
end

function Spec:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Spec:GetIconID()
    return self._IconID
end

function Spec:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end