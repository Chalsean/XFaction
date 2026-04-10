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

--#region Properties
function XFC.Race:Faction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil, 'argument must be Faction object or nil')
    if(inFaction ~= nil) then
        self.faction = inFaction
    end
    return self.faction
end
--#endregion

--#region Methods
function XFC.Race:Print()
    self:ParentPrint()
    if(self:Faction() ~= nil) then self:Faction():Print() end
end

function XFC.Race:HasFaction()
    return self:Faction() ~= nil
end
--#endregion