local XF, G = unpack(select(2, ...))
local ObjectName = 'Node'

Node = Object:newChildConstructor()

--#region Constructors
function Node:new()
    local object = Node.parent.new(self)
    object.__name = ObjectName
    object.target = nil
    object.linkCount = 0
    return object
end

function Node:Deconstructor()
    self:ParentDeconstructor()
    self.target = nil
    self.linkCount = 0
end
--#endregion

--#region Initializers
function Node:Initialize()
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
function Node:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  linkCount (' .. type(self.linkCount) .. '): ' .. tostring(self.linkCount))
    if(self:HasTarget()) then self:GetTarget():Print() end
end
--#endregion

--#region Accessors
function Node:IsMyNode()
    return self:GetName() == XF.Player.Unit:GetName()
end

function Node:HasTarget()
    return self.target ~= nil
end

function Node:GetTarget()
    return self.target
end

function Node:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    self.target = inTarget
end

function Node:GetString()
    return self:GetName() .. ':' .. self:GetTarget():GetRealm():GetID() .. ':' .. self:GetTarget():GetFaction():GetKey()
end

function Node:GetLinkCount()
    return self.linkCount
end

function Node:SetLinkCount(inLinkCount)
    assert(type(inLinkCount) == 'number')
    self.linkCount = inLinkCount
end

function Node:IncrementLinkCount()
    self.linkCount = self.linkCount + 1
end

function Node:DecrementLinkCount()
    self.linkCount = self.linkCount - 1
    if(self:GetLinkCount() == 0) then
        XF.Nodes:Remove(self)
    end
end
--#endregion