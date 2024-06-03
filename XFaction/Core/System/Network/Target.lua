local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Target'

-- A target is a collection of connected realms + faction
-- As long as someone on the target receives, they rebroadcast to local channel
XFC.Target = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Target:new()
    local object = XFC.Target.parent.new(self)
    object.__name = ObjectName
    object.realm = nil
    object.faction = nil
    return object
end
--#endregion

--#region Properties
function XFC.Target:Realm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or inRealm == nil)
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end

function XFC.Target:Faction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil)
    if(inFaction ~= nil) then
        self.faction = inFaction
    end
    return self.faction
end
--#endregion

--#region Methods
function XFC.Target:Print()
    self:ParentPrint()
    if(self:HasRealm()) then self:Realm():Print() end
    if(self:HasFaction()) then self:Faction():Print() end
end

function XFC.Target:HasRealm()
    return self:Realm() ~= nil
end

function XFC.Target:HasFaction()
    return self:Faction() ~= nil
end

function XFC.Target:IsMyTarget()
    return XF.Player.Target:Equals(self)
end

function XFC.Target:Serialize()
    return self:GetRealm():ID() .. ':' .. self:GetFaction():Key()
end

function XFC.Target:IsTarget(inRealm, inFaction)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction')
    return inRealm:Equals(self:GetRealm()) and inFaction:Equals(self:GetFaction())
end
--#endregion