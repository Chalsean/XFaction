local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Confederate'
local LogCategory = 'O' .. ObjectName

Confederate = {}

function Confederate:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Key = nil
        self._Name = nil
        self._Units = {}
        self._NumberOfUnits = 0
        self._Teams = {}
        self._NumberOfTeams = 0
        self._Realms = {}
        self._NumberOfRealms = 0
        self._Guilds = {}
        self._NumberOfGuilds = 0        
    end

    return Object
end

function Confederate:Print(inPrintOffline)    
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Confederate Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _NumberOfTeams (" .. type(self._NumberOfTeams) .. "): ".. tostring(self._NumberOfTeams))
    CON:Debug(LogCategory, "  _NumberOfRealms (" .. type(self._NumberOfRealms) .. "): ".. tostring(self._NumberOfRealms))
    CON:Debug(LogCategory, "  _NumberOfGuilds (" .. type(self._NumberOfGuilds) .. "): ".. tostring(self._NumberOfGuilds))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Units (" .. type(self._Units) .. "): ")
    for _Key, _Unit in pairs (self._Units) do
        if(inPrintOffline == true or _Unit:IsOnline()) then    
            _Unit:Print()
        end
    end
end

function Confederate:ShallowPrint()
    CON:DoubleLine(LogCategory)
    CON:Debug(LogCategory, "Confederate Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _NumberOfTeams (" .. type(self._NumberOfTeams) .. "): ".. tostring(self._NumberOfTeams))
    CON:Debug(LogCategory, "  _NumberOfRealms (" .. type(self._NumberOfRealms) .. "): ".. tostring(self._NumberOfRealms))
    CON:Debug(LogCategory, "  _NumberOfGuilds (" .. type(self._NumberOfGuilds) .. "): ".. tostring(self._NumberOfGuilds))
    CON:Debug(LogCategory, "  _NumberOfUnits (" .. type(self._NumberOfUnits) .. "): ".. tostring(self._NumberOfUnits))
    CON:Debug(LogCategory, "  _Teams (" .. type(self._Teams) .. ")")
    for _Key, _Team in pairs (self._Teams) do
        _Team:Print(true)
    end
end

function Confederate:GetKey()
    return self._Key
end

function Confederate:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Confederate:GetName()
    return self._Name
end

function Confederate:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Confederate:ContainsUnit(inKey)
    assert(type(inKey) == 'string')
    return self._Units[inKey] ~= nil
end

function Confederate:AddUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name ~= nil and inUnit.__name == 'Unit', "argument must be Unit object")

    if(self:ContainsUnit(inUnit:GetKey()) == false) then
        self._Units[inUnit:GetKey()] = inUnit
        self._NumberOfUnits = self._NumberOfUnits + 1
    end

    local _Team = nil
    if(self:ContainsTeam(inUnit:GetTeamName())) then
        _Team = self:GetTeam(inUnit:GetTeamName())
    else
        _Team = Team:new()
        _Team:SetName(inUnit:GetTeamName())
        _Team:SetKey(inUnit:GetTeamName())        
        self:AddTeam(_Team)
    end
    if(inUnit:IsOnline()) then
        self._Teams[inUnit:GetTeamName()][inUnit:GetKey()] = inUnit
        --_Team:AddUnit(inUnit)
    end

    -- local _Realm = nil
    -- if(self:ContainsRealm(inUnit:GetRealmName())) then
    --     _Realm = self:GetRealm(inUnit:GetRealmName())
    -- else
    --     _Realm = Realm:new()
    --     _Realm:SetName(inUnit:GetRealmName())
    --     _Realm:SetKey(inUnit:GetRealmName())        
    --     self:AddRealm(_Realm)
    -- end
    -- _Realm:AddUnit(inUnit)

    -- local _Guild = nil
    -- if(self:ContainsGuild(inUnit:GetGuildName())) then
    --     _Guild = self:GetGuild(inUnit:GetGuildName())
    -- else
    --     _Guild = Guild:new()
    --     _Guild:SetName(inUnit:GetGuildName())
    --     _Guild:SetKey(inUnit:GetGuildName())
    --     self:AddGuild(_Guild)
    -- end
    -- _Guild:AddUnit(inUnit)

    return self:ContainsUnit(inUnit:GetKey())
end

function Confederate:ContainsTeam(inKey)
    assert(type(inKey) == 'string')
    return self._Teams[inKey] ~= nil
end

function Confederate:AddTeam(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name ~= nil and inTeam.__name == 'Team', "argument must be Team object")

    if(self:ContainsTeam(inTeam:GetKey()) == false) then
        self._Teams[inTeam:GetKey()] = {}
        --self._Teams[inTeam:GetKey()] = inTeam
        self._NumberOfTeams = self._NumberOfTeams + 1
    end

    return self:ContainsTeam(inTeam:GetKey())
end

function Confederate:GetTeam(inKey)
    assert(type(inKey) == 'string')
    return self._Teams[inKey]
end

function Confederate:PrintTeam(inKey, inPrintOffline)
    -- if(inKey ~= nil and self:ContainsTeam(inKey)) then
    --     local _Team = self:GetTeam(inKey)
    --     _Team:Print(inPrintOffline)
    -- elseif(inKey == nil) then
    --     for _Key, _Team in pairs (self._Teams) do
    --         _Team:Print(inPrintOffline)
    --     end
    -- end
    CON:DataDumper(LogCategory, self._Teams)
end

function Confederate:ContainsRealm(inKey)
    assert(type(inKey) == 'string')
    return self._Realms[inKey] ~= nil
end

function Confederate:AddRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")

    if(self:ContainsRealm(inRealm:GetKey()) == false) then
        self._Realms[inRealm:GetKey()] = inRealm
        self._NumberOfRealms = self._NumberOfRealms + 1
    end

    return self:ContainsRealm(inRealm:GetKey())
end

function Confederate:GetRealm(inKey)
    assert(type(inKey) == 'string')
    return self._Realms[inKey]
end

function Confederate:ContainsGuild(inKey)
    assert(type(inKey) == 'string')
    return self._Guilds[inKey] ~= nil
end

function Confederate:AddGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', "argument must be Guild object")

    if(self:ContainsGuild(inGuild:GetKey()) == false) then
        self._Guilds[inGuild:GetKey()] = inGuild
        self._NumberOfGuilds = self._NumberOfGuilds + 1
    end

    return self:ContainsGuild(inGuild:GetKey())
end

function Confederate:GetGuild(inKey)
    assert(type(inKey) == 'string')
    return self._Guilds[inKey]
end