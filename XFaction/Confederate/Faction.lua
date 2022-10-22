local XFG, G = unpack(select(2, ...))
local ObjectName = 'Faction'

Faction = Object:newChildConstructor()

--#region Constructors
function Faction:new()
    local object = Faction.parent.new(self)
    object.__name = ObjectName
    object.ID = nil
    object.iconID = nil
    object.language = nil
    return object
end
--#endregion

--#region Initializers
function Faction:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        if(self:GetName() ~= nil) then
            if(self.name == 'Horde') then
                self:SetIconID(XFG.Icons.Horde)
                self:SetLanguage('Orcish')
                self:SetID('H')
            elseif(self:GetName() == 'Alliance') then
                self:SetIconID(XFG.Icons.Alliance)
                self:SetLanguage('Common')
                self:SetID('A')
            else
                self:SetIconID(XFG.Icons.Neutral)
                self:SetLanguage('Common')
                self:SetID('N')
            end
        end
        self:IsInitialized(true)
    end
end
--#endregion

--#region Print
function Faction:Print()
    if(XFG.Verbosity) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
        XFG:Debug(ObjectName, '  language (' .. type(self.language) .. '): ' .. tostring(self.language))
    end
end
--#endregion

--#region Accessors
function Faction:GetID()
    return self.ID
end

function Faction:SetID(inID)
    assert(type(inID) == 'string')
    self.ID = inID
end

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