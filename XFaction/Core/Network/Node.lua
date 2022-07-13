local XFG, G = unpack(select(2, ...))
local ObjectName = 'Node'
local LogCategory = 'NNode'

Node = {}

function Node:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Target = nil
    self._Initialized = false
    self._LinkCount = 0

    return _Object
end

function Node:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Node:Initialize()
    if(self:IsInitialized() == false) then
        if(self:GetName() ~= nil and self:GetKey() == nil) then
            self:SetKey(self:GetName())
        end
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Node:MyInitialize()
    if(self:IsInitialized() == false) then
        self:SetKey(XFG.Player.Unit:GetName())
        self:SetName(XFG.Player.Unit:GetName())
        self:SetTarget(XFG.Player.Target)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Node:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _LinkCount (" .. type(self._LinkCount) .. "): ".. tostring(self._LinkCount))
    if(self:HasTarget()) then
        self:GetTarget():Print()
    end
end

function Node:GetKey()
    return self._Key
end

function Node:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Node:IsMyNode()
    return self:GetName() == XFG.Player.Unit:GetName()
end

function Node:GetName()
    return self._Name
end

function Node:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
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
    return self:GetName() .. ':' .. self:GetTarget():GetRealm():GetID() .. ':' .. self:GetTarget():GetFaction():GetID()
end

function Node:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')    

    local _Node = string.Split(inLinkString, ':')  
    self:SetName(_Node[1])
    local _Realm = XFG.Realms:GetRealmByID(tonumber(_Node[2]))
    local _Faction = XFG.Factions:GetFaction(tonumber(_Node[3]))
    self:SetTarget(XFG.Targets:GetTarget(_Realm, _Faction))
    self:Initialize()

    return self:IsInitialized()
end

function Node:Equals(inNode)
    if(inNode == nil) then return false end
    if(type(inNode) ~= 'table' or inNode.__name == nil or inNode.__name ~= 'Node') then return false end
    if(self:GetKey() ~= inNode:GetKey()) then return false end
    return true
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