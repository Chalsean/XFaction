local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Link'

XFC.Link = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Link:new()
    local object = XFC.Link.parent.new(self)
    object.__name = ObjectName
    object.fromTarget = nil
    object.fromName = nil
    object.toTarget = nil
    object.toName = nil
    return object
end

function XFC.Link:Deconstructor()
    self:ParentDeconstructor()
    self.fromTarget = nil
    self.fromName = nil
    self.toTarget = nil
    self.toName = nil
end

function XFC.Link:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        local key = (self:FromName() < self:ToName()) and self:FromName() .. ':' .. self:ToName() or self:ToName() .. ':' .. self:FromName()
        self:Key(key)
        self:IsInitialized(true)
    end
end
--#endregion

--#region Properties
function XFC.Link:FromTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil)
    if(inTarget ~= nil) then
        self.fromTarget = inTarget
    end
    return self.fromTarget
end

function XFC.Link:FromName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.fromName = inName
    end
    return self.fromName
end

function XFC.Link:ToTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil)
    if(inTarget ~= nil) then
        self.toTarget = inTarget
    end
    return self.toTarget
end

function XFC.Link:ToName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.toName = inName
    end
    return self.toName
end
--#endregion

--#region Methods
function XFC.Link:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XF:Debug(self:ObjectName(), '  fromName (' .. type(self.fromName) .. '): ' .. tostring(self.fromName))
    if(self:HasFromTarget()) then self:FromTarget():Print() end
    XF:Debug(self:ObjectName(), '  toName (' .. type(self.toName) .. '): ' .. tostring(self.toName))    
    if(self:HasToTarget()) then self:ToTarget():Print() end
end

function XFC.Link:HasFromTarget()
    return self:FromTarget() ~= nil
end

function XFC.Link:HasToTarget()
    return self:ToTarget() ~= nil
end

function XFC.Link:HasNode(inName, inRealm, inFaction)
    assert(type(inName) == 'string')
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm')
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction')

    if(self:FromName() == inName and self:FromTarget():GetRealm():Equals(inRealm) and self:FromTarget():GetFaction():Equals(inFaction)) then
        return true
    elseif(self:ToName() == inName and self:ToTarget():GetRealm():Equals(inRealm) and self:ToTarget():GetFaction():Equals(inFaction)) then
        return true
    end
    return false
end

function XFC.Link:IsMyLink()
    return self:HasNode(XF.Player.Unit:Name(), XF.Player.Realm, XF.Player.Faction)
end

function XFC.Link:Serialize()
    local from = self:FromName() .. ':' .. self:FromTarget():GetRealm():ID() .. ':' .. self:FromTarget():GetFaction():Key()
    local to = self:ToName() .. ':' .. self:ToTarget():GetRealm():ID() .. ':' .. self:ToTarget():GetFaction():Key()
    return from .. ';' .. to
end

function XFC.Link:Deserialize(inSerial)
    assert(type(inSerial) == 'string')

    local _Nodes = string.Split(inSerial, ';')

    local fromNode = string.Split(_Nodes[1], ':')
    self:FromName(fromNode[1])
    self:FromTarget(XFO.Targets:Get(tonumber(fromNode[2]), tonumber(fromNode[3])))

    local toNode = string.Split(_Nodes[2], ':')
    self:ToName(toNode[1])
    self:ToTarget(XFO.Targets:Get(tonumber(toNode[2]), tonumber(toNode[3])))

    self:Initialize()
end
--#endregion