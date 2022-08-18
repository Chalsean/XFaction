local XFG, G = unpack(select(2, ...))
local ObjectName = 'Profession'

Profession = Object:newChildConstructor()

function Profession:new()
    local _Object = Profession.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = 0
    _Object._IconID = nil
    return _Object
end

function Profession:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        XFG:Debug(ObjectName, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
    end
end

function Profession:GetID()
    return self._ID
end

function Profession:SetID(inProfessionID)
    assert(type(inProfessionID) == 'number')
    self._ID = inProfessionID
end

function Profession:GetIconID()
    return self._IconID
end

function Profession:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
end