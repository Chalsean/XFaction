local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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
    object.targetCount = 1
    return object
end

function XFC.Target:Deconstructor()
    self:ParentDeconstructor()
    self.realm = nil
    self.faction = nil
    self.targetCount = 1
end
--#endregion

--#region Print
function XFC.Target:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  targetCount (' .. type(self.targetCount) .. '): ' .. tostring(self.targetCount))
    if(self:HasRealm()) then self:GetRealm():Print() end
    if(self:HasFaction()) then self:GetFaction():Print() end
end
--#endregion

--#region Accessors
function XFC.Target:HasRealm()
    return self.realm ~= nil
end

function XFC.Target:GetRealm()
    return self.realm
end

function XFC.Target:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
end

function XFC.Target:HasFaction()
    return self.faction ~= nil
end


function XFC.Target:GetFaction()
    return self.faction
end

function XFC.Target:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end

function XFC.Target:IsMyTarget()
    return XF.Player.Target:Equals(self)
end

function XFC.Target:GetTargetCount()
    return self.targetCount
end

function XFC.Target:IncrementTargetCount()
    self.targetCount = self.targetCount + 1
end
--#endregion

--#region Serialization
function XFC.Target:Serialize()
    return self:GetTarget():GetRealm():GetID() .. '-' .. self:GetTarget():GetFaction():GetKey()
end

function XFC.Target:Deserialize(inSerialized)
    assert(type(inSerialized) == 'string')
    local data = string.Split(inSerialized, ':')
    self:SetRealm(XFO.Realms:GetByID(tonumber(data[1])))
    self:SetFaction(XFO.Factions:Get(data[2]))
end
--#endregion