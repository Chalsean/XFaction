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
    self._Realm = nil
    self._Faction = nil
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

function Node:Initialize(inString)
    if(not self:IsInitialized()) then
        assert(type(inString) == 'string')
        local _Parts = string.Split(inString, ':')
        self:SetKey(_Parts[1])
        self:SetName(_Parts[1])
        self:SetRealm(XFG.Realms:GetRealmByID(tonumber(_Parts[2])))
        self:SetFaction(XFG.Factions:GetFaction(tonumber(_Parts[3])))
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
    self._Realm:Print()
    self._Faction:Print()
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

function Node:GetRealm()
    return self._Realm
end

function Node:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._Realm = inRealm
    return self:GetRealm()
end

function Node:GetFaction()
    return self._Faction
end

function Node:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function Node:IsNodeForTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    return inTarget:GetRealm():Equals(self:GetRealm()) and inTarget:GetFaction():Equals(self:GetFaction())
end

function Node:GetString()
    return self:GetName() .. ':' .. 
           self:GetRealm():GetID() .. ':' .. 
           self:GetFaction():GetID()
end

function Node:GetLinkCount()
    return self._LinkCount
end

function Node:SetLinkCount(inLinkCount)
    assert(type(inLinkCount) == 'number')
    self._LinkCount = inLinkCount
    return self:GetLinkCount()
end