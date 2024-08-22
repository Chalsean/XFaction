local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Faction'

XFC.Faction = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Faction:new()
    local object = XFC.Faction.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.language = nil
    return object
end
--#endregion

--#region Properties
function XFC.Faction:IconID(inIconID)
    assert(type(inIconID) == 'number' or inIconID == nil, 'argument must be number or nil')
    if(inIconID ~= nil) then
        self.iconID = inIconID
    end
    return self.iconID
end

function XFC.Faction:Language(inLanguage)
    assert(type(inLanguage) == 'string' or inLanguage == nil, 'argument must be string or nil')
    if(inLanguage ~= nil) then
        self.language = inLanguage
    end
    return self.language
end

function XFC.Faction:IsAlliance()
    return self:Name() == 'Alliance'
end

function XFC.Faction:IsHorde()
    return self:Name() == 'Horde'
end

function XFC.Faction:IsNeutral()
    return self:Name() == 'Neutral'
end
--#endregion

--#region Methods
function XFC.Faction:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    XF:Debug(self:ObjectName(), '  language (' .. type(self.language) .. '): ' .. tostring(self.language))
end

function XFC.Faction:GetHex()
    return self:IsHorde() and 'E0000D' or '378DEF'
end
--#endregion