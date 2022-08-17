local XFG, G = unpack(select(2, ...))
local ObjectName = 'Node'

Node = Object:newChildConstructor()

function Node:new()
    local _Object = Node.parent.new(self)
    _Object.__name = ObjectName
    _Object._Target = nil
    _Object._LinkCount = 0
    return _Object
end

function Node:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:SetKey(XFG.Player.Unit:GetName())
        self:SetName(XFG.Player.Unit:GetName())
        self:SetTarget(XFG.Player.Target)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Node:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _LinkCount (" .. type(self._LinkCount) .. "): ".. tostring(self._LinkCount))
        if(self:HasTarget()) then self:GetTarget():Print() end
    end
end

function Node:IsMyNode()
    return self:GetName() == XFG.Player.Unit:GetName()
end

function Node:HasTarget()
    return self._Target ~= nil
end

function Node:GetTarget()
    return self._Target
end

function Node:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    self._Target = inTarget
    return self:GetTarget()
end

function Node:GetString()
    return self:GetName() .. ':' .. self:GetTarget():GetRealm():GetID() .. ':' .. self:GetTarget():GetFaction():GetKey()
end

function Node:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')    

    local _Node = string.Split(inLinkString, ':')  
    self:SetKey(_Node[1])
    self:SetName(_Node[1])
    local _Realm = XFG.Realms:GetRealmByID(tonumber(_Node[2]))
    local _Faction = XFG.Factions:GetObject(tonumber(_Node[3]))
    self:SetTarget(XFG.Targets:GetTargetByRealmFaction(_Realm, _Faction))

    return self:IsInitialized(true)
end

function Node:GetLinkCount()
    return self._LinkCount
end

function Node:SetLinkCount(inLinkCount)
    assert(type(inLinkCount) == 'number')
    self._LinkCount = inLinkCount
    return self:GetLinkCount()
end

function Node:IncrementLinkCount()
    self._LinkCount = self._LinkCount + 1
    return self:GetLinkCount()
end

function Node:DecrementLinkCount()
    self._LinkCount = self._LinkCount - 1
    if(self:GetLinkCount() == 0) then
        XFG.Nodes:RemoveNode(self)
    end
    return self:GetLinkCount()
end