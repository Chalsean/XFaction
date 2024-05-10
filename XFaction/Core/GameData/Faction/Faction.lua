local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Faction'

Faction = XFC.Object:newChildConstructor()

--#region Constructors
function Faction:new()
    local object = Faction.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.language = nil
    return object
end
--#endregion

--#region Initializers
function Faction:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:Name() ~= nil) then
            if(self.name == 'Horde') then
                self:SetIconID(XF.Icons.Horde)
                self:SetLanguage('Orcish')
                self:ID('H')
            elseif(self:Name() == 'Alliance') then
                self:SetIconID(XF.Icons.Alliance)
                self:SetLanguage('Common')
                self:ID('A')
            else
                self:SetIconID(XF.Icons.Neutral)
                self:SetLanguage('Common')
                self:ID('N')
            end
        end
        self:IsInitialized(true)
    end
end
--#endregion

--#region Print
function Faction:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    XF:Debug(ObjectName, '  language (' .. type(self.language) .. '): ' .. tostring(self.language))
end
--#endregion

--#region Accessors
function Faction:GetIconID()
    return self.iconID
end

function Faction:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end

function Faction:GetLanguage()
    return self.language
end

function Faction:SetLanguage(inLanguage)
    assert(type(inLanguage) == 'string')
    self.language = inLanguage
end
--#endregion