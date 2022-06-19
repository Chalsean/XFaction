local XFG, G = unpack(select(2, ...))
local ObjectName = 'Unit'
local LogCategory = 'UUnit'

Unit = {}

function Unit:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._GUID = nil
    self._UnitName = nil
    self._Name = nil
    self._ID = 0  -- Note player ID is unique to a guild, not globally
    self._Rank = nil
    self._Level = 60
    self._Class = nil
    self._Spec = nil
    self._Zone = nil
    self._Note = nil
    self._Online = false
    self._Status = nil
    self._Mobile = false
    self._Race = nil
    self._TimeStamp = nil
    self._Covenant = nil
    self._Soulbind = nil
    self._Profession1 = nil
    self._Profession2 = nil
    self._DungeonScore = 0
    self._AchievementPoints = 0
    self._RunningAddon = false
    self._Alt = false
    self._MainName = nil
    self._IsPlayer = false
    self._IsOnMainGuild = false
    self._Faction = false
    self._Team = nil
    self._Initialized = false
    self._Guild = nil
    self._Realm = nil

    return Object
end

function Unit:Initialize(inMemberID)
    assert(type(inMemberID) == 'number')
    self:SetGuildIndex(inMemberID)
    local _UnitData = C_Club.GetMemberInfo(XFG.Player.Guild:GetID(), inMemberID)
    if(_UnitData == nil) then return end

    self:SetGUID(_UnitData.guid)
    self:SetKey(self:GetGUID())
    self:IsOnline(_UnitData.presence == 1 or _UnitData.presence == 4 or _UnitData.presence == 5)
    if(self:IsOffline()) then
        return
    end

    self:SetName(_UnitData.name)
    self:SetUnitName(_UnitData.name .. '-' .. XFG.Player.Realm:GetAPIName())
	self:SetLevel(_UnitData.level)	
	self:SetFaction(XFG.Player.Faction)
    self:SetGuild(XFG.Player.Guild)
    self:SetRealm(XFG.Player.Realm)
    self:SetTimeStamp(GetServerTime())
    self:SetClass(XFG.Classes:GetClass(_UnitData.classID))
    self:SetRace(XFG.Races:GetRace(_UnitData.race))

    if(XFG.Ranks:Contains(_UnitData.guildRankOrder) == false) then
        local _NewRank = Rank:new()
        _NewRank:SetKey(_UnitData.guildRankOrder)
        _NewRank:SetID(_UnitData.guildRankOrder)
        _NewRank:SetName(_UnitData.guildRank)
        XFG.Ranks:AddRank(_NewRank)
    end
    self:SetRank(XFG.Ranks:GetRank(_UnitData.guildRankOrder))    
    self:SetNote(_UnitData.memberNote or '?')
    self:IsPlayer(_UnitData.isSelf)
    self:SetDungeonScore(_UnitData.overallDungeonScore or 0)
    self:SetAchievementPoints(_UnitData.achievementPoints or 0)

    if(_UnitData.profession1ID) then
        self:SetProfession1(XFG.Professions:GetProfession(_UnitData.profession1ID))
    end

    if(_UnitData.profession2ID) then
        self:SetProfession2(XFG.Professions:GetProfession(_UnitData.profession2ID))
    end

    self:SetZone(_UnitData.zone or '?')

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        local _CovenantID = C_Covenants.GetActiveCovenantID()
        if(XFG.Covenants:Contains(_CovenantID)) then
            self:SetCovenant(XFG.Covenants:GetCovenant(_CovenantID))
        end

        local _SoulbindID = C_Soulbinds.GetActiveSoulbindID()
        if(XFG.Soulbinds:Contains(_SoulbindID)) then
            self:SetSoulbind(XFG.Soulbinds:GetSoulbind(_SoulbindID))
        end

        local _SpecGroupID = GetSpecialization()
	    local _SpecID = GetSpecializationInfo(_SpecGroupID)
        if(XFG.Specs:Contains(_SpecID)) then
            self:SetSpec(XFG.Specs:GetSpec(_SpecID))
        end
    end

    self:IsInitialized(true)
