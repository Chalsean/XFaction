local XFG, G = unpack(select(2, ...))
local ObjectName = 'Covenant'

Covenant = Object:newChildConstructor()

function Covenant:new()
    local _Object = Covenant.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = 0
    _Object._SoulbindIDs = {}
    _Object._IconID = nil
    return _Object
end

function Covenant:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        local _CovenantInfo = C_Covenants.GetCovenantData(self._ID)
        self:SetKey(_CovenantInfo.ID)
        self:SetID(_CovenantInfo.ID)
        self:SetName(_CovenantInfo.name)
        self._SoulbindIDs = _CovenantInfo.soulbindIDs
        self:SetIconID(XFG.Icons[self:GetName()])
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Covenant:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        for _Index, _SoulbindID in PairsByKeys (self._SoulbindIDs) do
            XFG:Debug(ObjectName, '  _SoulbindID[' .. tostring(_Index) .. '] (' .. type(_SoulbindID) .. '): ' .. tostring(_SoulbindID))
        end
    end
end

function Covenant:GetID()
    return self._ID
end

function Covenant:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Covenant:GetIconID()
    return self._IconID
end

function Covenant:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Covenant:SoulbindIterator()
    return next, self._SoulbindIDs, nil
end