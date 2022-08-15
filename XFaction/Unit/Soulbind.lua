local XFG, G = unpack(select(2, ...))

Soulbind = Object:newChildConstructor()

function Soulbind:new()
    local _Object = Soulbind.parent.new(self)
    _Object.__name = 'Soulbind'
    _Object._ID = nil
    return _Object
end

function Soulbind:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:GetID() ~= nil) then
            local _SoulbindInfo = C_Soulbinds.GetSoulbindData(self:GetID())
            self:SetName(_SoulbindInfo.name)
        end
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Soulbind:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
end

function Soulbind:GetID()
    return self._ID
end

function Soulbind:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end