end

function Unit:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Unit:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _GUID (" .. type(self._GUID) .. "): ".. tostring(self._GUID))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
	XFG:Debug(LogCategory, "  _UnitName (" .. type(self._UnitName) .. "): ".. tostring(self._UnitName))
    XFG:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))    
    XFG:Debug(LogCategory, "  _GuildIndex (" .. type(self._GuildIndex) .. "): ".. tostring(self._GuildIndex))
    XFG:Debug(LogCategory, "  _Level (" .. type(self._Level) .. "): ".. tostring(self._Level))
    XFG:Debug(LogCategory, "  _Zone (" .. type(self._Zone) .. "): ".. tostring(self._Zone))
    XFG:Debug(LogCategory, "  _Note (" .. type(self._Note) .. "): ".. tostring(self._Note))
    XFG:Debug(LogCategory, "  _Online (" .. type(self._Online) .. "): ".. tostring(self._Online))
    XFG:Debug(LogCategory, "  _Status (" .. type(self._Status) .. "): ".. tostring(self._Status))
    XFG:Debug(LogCategory, "  _DungeonScore (" .. type(self._DungeonScore) .. "): ".. tostring(self._DungeonScore))
    XFG:Debug(LogCategory, "  _AchievementPoints (" .. type(self._AchievementPoints) .. "): ".. tostring(self._AchievementPoints))
    XFG:Debug(LogCategory, "  _TimeStamp (" .. type(self._TimeStamp) .. "): ".. tostring(self._TimeStamp))
    XFG:Debug(LogCategory, "  _RunningAddon (" .. type(self._RunningAddon) .. "): ".. tostring(self._RunningAddon))
    XFG:Debug(LogCategory, "  _Alt (" .. type(self._Alt) .. "): ".. tostring(self._Alt))
    XFG:Debug(LogCategory, "  _MainName (" .. type(self._MainName) .. "): ".. tostring(self._MainName))
    XFG:Debug(LogCategory, "  _IsPlayer (" .. type(self._IsPlayer) .. "): ".. tostring(self._IsPlayer))
    XFG:Debug(LogCategory, "  _IsOnMainGuild (" .. type(self._IsOnMainGuild) .. "): ".. tostring(self._IsOnMainGuild))
    XFG:Debug(LogCategory, "  _GuildName (" .. type(self._GuildName) .. "): ".. tostring(self._GuildName))
    XFG:Debug(LogCategory, "  _RealmName (" .. type(self._RealmName) .. "): ".. tostring(self._RealmName))
    XFG:Debug(LogCategory, "  _Team (" .. type(self._Team) .. "): ")
    if(self:HasTeam()) then self._Team:Print() end
    XFG:Debug(LogCategory, "  _Race (" .. type(self._Race) .. "): ")
    if(self:HasRace()) then self._Race:Print() end
    XFG:Debug(LogCategory, "  _Class (" .. type(self._Class) .. "): ")
    self._Class:Print()
    XFG:Debug(LogCategory, "  _Spec (" .. type(self._Spec) .. "): ")
    if(self._Spec ~= nil) then
        self._Spec:Print()
    end
    XFG:Debug(LogCategory, "  _Covenant (" .. type(self._Covenant) .. "): ")
    if(self._Covenant ~= nil) then
        self._Covenant:Print()
    end
    XFG:Debug(LogCategory, "  _Soulbind (" .. type(self._Soulbind) .. "): ")
    if(self._Soulbind ~= nil) then
        self._Soulbind:Print()
    end
    XFG:Debug(LogCategory, "  _Profession1 (" .. type(self._Profession1) .. "): ")
    if(self._Profession1 ~= nil) then
        self._Profession1:Print()
    end
    XFG:Debug(LogCategory, "  _Profession2 (" .. type(self._Profession2) .. "): ")
    if(self._Profession2 ~= nil) then
        self._Profession2:Print()
    end
    XFG:Debug(LogCategory, "  _Rank (" .. type(self._Rank) .. "): ")
    if(self._Rank ~= nil) then
        self._Rank:Print()
    end
