local XFG, G = unpack(select(2, ...))
local ObjectName = 'Guild'
local LogCategory = 'CGuild'

Guild = {}

function Guild:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil
    self._Name = nil
    self._ShortName = nil
    self._Faction = nil
    self._Realm = nil
    self._Initialized = false

    return _Object
end

function Guild:IsInitialized(inInitialized)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function Guild:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
        self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function Guild:Print()
    XFG:DoubleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _ShortName (" .. type(self._ShortName) .. "): ".. tostring(self._ShortName))
    XFG:Debug(LogCategory, "  _Faction (" .. type(self._Faction) .. ")")
    self._Faction:Print()
    XFG:Debug(LogCategory, "  _Realm (" .. type(self._Realm) .. ")")
    self._Realm:Print()
end

function Guild:GetKey()
    return self._Key
end

function Guild:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Guild:GetID()
    return self._ID
end

function Guild:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Guild:GetName()
    return self._Name
end

function Guild:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Guild:GetShortName()
    return self._ShortName
end

function Guild:SetShortName(inShortName)
    assert(type(inShortName) == 'string')
    self._ShortName = inShortName
    return self:GetShortName()
end

function Guild:GetFaction()
    return self._Faction
end

function Guild:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function Guild:GetRealm()
    return self._Realm
end

function Guild:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._Realm = inRealm
    return self:GetRealm()
end

function Guild:Equals(inGuild)
    if(inGuild == nil) then return false end
    if(type(inGuild) ~= 'table' or inGuild.__name == nil or inGuild.__name ~= 'Guild') then return false end
    if(self:GetKey() ~= inGuild:GetKey()) then return false end
    return true
end