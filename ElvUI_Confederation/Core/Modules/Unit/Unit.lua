local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'Unit'
local LogCategory = 'U' .. ObjectName

Unit = {}

function Unit:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true
    assert(_Argument == nil or _typeof == 'table' or _typeof == 'number' or _typeof == 'string', "argument must be nil, string, number or " .. ObjectName .. " object")
    if(_Argument == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName) then
        Object = _Argument
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Key = nil
        self._GUID = nil
        self._UnitName = nil
        self._Name = nil
        self._GuildIndex = 0
        self._Rank = nil
        self._Level = 60
        self._Class = nil
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
        self._RunningAddon = false
        self._Alt = false
        self._MainName = nil
        self._IsPlayer = false
        self._IsOnMainGuild = false

        -- These three will be redundant but necessary when marshaling data
        self._GuildName = nil
        self._RealmName = nil
        self._TeamName = nil
    end

    return Object
end

-- Unfortunately lua seems to have a problem with the Blizz API function calls being in the constructor
-- So have to have a post creation intialization
function Unit:Initialize(_Argument)
    assert(type(_Argument) == 'number')
    self:SetGuildIndex(_Argument)
    local _unit, _rank, _, _level, _class, _zone, _note, _officernote, _online, _status, _, _, _, _isMobile, _, _, _GUID = GetGuildRosterInfo(self:GetGuildIndex())
    self:SetGUID(_GUID)
    self:SetKey(self:GetGUID())
    self:SetUnitName(_unit)
	self:SetLevel(_level)
	--self:SetZone(_zone)
	self:SetNote(_note)
	self:IsOnline(_online)
	self:IsMobile(_isMobile)

    self:SetGuildName(GetGuildInfo('player'))
    self:SetRealmName(GetRealmName())
    self:SetTimeStamp(GetServerTime())

    local _ParsedName = string.Split(_unit, "-")
    self:SetName(_ParsedName[1])
    self:SetRank(Rank:new(_rank))

    self:SetClass(CON.Classes:GetClass(_class))
    local _, _, _Race = GetPlayerInfoByGUID(self:GetGUID())
    self:SetRace(CON.Races:GetRace(_Race))

    local _SpecGroupID = GetSpecialization()
	local _SpecID = GetSpecializationInfo(_SpecGroupID)
    self:SetSpec(CON.Specs:GetSpec(_SpecID))

    if(self:IsPlayer()) then
        local _CovenantID = C_Covenants.GetActiveCovenantID()
        if(CON.Covenants:Contains(_CovenantID)) then
            self:SetCovenant(CON.Covenants:GetCovenant(_CovenantID))
        else
            CON:Error(LogCategory, "Active Covenant not found in CovenantCollection: " .. tostring(_CovenantID))
        end

        local _SoulbindID = C_Soulbinds.GetActiveSoulbindID()
        if(CON.Soulbinds:Contains(_SoulbindID)) then
            self:SetSoulbind(CON.Soulbinds:GetSoulbind(_SoulbindID))
        else
            CON:Error(LogCategory, "Active Soulbind not found in SoulbindCollection: " .. tostring(_SoulbindID))
        end

        -- These profession IDs are local to the player, need to initialize object to get global ID
        local _Profession1ID, _Profession2ID = GetProfessions()
        if(_Profession1ID ~= nil and _Profession1ID > 0) then
            local _Profession1 = Profession:new()
            _Profession1:SetID(_Profession1ID)
            _Profession1:Initialize()
            if(CON.Professions:Contains(_Profession1:GetKey()) == false) then
                CON.Professions:AddProfession(_Profession1)
            end
            self:SetProfession1(CON.Professions:GetProfession(_Profession1:GetKey()))
        end

        if(_Profession2ID ~= nil and _Profession2ID > 0) then
            local _Profession2 = Profession:new()
            _Profession2:SetID(_Profession2ID)
            _Profession2:Initialize()
            if(CON.Professions:Contains(_Profession2:GetKey()) == false) then
                CON.Professions:AddProfession(_Profession2)
            end
            self:SetProfession2(CON.Professions:GetProfession(_Profession2:GetKey()))
        end
    end
    
    local _UpperNote = string.upper(self:GetNote())
	if(string.match(_UpperNote, "%[EN?KA%]")) then
		self:IsAlt(true)
	end
    
    if(string.match(_UpperNote, "%[ENKA%]")) then
		self:SetTeamName('NonRaid')
	elseif(string.match(_UpperNote, "%[A%]")) then
		self:SetTeamName('Acheron')
	elseif(string.match(_UpperNote, "%[C%]")) then
		self:SetTeamName('Chivalry')
	elseif(string.match(_UpperNote, "%[D%]")) then
		self:SetTeamName('Duelist')
	elseif(string.match(_UpperNote, "%[E%]")) then
		self:SetTeamName('Empire')
	elseif(string.match(_UpperNote, "%[F%]")) then
		self:SetTeamName('Fireforged')
	elseif(string.match(_UpperNote, "%[G%]")) then
		self:SetTeamName('Gallant')
	elseif(string.match(_UpperNote, "%[H%]")) then
		self:SetTeamName('Harbinger')
	elseif(string.match(_UpperNote, "%[K%]")) then
		self:SetTeamName('Kismet')
	elseif(string.match(_UpperNote, "%[L%]")) then
		self:SetTeamName('Legacy')
	elseif(string.match(_UpperNote, "%[O%]")) then
		self:SetTeamName('Olympus')
	elseif(string.match(_UpperNote, "%[S%]")) then
		self:SetTeamName('Sellswords')
	elseif(string.match(_UpperNote, "%[T%]")) then
		self:SetTeamName('Tsunami')
	elseif(string.match(_UpperNote, "%[T%]")) then
		self:SetTeamName('Tsunami')
	elseif(string.match(_UpperNote, "%[Y%]")) then
		self:SetTeamName('Gravity')
	elseif(string.match(_UpperNote, "%[R%]")) then
		self:SetTeamName('Reckoning')
	elseif(string.match(_UpperNote, "%[BANK%]")) then
		self:SetTeamName('Management')
	else
		self:SetTeamName('Unknown')
	end