end

function Unit:IsPlayer(_Player)
    assert(_Player == nil or type(_Player == 'boolean'), "argument must be nil or boolean")
    if(_Player ~= nil) then
        self._IsPlayer = _Player
    end
    return self._IsPlayer
end

function Unit:GetKey()
    return self._Key
end

function Unit:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Unit:GetGUID()
    return self._GUID
end

function Unit:SetGUID(_GUID)
    assert(type(_GUID) == 'string')
    self._GUID = _GUID
    self:IsPlayer(self:GetGUID() == XFG.Player.GUID)
    return self:GetGUID()
end

function Unit:GetID()
    return self._ID
end

function Unit:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Unit:GetUnitName()
    return self._UnitName
end

function Unit:SetUnitName(_UnitName)
    assert(type(_UnitName) == 'string')
    self._UnitName = _UnitName
    return self:GetUnitName()
end

function Unit:GetName()
    return self._Name
end

function Unit:SetName(_Name)
    assert(type(_Name) == 'string')
    self._Name = _Name
    return self:GetName()
end

function Unit:GetGuildIndex()
    return self._GuildIndex
end

function Unit:SetGuildIndex(_GuildIndex)
    assert(type(_GuildIndex) == 'number')
    self._GuildIndex = _GuildIndex
    return self:GetGuildIndex()
end

function Unit:HasRank()
    return self._Rank ~= nil
end

function Unit:GetRank()
    return self._Rank
end

function Unit:SetRank(_Rank)
    assert(type(_Rank) == 'table' and _Rank.__name ~= nil and _Rank.__name == 'Rank', "argument must be Rank object")
    self._Rank = _Rank

    if(_Rank:GetName() == 'Grand Alt' or _Rank:GetName() == 'Cat Herder') then
        self:IsAlt(true)
    end

    return self:GetRank()
end

function Unit:GetLevel()
    return self._Level
end

function Unit:SetLevel(_Level)
    assert(type(_Level) == 'number')
    self._Level = _Level
    return self:GetLevel()
end

function Unit:GetZone()
    return self._Zone
end

function Unit:SetZone(inZone)
    assert(type(inZone) == 'string', "Usage: SetZone(string)")
    self._Zone = inZone
    return self:GetZone()
end

function Unit:GetNote()
    return self._Note
end

function Unit:SetNote(_Note)
    assert(type(_Note) == 'string')
    self._Note = _Note

    local _Parts = string.Split(_Note, ' ')
    if(self:IsAlt() and _Parts[2] ~= nil) then
        self:SetMainName(_Parts[2])
    end

    if(_Parts[1] ~= nil) then
        -- The first team that matches wins
        _Parts[1] = string.gsub(_Parts[1], '[%[%]]', '')    
        local _Tags = string.Split(_Parts[1], '-')
        for _, _Tag in pairs (_Tags) do
            if(XFG.Teams:Contains(_Tag)) then
                self:SetTeam(XFG.Teams:GetTeam(_Tag))
                break
            end
        end
    end

    if(self:HasTeam() == false) then
        local _Team = XFG.Teams:GetTeam('U')
        self:SetTeam(_Team)
    end

    return self:GetNote()
end

function Unit:GetFaction()
    return self._Faction
end

