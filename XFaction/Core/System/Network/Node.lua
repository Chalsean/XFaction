local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Node'

XFC.Node = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Node:new()
    local object = XFC.Node.parent.new(self)
    object.__name = ObjectName
    object.target = nil
    object.links = nil
    return object
end

function XFC.Node:Deconstructor()
    self:ParentDeconstructor()
    self.target = nil
    self.links:Deconstructor()
    self.links = nil
end

function XFC.Node:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:Key(XF.Player.Unit:Name())
        self:Name(XF.Player.Unit:Name())
        self:Target(XF.Player.Target)
        self.links = XFC.ObjectCollection:new()
        self.links:Initialize()
        self:IsInitialized(true)
    end
end
--#endregion

--#region Properties
function XFC.Node:Target(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil, 'Target property requires Target object for set or nil for get')
    if(inTarget ~= nil) then
        self.target = inTarget
    end
    return self.target
end

function XFC.Node:Links()
    return self.links
end
--#endregion

--#region Methods
function XFC.Node:AddLink(inLink)
    assert(type(inLink) == 'table' and inLink.__name == 'Node')
    self:Links():Add(inLink)
end

function XFC.Node:RemoveLink(inKey)
    assert(type(inKey) == 'string')
    self:Links():Remove(inKey)
end

function XFC.Node:GetLink(inKey)
    assert(type(inKey) == 'string')
    return self:Links():Get(inKey)
end

function XFC.Node:ContainsLink(inKey)
    assert(type(inKey) == 'string')
    return self:Links():Contains(inKey)
end

function XFC.Node:Print()
    self:ParentPrint()
    if(self:HasTarget()) then self:Target():Print() end
end

function XFC.Node:IsMyNode()
    return self:Name() == XF.Player.Unit:Name() and self:Target():Equals(XF.Player.Target)
end

function XFC.Node:HasTarget()
    return self.target ~= nil
end

function XFC.Node:Serialize()
    return self:Name() .. ':' .. self:Target():Serialize()
end

function XFC.Node:Deserialize(inNodeString)
    assert(type(inNodeString) == 'string')
    node:Key(nodeData[1])
    node:Name(nodeData[1])
    local realm = XFO.Realms:Get(tonumber(nodeData[2]))
    local faction = XFO.Factions:Get(tonumber(nodeData[3]))
    node:Target(XFO.Targets:Get(realm, faction))
    node:IsInitialized(true)
end
--#endregion