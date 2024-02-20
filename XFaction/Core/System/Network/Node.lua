local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Node'

XFC.Node = Object:newChildConstructor()

--#region Constructors
function XFC.Node:new()
    local object = XFC.Node.parent.new(self)
    object.__name = ObjectName
    object.target = nil
    object.linkCount = 0
    return object
end

function XFC.Node:Deconstructor()
    self:ParentDeconstructor()
    self.target = nil
    self.linkCount = 0
end
--#endregion

--#region Initializers
function XFC.Node:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:SetKey(XF.Player.Unit:GetName())
        self:SetName(XF.Player.Unit:GetName())
        self:SetTarget(XF.Player.Target)
        self:IsInitialized(true)
    end
end
--#endregion

--#region Print
function XFC.Node:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  linkCount (' .. type(self.linkCount) .. '): ' .. tostring(self.linkCount))
    if(self:HasTarget()) then self:GetTarget():Print() end
end
--#endregion

--#region Accessors
function XFC.Node:IsMyNode()
    return self:GetName() == XF.Player.Unit:GetName()
end

function XFC.Node:HasTarget()
    return self.target ~= nil
end

function XFC.Node:GetTarget()
    return self.target
end

function XFC.Node:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    self.target = inTarget
end

function XFC.Node:GetLinkCount()
    return self.linkCount
end

function XFC.Node:SetLinkCount(inLinkCount)
    assert(type(inLinkCount) == 'number')
    self.linkCount = inLinkCount
end

function XFC.Node:IncrementLinkCount()
    self.linkCount = self.linkCount + 1
end

function XFC.Node:DecrementLinkCount()
    self.linkCount = self.linkCount - 1
    if(self:GetLinkCount() == 0) then
        XFO.Nodes:Remove(self)
    end
end
--#endregion

--#region Serialization
function XFC.Node:Serialize()
    return self:GetName() .. ':' .. self:GetTarget():Serialize()
end

function XFC.Node:Deserialize(inSerialized)
    assert(type(inSerialized) == 'string')
    local data = string.Split(inSerialized, ':')
    self:SetKey(data[1])
    self:SetName(data[1])
    
    local target = nil
    try(function()
        target = XFO.Targets:Pop()
        target:Deserialize(data[2])
        self:SetTarget(XFO.Targets:Get(target:GetKey()))
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
    end).
    finally(function()
        XFO.Targets:Push(target)
    end)    
end
--#endregion