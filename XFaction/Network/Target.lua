local XFG, G = unpack(select(2, ...))
local ObjectName = 'Target'
local LogCategory = 'NTarget'

Target = {}

function Target:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Realm = nil
    self._Faction = nil

    return _Object
end

function Target:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _Realm (" .. type(self._Realm) .. "): ".. tostring(self._Realm))
    if(self:HasRealm()) then
        self._Realm:Print()
    end
    XFG:Debug(LogCategory, "  _Faction (" .. type(self._Faction) .. "): ".. tostring(self._Faction))
    if(self:HasFaction()) then
        self._Faction:Print()
    end
end

function Target:GetKey()
    return self._Key
end

function Target:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Target:HasRealm()
    return self._Realm ~= nil
end

function Target:GetRealm()
    return self._Realm
end

function Target:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._Realm = inRealm
    return self:GetRealm()
end

function Target:HasFaction()
    return self._Faction ~= nil
end


function Target:GetFaction()
    return self._Faction
end

function Target:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function Target:Equals(inTarget)
    if(inTarget == nil) then return false end
    if(type(inTarget) ~= 'table' or inTarget.__name == nil or inTarget.__name ~= 'Target') then return false end
    if(self:GetKey() ~= inTarget:GetKey()) then return false end
    return true
end