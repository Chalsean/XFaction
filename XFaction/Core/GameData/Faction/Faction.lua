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

--#region Initializers
function XFC.Faction:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:GetName() ~= nil) then
            if(self.name == 'Horde') then
                self:SetIconID(XF.Icons.Horde)
                self:SetLanguage('Orcish')
                self:SetID('H')
            elseif(self:GetName() == 'Alliance') then
                self:SetIconID(XF.Icons.Alliance)
                self:SetLanguage('Common')
                self:SetID('A')
            else
                self:SetIconID(XF.Icons.Neutral)
                self:SetLanguage('Common')
                self:SetID('N')
            end
        end
        self:IsInitialized(true)
    end
end
--#endregion

--#region Print
function XFC.Faction:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    XF:Debug(self:GetObjectName(), '  language (' .. type(self.language) .. '): ' .. tostring(self.language))
end
--#endregion

--#region Accessors
function XFC.Faction:GetIconID()
    return self.iconID
end

function XFC.Faction:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end

function XFC.Faction:GetLanguage()
    return self.language
end

function XFC.Faction:SetLanguage(inLanguage)
    assert(type(inLanguage) == 'string')
    self.language = inLanguage
end
--#endregion