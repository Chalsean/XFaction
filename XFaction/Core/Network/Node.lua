local XFG, G = unpack(select(2, ...))
local ObjectName = 'LinkNode'
local LogCategory = 'NLinkNode'

LinkNode = {}

function LinkNode:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Name = nil
    self._Realm = nil
    self._Faction = nil
    self._Initialized = false

    return _Object
end

function LinkNode:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function LinkNode:Initialize(inString)
    if(not self:IsInitialized()) then
        assert(type(inString) == 'string')
        local _Parts = string.Split(':', inString)
        self:SetKey(_Parts[1])
        self:SetName(_Parts[1])
        self:SetRealm(XFG.Realms:GetRealmByID(_Parts[2]))
        self:SetFaction(XFG.Factions:GetFaction(_Parts[3]))
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function LinkNode:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    self._Realm:Print()
    self._Faction:Print()
end

function LinkNode:GetKey()
    return self._Key
end

function LinkNode:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function LinkNode:IsMyNode()
    return self:GetName() == XFG.Player.Unit:GetName()
end

function LinkNode:GetName()
    return self._Name
end

function LinkNode:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function LinkNode:GetRealm()
    return self._Realm
end

function LinkNode:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._Realm = inRealm
    return self:GetRealm()
end

function LinkNode:GetFaction()
    return self._Faction
end

function LinkNode:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function LinkNode:IsNodeForTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    return inTarget:GetRealm():Equals(self:GetRealm()) and inTarget:GetFaction():Equals(self:GetFaction())
end

function LinkNode:GetString()
    return self:GetName() .. ':' .. 
           self:GetRealm():GetID() .. ':' .. 
           self:GetFaction():GetID()
end