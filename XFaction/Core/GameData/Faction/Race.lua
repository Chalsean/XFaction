local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Race'

XFC.Race = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Race:new()
    local object = XFC.Race.parent.new(self)
    object.__name = ObjectName
    object.faction = nil
    return object
end
--#endregion

--#region Print
function XFC.Race:Print()
    self:ParentPrint()
    if(self:HasFaction()) then self:GetFaction():Print() end
end
--#endregion

--#region Accessors
function XFC.Race:HasFaction()
    return self.faction ~= nil
end

function XFC.Race:GetFaction()
    return self.faction
end

function XFC.Race:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end
--#endregion