end

function Unit:Print()
	CON:SingleLine(LogCategory)
	CON:Debug(LogCategory, "Unit Object")
    CON:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    CON:Debug(LogCategory, "  _GUID (" .. type(self._GUID) .. "): ".. tostring(self._GUID))
	CON:Debug(LogCategory, "  _UnitName (" .. type(self._UnitName) .. "): ".. tostring(self._UnitName))
    CON:Debug(LogCategory, "  _Name (" .. type(self._Name) .. "): ".. tostring(self._Name))
    CON:Debug(LogCategory, "  _Rank (" .. type(self._Rank) .. "): ".. tostring(self._Rank))
    CON:Debug(LogCategory, "  _GuildIndex (" .. type(self._GuildIndex) .. "): ".. tostring(self._GuildIndex))
    CON:Debug(LogCategory, "  _Level (" .. type(self._Level) .. "): ".. tostring(self._Level))
    CON:Debug(LogCategory, "  _Zone (" .. type(self._Zone) .. "): ".. tostring(self._Zone))
    CON:Debug(LogCategory, "  _Note (" .. type(self._Note) .. "): ".. tostring(self._Note))
    CON:Debug(LogCategory, "  _Online (" .. type(self._Online) .. "): ".. tostring(self._Online))
    CON:Debug(LogCategory, "  _Status (" .. type(self._Status) .. "): ".. tostring(self._Status))
    CON:Debug(LogCategory, "  _Mobile (" .. type(self._Mobile) .. "): ".. tostring(self._Mobile))
    CON:Debug(LogCategory, "  _TimeStamp (" .. type(self._TimeStamp) .. "): ".. tostring(self._TimeStamp))
    CON:Debug(LogCategory, "  _RunningAddon (" .. type(self._RunningAddon) .. "): ".. tostring(self._RunningAddon))
    CON:Debug(LogCategory, "  _Alt (" .. type(self._Alt) .. "): ".. tostring(self._Alt))
    CON:Debug(LogCategory, "  _MainName (" .. type(self._MainName) .. "): ".. tostring(self._MainName))
    CON:Debug(LogCategory, "  _IsPlayer (" .. type(self._IsPlayer) .. "): ".. tostring(self._IsPlayer))
    CON:Debug(LogCategory, "  _IsOnMainGuild (" .. type(self._IsOnMainGuild) .. "): ".. tostring(self._IsOnMainGuild))
    CON:Debug(LogCategory, "  _GuildName (" .. type(self._GuildName) .. "): ".. tostring(self._GuildName))
    CON:Debug(LogCategory, "  _RealmName (" .. type(self._RealmName) .. "): ".. tostring(self._RealmName))
    CON:Debug(LogCategory, "  _TeamName (" .. type(self._TeamName) .. "): ".. tostring(self._TeamName))
    CON:Debug(LogCategory, "  _Race (" .. type(self._Race) .. "): ")
    self._Race:Print()
    CON:Debug(LogCategory, "  _Class (" .. type(self._Class) .. "): ")
    self._Class:Print()
    CON:Debug(LogCategory, "  _Spec (" .. type(self._Spec) .. "): ")
    self._Spec:Print()
    CON:Debug(LogCategory, "  _Covenant (" .. type(self._Covenant) .. "): ")
    if(self._Covenant ~= nil) then
        self._Covenant:Print()
    end
    CON:Debug(LogCategory, "  _Soulbind (" .. type(self._Soulbind) .. "): ")
    if(self._Soulbind ~= nil) then
        self._Soulbind:Print()
    end
    CON:Debug(LogCategory, "  _Profession1 (" .. type(self._Profession1) .. "): ")
    if(self._Profession1 ~= nil) then
        self._Profession1:Print()
    end
    CON:Debug(LogCategory, "  _Profession2 (" .. type(self._Profession2) .. "): ")
    if(self._Profession2 ~= nil) then
        self._Profession2:Print()
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
    self:IsPlayer(self:GetGUID() == CON.Player.GUID)
    return self:GetGUID()
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

