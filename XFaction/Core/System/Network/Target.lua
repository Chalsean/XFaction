local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Target'

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

--#region Properties
function XFC.Target:Realm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or inRealm == nil, 'argument must be Realm object or nil')
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end

function XFC.Target:Faction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil, 'argument must be Faction object or nil')
    if(inFaction ~= nil) then
        self.faction = inFaction
    end
    return self.faction
end
--#endregion

--#region Methods
function XFC.Target:Print()
    self:ParentPrint()
    if(self:Realm() ~= nil) then self:Realm():Print() end
    if(self:Faction() ~= nil) then self:Faction():Print() end
end

function XFC.Target:IsMyTarget()
    return XF.Player.Target:Equals(self)
end

function XFC.Target:Serialize()
    return self:Realm():ID() .. '-' .. self:Faction():Key()
end

function XFC.Target:Deserialize(inSerialized)
    assert(type(inSerialized) == 'string')
    self:Key(inSerialized)
    local data = string.Split(inSerialized, '-')
    self:Realm(XFO.Realms:Get(tonumber(data[1])))
    self:Faction(XFO.Factions:Get(tonumber(data[2])))
end
--#endregion