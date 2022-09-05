local XFG, G = unpack(select(2, ...))
local ObjectName = 'Node'

Node = Object:newChildConstructor()

function Node:new()
    local object = Node.parent.new(self)
    object.__name = ObjectName
    object.target = nil
    object.linkCount = 0
    return object
end

function Node:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:SetKey(XFG.Player.Unit:GetName())
        self:SetName(XFG.Player.Unit:GetName())
        self:SetTarget(XFG.Player.Target)
        self:IsInitialized(true)
    end
end

function Node:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  linkCount (' .. type(self.linkCount) .. '): ' .. tostring(self.linkCount))
        if(self:HasTarget()) then self:GetTarget():Print() end
    end
end

function Node:IsMyNode()
    return self:GetName() == XFG.Player.Unit:GetName()
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
        XFG.Nodes:Remove(self)
    end
end

function Node:FactoryReset()
    self:ParentFactoryReset()
    self.target = nil
    self.linkCount = 0
end