function Unit:GetRank()
    return self._Rank
end

function Unit:SetRank(_Rank)
    assert(type(_Rank) == 'table' and _Rank.__name ~= nil and _Rank.__name == 'Rank', "argument must be Rank object")
    self._Rank = _Rank
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
    assert(type(inZone) == 'string')
    self._Zone = inZone
    return self:GetZone()
end

function Unit:GetNote()
    return self._Note
end

function Unit:SetNote(_Note)
    assert(type(_Note) == 'string')
    self._Note = _Note
    return self:GetNote()
end

function Unit:IsOnline(_Online)
    assert(_Online == nil or type(_Online == 'boolean'), "argument must be nil or boolean")
    if(_Online ~= nil) then
        self._Online = _Online
    end
    return self._Online
end

function Unit:IsMobile(_Mobile)
    assert(_Mobile == nil or type(_Mobile == 'boolean'), "argument must be nil or boolean")
    if(_Mobile ~= nil) then
        self._Mobile = _Mobile
    end
    return self._Mobile
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

function Unit:GetSpec()
    return self._Spec
end

function Unit:SetSpec(_Spec)
    assert(type(_Spec) == 'table' and _Spec.__name ~= nil and _Spec.__name == 'Spec', "argument must be Spec object")
    self._Spec = _Spec
    return self:GetSpec()
end

function Unit:HasCovenant()
    return self._Covenant ~= nil
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
    return self._Covenant ~= nil
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
    return self._Profession1 ~= nil
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
    return self._Profession2 ~= nil
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

function Unit:GetMainName()
    return self._MainName
end

function Unit:SetMainName(_MainName)
    assert(type(_MainName) == 'string')
    self._MainName = _MainName
    return self:GetMainName()
end

function Unit:GetTeamName()
    return self._TeamName
end

function Unit:SetTeamName(_TeamName)
    assert(type(_TeamName) == 'string')
    self._TeamName = _TeamName
    return self:GetTeamName()
end

function Unit:GetRealmName()
    return self._RealmName
end

function Unit:SetRealmName(_RealmName)
    assert(type(_RealmName) == 'string')
    self._RealmName = _RealmName
    return self:GetRealmName()
end

function Unit:GetGuildName()
    return self._GuildName
end

function Unit:SetGuildName(_GuildName)
    assert(type(_GuildName) == 'string')
    self._GuildName = _GuildName
    return self:GetGuildName()
end

function Unit:IsOnMainGuild(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._IsOnMainGuild = inBoolean
    end
    return self._IsOnMainGuild
end