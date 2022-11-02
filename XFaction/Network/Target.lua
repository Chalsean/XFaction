local XFG, G = unpack(select(2, ...))
local ObjectName = 'Target'

-- A target is a collection of connected realms + faction
-- As long as someone on the target receives, they rebroadcast to local channel
Target = Object:newChildConstructor()

--#region Constructors
function Target:new()
    local object = Target.parent.new(self)
    object.__name = ObjectName
    object.realm = nil
    object.faction = nil
    return object
end
--#endregion

--#region Print
function Target:Print()
    if(self:ParentPrint()) then
        if(self:HasRealm()) then self:GetRealm():Print() end
        if(self:HasFaction()) then self:GetFaction():Print() end
    end
end
--#endregion

--#region Accessors
function Target:HasRealm()
    return self.realm ~= nil
end

function Target:GetRealm()
    return self.realm
end

function Target:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
    return self:GetRealm()
end

function Target:HasFaction()
    return self.faction ~= nil
end


function Target:GetFaction()
    return self.faction
end

function Target:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
    return self:GetFaction()
end

function Target:IsMyTarget()
    return XFG.Player.Target:Equals(self)
end
--#endregion