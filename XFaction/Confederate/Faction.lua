local XFG, G = unpack(select(2, ...))
local ObjectName = 'Faction'

local Functions = {
    LogDebug = XFG.Debug,    
}

Faction = Object:newChildConstructor()

function Faction:new()
    local _Object = Faction.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = nil
    _Object._IconID = nil
    _Object._Language = nil
    return _Object
end

function Faction:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:GetName() ~= nil) then
            if(self._Name == 'Horde') then
                self:SetIconID(463451)
                self:SetLanguage('Orcish')
                self:SetID('H')
            elseif(self:GetName() == 'Alliance') then
                self:SetIconID(2565243)
                self:SetLanguage('Common')
                self:SetID('A')
            else
                self:SetIconID(132311)
                self:SetLanguage('Common')
                self:SetID('N')
            end
        end
        self:IsInitialized(true)
    end
end

function Faction:Print()
    self:ParentPrint()
    Functions.LogDebug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
    Functions.LogDebug(ObjectName, '  _IconID (' .. type(self._IconID) .. '): ' .. tostring(self._IconID))
end

function Faction:GetID()
    return self._ID
end

function Faction:SetID(inID)
    assert(type(inID) == 'string')
    self._ID = inID
    return self:GetID()
end

function Faction:GetIconID()
    return self._IconID
end

function Faction:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self._IconID = inIconID
    return self:GetIconID()
end

function Faction:GetLanguage()
    return self._Language
end

function Faction:SetLanguage(inLanguage)
    assert(type(inLanguage) == 'string')
    self._Language = inLanguage
    return self:GetLanguage()
end
