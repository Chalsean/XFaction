local XFG, G = unpack(select(2, ...))

Target = Object:newChildConstructor()

function Target:new()
    local _Object = Target.parent.new(self)
    _Object.__name = 'Target'
    _Object._Realm = nil
    _Object._Faction = nil
    return _Object
end

function Target:Print()
    self:ParentPrint()
    if(self:HasRealm()) then self:GetRealm():Print() end
    if(self:HasFaction()) then self:GetFaction():Print() end
end

function Target:HasRealm()
    return self._Realm ~= nil
end

function Target:GetRealm()
    return self._Realm
end

function Target:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._Realm = inRealm
    return self:GetRealm()
end

function Target:HasFaction()
    return self._Faction ~= nil
end


function Target:GetFaction()
    return self._Faction
end

function Target:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function Target:IsMyTarget()
    return XFG.Player.Target:Equals(self)
end