function Unit:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be a Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function Unit:IsOnline(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Online = inBoolean
    end
    return self._Online
end

function Unit:IsOffline(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Online = inBoolean
    end
    return self._Online == false
end

function Unit:GetDungeonScore()
    return self._DungeonScore
end

function Unit:SetDungeonScore(inScore)
    assert(type(inScore) == 'number')
    self._DungeonScore = inScore
    return self:GetDungeonScore()
end

function Unit:GetAchievementPoints()
    return self._AchievementPoints
end

function Unit:SetAchievementPoints(inPoints)
    assert(type(inPoints) == 'number')
    self._AchievementPoints = inPoints
    return self:GetAchievementPoints()
end

function Unit:HasRace()
    return self._Race ~= nil
end

function Unit:GetRace()
    return self._Race
end

function Unit:SetRace(_Race)
    assert(type(_Race) == 'table' and _Race.__name ~= nil and _Race.__name == 'Race', "argument must be Race object")
    self._Race = _Race
    return self:GetRace()
end

function Unit:GetTimeStamp()
    return self._TimeStamp
end

function Unit:SetTimeStamp(_TimeStamp)
    assert(type(_TimeStamp) == 'number')
    self._TimeStamp = _TimeStamp
    return self:GetTimeStamp()
end

function Unit:GetClass()
    return self._Class
end

function Unit:SetClass(_Class)
    assert(type(_Class) == 'table' and _Class.__name ~= nil and _Class.__name == 'Class', "argument must be Class object")
    self._Class = _Class
    return self:GetClass()
end

function Unit:HasSpec()
    return self._Spec ~= nil
end

function Unit:GetSpec()
    return self._Spec
end

function Unit:SetSpec(_Spec)
    assert(type(_Spec) == 'table' and _Spec.__name ~= nil and _Spec.__name == 'Spec', "argument must be Spec object")
    self._Spec = _Spec
    return self:GetSpec()
end

function Unit:HasCovenant()
    return self._Covenant ~= nil and self._Covenant:GetKey() ~= nil
end

function Unit:GetCovenant()
    return self._Covenant
end

function Unit:SetCovenant(_Covenant)
    assert(type(_Covenant) == 'table' and _Covenant.__name ~= nil and _Covenant.__name == 'Covenant', "argument must be Covenant object")
    self._Covenant = _Covenant
    return self:GetCovenant()
end

function Unit:HasSoulbind()
    return self._Soulbind ~= nil and self._Soulbind:GetKey() ~= nil
end

function Unit:GetSoulbind()
    return self._Soulbind
end

function Unit:SetSoulbind(_Soulbind)
    assert(type(_Soulbind) == 'table' and _Soulbind.__name ~= nil and _Soulbind.__name == 'Soulbind', "argument must be Soulbind object")
    self._Soulbind = _Soulbind
    return self:GetSoulbind()
end

function Unit:HasProfession1()
    return self._Profession1 ~= nil and self._Profession1:GetKey() ~= nil
end

function Unit:GetProfession1()
    return self._Profession1
end

function Unit:SetProfession1(_Profession)
    assert(type(_Profession) == 'table' and _Profession.__name ~= nil and _Profession.__name == 'Profession', "argument must be Profession object")
    self._Profession1 = _Profession
    return self:GetProfession1()
end

function Unit:HasProfession2()
    return self._Profession2 ~= nil and self._Profession2:GetKey() ~= nil
end

function Unit:GetProfession2()
    return self._Profession2
end

function Unit:SetProfession2(_Profession)
    assert(type(_Profession) == 'table' and _Profession.__name ~= nil and _Profession.__name == 'Profession', "argument must be Profession object")
    self._Profession2 = _Profession
    return self:GetProfession2()
end

function Unit:IsRunningAddon(_RunningAddon)
    assert(_RunningAddon == nil or type(_RunningAddon == 'boolean'), "argument must be nil or boolean")
    if(_RunningAddon ~= nil) then
        self._RunningAddon = _RunningAddon
    end
    return self._RunningAddon
end

function Unit:IsAlt(_Alt)
    assert(_Alt == nil or type(_Alt == 'boolean'), "argument must be nil or boolean")
    if(_Alt ~= nil) then
        self._Alt = _Alt
    end
    return self._Alt
end

function Unit:HasMainName()
    return self._MainName ~= nil
end

function Unit:GetMainName()
    return self._MainName
end

function Unit:SetMainName(_MainName)
    assert(type(_MainName) == 'string')
    self._MainName = _MainName
    return self:GetMainName()
end

function Unit:HasTeam()
    return self._Team ~= nil
end

function Unit:GetTeam()
    return self._Team
end

function Unit:SetTeam(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name ~= nil and inTeam.__name == 'Team', "argument must be Team object")
    self._Team = inTeam
    return self:GetTeam()
end

function Unit:GetRealm()
    return self._Realm
end

function Unit:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', "argument must be Realm object")
    self._Realm = inRealm
    return self:GetRealm()
end

function Unit:GetGuild()
    return self._Guild
end

function Unit:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', "argument must be Guild object")
    self._Guild = inGuild
    return self:GetGuild()
end

function Unit:IsOnMainGuild(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._IsOnMainGuild = inBoolean
    end
    return self._IsOnMainGuild
end

-- Usually a key check is enough for equality check, but use case is to detect any data differences
function Unit:Equals(inUnit)
    if(inUnit == nil) then return false end
    if(type(inUnit) ~= 'table' or inUnit.__name == nil or inUnit.__name ~= 'Unit') then return false end

    if(self:GetKey() ~= inUnit:GetKey()) then return false end
    if(self:GetGUID() ~= inUnit:GetGUID()) then return false end
    if(self:GetUnitName() ~= inUnit:GetUnitName()) then return false end
    if(self:GetName() ~= inUnit:GetName()) then return false end
    if(self:GetGuildIndex() ~= inUnit:GetGuildIndex()) then return false end
    if(self:GetLevel() ~= inUnit:GetLevel()) then return false end
    if(self:GetZone() ~= inUnit:GetZone()) then return false end
    if(self:GetNote() ~= inUnit:GetNote()) then return false end
    if(self:IsOnline() ~= inUnit:IsOnline()) then return false end
    if(self:GetDungeonScore() ~= inUnit:GetDungeonScore()) then return false end
    if(self:GetAchievementPoints() ~= inUnit:GetAchievementPoints()) then return false end    
    if(self:IsRunningAddon() ~= inUnit:IsRunningAddon()) then return false end
    if(self:IsAlt() ~= inUnit:IsAlt()) then return false end
    if(self:GetMainName() ~= inUnit:GetMainName()) then return false end
    if(self:IsOnMainGuild() ~= inUnit:IsOnMainGuild()) then return false end
    if(self:GetMainName() ~= inUnit:GetMainName()) then return false end

    if(self:HasCovenant() == false and inUnit:HasCovenant()) then return false end
    if(self:HasCovenant()) then
        local _CachedCovenant = self:GetCovenant()
        if(_CachedCovenant:Equals(inUnit:GetCovenant()) == false) then return false end
    end

    if(self:HasSoulbind() == false and inUnit:HasSoulbind()) then return false end
    if(self:HasSoulbind()) then
        local _CachedSoulbind = self:GetSoulbind()
        if(_CachedSoulbind:Equals(inUnit:GetSoulbind()) == false) then return false end
    end
    
    if(self:HasProfession1() == false and inUnit:HasProfession1()) then return false end
    if(self:HasProfession1()) then
        local _CachedProfession1 = self:GetProfession1()
        if(_CachedProfession1:Equals(inUnit:GetProfession1()) == false) then return false end
    end

    if(self:HasProfession2() == false and inUnit:HasProfession2()) then return false end
    if(self:HasProfession2()) then
        local _CachedProfession2 = self:GetProfession2()
        if(_CachedProfession2:Equals(inUnit:GetProfession2()) == false) then return false end
    end

    if(self:HasRank() == false and inUnit:HasRank()) then return false end
    if(self:HasRank()) then
        local _CachedRank = self:GetRank()
        if(_CachedRank:Equals(inUnit:GetRank()) == false) then return false end
    end

    if(self:HasRace() == false and inUnit:HasRace()) then return false end
    if(self:HasRace()) then
        local _CachedRace = self:GetRace()
        if(_CachedRace:Equals(inUnit:GetRace()) == false) then return false end
    end
    
    if(self:HasSpec() == false and inUnit:HasSpec()) then return false end
    if(self:HasSpec()) then
        local _CachedSpec = self:GetSpec()
        if(_CachedSpec:Equals(inUnit:GetSpec()) == false) then return false end
    end
    
    -- Do not consider TimeStamp
    -- A unit cannot change Class, do not consider
    
    return true
end