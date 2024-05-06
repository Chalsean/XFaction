local XF, G = unpack(select(2, ...))
local ObjectName = 'Race'

Race = Object:newChildConstructor()

--#region Constructors
function Race:new()
    local object = Race.parent.new(self)
    object.__name = ObjectName
    object.faction = nil
    return object
end
--#endregion

--#region Print
function Race:Print()
    self:ParentPrint()
    if(self:HasFaction()) then self:GetFaction():Print() end
end
--#endregion

--#region Accessors
function Race:HasFaction()
    return self.faction ~= nil
end

function Race:GetFaction()
    return self.faction
end

function Race:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end
--#endregion