local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Unit'

XFC.Unit = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Unit:new()
    local object = XFC.Unit.parent.new(self)
    object.__name = ObjectName

    object.guid = nil
    object.unitName = nil    
    object.rank = nil
    object.level = 70
    object.class = nil
    object.spec = nil
    object.zone = nil
    object.zoneName = nil
    object.note = nil
    object.presence = Enum.ClubMemberPresence.Unknown
    object.race = nil
    object.timeStamp = nil
    object.profession1 = nil
    object.profession2 = nil
    object.achievements = 0
    object.isRunningAddon = false
    object.mainName = nil
    object.isPlayer = false
    object.faction = nil
    object.team = nil
    object.guild = nil
    object.version = nil
    object.itemLevel = 0
    object.pvp = ''
    object.guildSpeak = true
    object.guildListen = true
    object.raiderIO = nil
    object.lastLogin = 0
    object.mythicKey = nil
    object.expansion = nil
    object.realm = nil

    return object
end

function XFC.Unit:Deconstructor()
    self:ParentDeconstructor()
    self.guid = nil
    self.unitName = nil
    self.rank = nil
    self.level = 60
    self.class = nil
    self.spec = nil
    self.zone = nil
    self.zoneName = nil
    self.note = nil
    self.presence = Enum.ClubMemberPresence.Unknown
    self.race = nil
    self.timeStamp = nil
    self.profession1 = nil
    self.profession2 = nil
    self.achievements = 0
    self.isRunningAddon = false
    self.mainName = nil
    self.isPlayer = false
    self.faction = nil
    self.team = nil
    self.guild = nil
    self.version = nil
    self.itemLevel = 0
    self.pvp = ''
    self.guildSpeak = true
    self.guildListen = true
    self.raiderIO = nil
    self.lastLogin = 0
    self.mythicKey = nil
    self.expansion = nil
    self.realm = nil
end

function XFC.Unit:Initialize(inMemberID)
    assert(type(inMemberID) == 'number' or inMemberID == nil)
    local unitData
    if(inMemberID ~= nil) then
        unitData = XFF.GuildGetMember(XF.Player.Guild:ID(), inMemberID)
    else
        unitData = XFF.GuildGetMyself(XF.Player.Guild:ID())
    end

    -- Failure conditions:
    --   Sometimes fails on initial login
    --   guildRank is nil during a zone transition
    --   Unknown presence means dont know if online or offline
    if(unitData == nil or unitData.guildRank == nil or unitData.presence == Enum.ClubMemberPresence.Unknown) then
        self:IsInitialized(false)
        return
    end

    self:GUID(unitData.guid)
    self:Key(unitData.guid)
    self:Presence(unitData.presence) 
    self:ID(unitData.memberId)
    self:Name(unitData.name)
	self:Level(unitData.level)	
	self:Guild(XF.Player.Guild)
    self:TimeStamp(XFF.TimeGetCurrent())
    self:Race(XFO.Races:Get(unitData.race))
    self:Rank(unitData.guildRank)
    self:Note(unitData.memberNote or '?')
    self:IsPlayer(unitData.isSelf)
    self:AchievementPoints(unitData.achievementPoints or 0)
    self:Expansion(XF.WoW)
    self:Realm(XF.Player.Realm)

    local lastLogin = 0
    if(unitData.lastOnlineYear ~= nil) then
        lastLogin = lastLogin + (unitData.lastOnlineYear * 365)
    end
    if(unitData.lastOnlineMonth ~= nil) then
        lastLogin = lastLogin + (unitData.lastOnlineMonth * 30)
    end
    if(unitData.lastOnlineDay ~= nil) then
        lastLogin = lastLogin + unitData.lastOnlineDay
    end
    self:LastLogin(lastLogin)

    if(unitData.zone and XFO.Zones:Contains(unitData.zone)) then
        self:Zone(XFO.Zones:Get(unitData.zone))
    elseif(unitData.zone and strlen(unitData.zone)) then
        XFO.Zones:Add(unitData.zone)
        self:Zone(XFO.Zones:Get(unitData.zone))
    else
        self:Zone(XFO.Zones:Get('?'))
    end

    if(unitData.profession1ID ~= nil) then
        self:Profession1(XFO.Professions:Get(unitData.profession1ID))
    end

    if(unitData.profession2ID ~= nil) then
        self:Profession2(XFO.Professions:Get(unitData.profession2ID))
    end

    local raiderIO = XF.Addons.RaiderIO:Get(self)
    if(raiderIO ~= nil) then
        self:RaiderIO(raiderIO)
    end

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        self:Version(XF.Version)
        
        local mythicKey = XFC.MythicKey:new()
        mythicKey:Initialize()
        mythicKey:Refresh()
        self:MythicKey(mythicKey)

        local permissions = XFF.GuildGetPermissions(unitData.guildRankOrder)
        if(permissions ~= nil) then
            self:CanGuildListen(permissions[1])
            self:CanGuildSpeak(permissions[2])
        end
        
        local itemLevel = XFF.PlayerGetItemLevel()
        if(type(itemLevel) == 'number') then
            itemLevel = math.floor(itemLevel)
            self:ItemLevel(itemLevel)
        end

        -- The following call will randomly fail, retries seem to help
        for i = 1, 10 do
            local specGroupID = XFF.SpecGetGroupID()
            if(specGroupID ~= nil) then
    	        local specID = XFF.SpecGetID(specGroupID)
                if(specID ~= nil and XFO.Specs:Contains(specID)) then
                    self:Spec(XFO.Specs:Get(specID))
                    break
                end
            end
        end        

        -- Highest PvP rating wins
        local highestRating = 0
        local highestIndex = 1
        for i = 1, 3 do
            local pvpRating = XFF.PlayerGetPvPRating(i)
            if(pvpRating > highestRating) then
                highestRating = pvpRating
                highestIndex = i
            end
        end
        if(highestRating > 0) then
            self:PvP(highestRating, highestIndex)
        end
    else
        self:Spec(XFO.Specs:GetInitialClassSpec(unitData.classID))
    end

    self:IsInitialized(true)
end
--#endregion

--#region Properties
function XFC.Unit:IsPlayer(inBoolean)
    return self:Key() == XF.Player.GUID
end

function XFC.Unit:GUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.guid = inGUID
    end
    return self.guid
end

function XFC.Unit:UnitName()
    return self:Name() .. '-' .. self:Realm():APIName()
end

function XFC.Unit:Realm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or inRealm == nil)
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end

function XFC.Unit:Rank(inRank)
    assert(type(inRank) == 'string' or inRank == nil)
    if(inRank ~= nil) then
        self.rank = inRank
    end
    return self.rank
end

function XFC.Unit:Level(inLevel)
    assert(type(inLevel) == 'number' or inLevel == nil)
    if(inLevel ~= nil) then
        self.level = inLevel
    end
    return self.level
end

function XFC.Unit:Zone(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone' or inZone == nil)
    if(inZone ~= nil) then
        self.zone = inZone
    end
    return self.zone
end

function XFC.Unit:Note(inNote)
    assert(type(inNote) == 'string' or inNote == nil)
    if(inNote ~= nil) then
        self.note = inNote
        try(function()

            -- Team tag
            local _, _, teamInitial = string.find(self.note, '%[XFt:(%a-)%]')
            if(teamInitial ~= nil and XFO.Teams:Contains(teamInitial)) then
                self:Team(XFO.Teams:Get(teamInitial))
            else
                local _, _, teamInitial = string.find(self.note, '%[(%a-)%]')
                if(teamInitial ~= nil and XFO.Teams:Contains(teamInitial)) then
                    self:Team(XFO.Teams:Get(teamInitial))
                else
                    local _, _, teamInitial, guildInitials = string.find(self.note, '%[(%a-)-(%a+)')
                    if(teamInitial ~= nil and XFO.Teams:Contains(teamInitial)) then
                        self:Team(XFO.Teams:Get(teamInitial))
                    end
                    if(guildInitials ~= nil and XFO.Guilds:Contains(guildInitials) and not self:Guild():Equals(XFO.Guilds:Get(guildInitials))) then
                        local _, _, mainName = string.find(self.note, '%s+([^%s%[%]]+)%s?')
                        if(mainName ~= nil) then
                            self:MainName(mainName)
                        end
                    end 
                end
            end
    
            -- Alt tag
            local _, _, altName = string.find(self.note, '%[XFa:([^%s%[%]]-)%]')
            if(altName ~= nil) then
                self:MainName(altName)
            end
        end).
        catch(function(err)
            XF:Trace(self:ObjectName(), 'Failed to parse player note: [' .. self.note .. ']')
            XF:Trace(self:ObjectName(), err)
        end).
        finally(function()
            if(not self:HasTeam()) then
                self:Team(XFO.Teams:Get('?'))
            end
        end)
    end
    return self.note
end

function XFC.Unit:CanGuildSpeak(inBoolean)
    assert(type(inBoolean == 'boolean') or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.guildSpeak = inBoolean
    end
    return self.guildSpeak
end

function XFC.Unit:CanGuildListen(inBoolean)
    assert(type(inBoolean == 'boolean') or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.guildListen = inBoolean
    end
    return self.guildListen
end

function XFC.Unit:Presence(inPresence)
    assert(type(inPresence) == 'number' or inPresence == nil)
    if(inPresence ~= nil) then
        self.presence = inPresence
    end
    return self.presence
end

function XFC.Unit:PvP(inScore, inIndex)
    assert(type(inScore) == 'number' or type(inScore) == 'string' or inScore == nil)
    assert(type(inIndex) == 'number' or inIndex == nil)

    if(type(inScore) == 'string') then
        self.pvp = inScore
    elseif(type(inScore == 'number')) then
        self.pvp = tostring(inScore)
        if(inIndex == 1) then
            self.pvp = self.pvp .. ' (2)'
        elseif(inIndex == 2) then
            self.pvp = self.pvp .. ' (3)'
        else
            self.pvp = self.pvp .. ' (10)'
        end
    end

    return self.pvp
end

function XFC.Unit:AchievementPoints(inPoints)
    assert(type(inPoints) == 'number' or inPoints == nil)
    if(inPoints ~= nil) then
        self.achievements = inPoints
    end
    return self.achievements
end

function XFC.Unit:RaiderIO(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name == 'RaiderIO' or inRaiderIO == nil)
    if(inRaiderIO ~= nil) then
        self.raiderIO = inRaiderIO
    end
    return self.raiderIO
end

function XFC.Unit:Race(inRace)
    assert(type(inRace) == 'table' and inRace.__name == 'Race' or inRace == nil)
    if(inRace ~= nil) then
        self.race = inRace
    end
    return self.race
end

function XFC.Unit:Expansion(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name == 'Expansion' or inExpansion == nil)
    if(inExpansion ~= nil) then
        self.expansion = inExpansion
    end
    return self.expansion
end

function XFC.Unit:Spec(inSpec)
    assert(type(inSpec) == 'table' and inSpec.__name == 'Spec' or inSpec == nil)
    if(inSpec ~= nil) then
        self.spec = inSpec
    end
    return self.spec
end

function XFC.Unit:TimeStamp(inTimeStamp)
    assert(type(inTimeStamp) == 'number' or inTimeStamp == nil)
    if(inTimeStamp ~= nil) then
        self.timeStamp = inTimeStamp
    end
    return self.timeStamp
end

function XFC.Unit:Profession1(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession' or inProfession == nil)
    if(inProfession ~= nil) then
        self.profession1 = inProfession
    end
    return self.profession1
end

function XFC.Unit:Profession2(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession' or inProfession == nil)
    if(inProfession ~= nil) then
        self.profession2 = inProfession
    end
    return self.profession2
end

function XFC.Unit:IsRunningAddon(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isRunningAddon = inBoolean
    end
    return self.isRunningAddon
end

function XFC.Unit:Version(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil)
    if(inVersion ~= nil) then
        self.version = inVersion
    end
    return self.version
end

function XFC.Unit:MainName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.mainName = inName
    end
    return self.mainName
end

function XFC.Unit:Team(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name == 'Team' or inTeam == nil)
    if(inTeam ~= nil) then
        self.team = inTeam
    end
    return self.team
end

function XFC.Unit:Guild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild' or inGuild == nil)
    if(inGuild ~= nil) then
        self.guild = inGuild
    end
    return self.guild
end

function XFC.Unit:MythicKey(inKey)
    assert(type(inKey) == 'table' and inKey.__name == 'MythicKey' or inKey == nil)
    if(inKey ~= nil) then
        self.mythicKey = inKey
    end
    return self.mythicKey
end

function XFC.Unit:LastLogin(inDays)
    assert(type(inDays) == 'number' or inDays == nil)
    if(inDays ~= nil) then
        self.lastLogin = inDays
    end
    return self.lastLogin
end

function XFC.Unit:ItemLevel(inItemLevel)
    assert(type(inItemLevel) == 'number' or inItemLevel == nil)
    if(inItemLevel ~= nil) then
        self.itemLevel = inItemLevel
    end
    return self.itemLevel
end
--#endregion

--#region Methods
function XFC.Unit:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
    XF:Debug(self:ObjectName(), '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
    XF:Debug(self:ObjectName(), '  rank (' .. type(self.rank) .. '): ' .. tostring(self.rank))
    XF:Debug(self:ObjectName(), '  level (' .. type(self.level) .. '): ' .. tostring(self.level))
    XF:Debug(self:ObjectName(), '  note (' .. type(self.note) .. '): ' .. tostring(self.note))
    XF:Debug(self:ObjectName(), '  presence (' .. type(self.presence) .. '): ' .. tostring(self.presence))
    XF:Debug(self:ObjectName(), '  achievements (' .. type(self.achievements) .. '): ' .. tostring(self.achievements))
    XF:Debug(self:ObjectName(), '  timeStamp (' .. type(self.timeStamp) .. '): ' .. tostring(self.timeStamp))
    XF:Debug(self:ObjectName(), '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(self:ObjectName(), '  isAlt (' .. type(self.isAlt) .. '): ' .. tostring(self.isAlt))
    XF:Debug(self:ObjectName(), '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(self:ObjectName(), '  isPlayer (' .. type(self.isPlayer) .. '): ' .. tostring(self.isPlayer))
    XF:Debug(self:ObjectName(), '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
    XF:Debug(self:ObjectName(), '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
    XF:Debug(self:ObjectName(), '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
    XF:Debug(self:ObjectName(), '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
    if(self:HasZone()) then self:Zone():Print() end
    if(self:HasVersion()) then self:Version():Print() end
    if(self:HasGuild()) then self:Guild():Print() end
    if(self:HasRealm()) then self:Realm():Print() end
    if(self:HasTeam()) then self:Team():Print() end
    if(self:HasRace()) then self:Race():Print() end
    if(self:HasSpec()) then self:Spec():Print() end
    if(self:HasProfession1()) then self:Profession1():Print() end
    if(self:HasProfession2()) then self:Profession2():Print() end  
    if(self:HasRaiderIO()) then self:RaiderIO():Print() end
    if(self:HasMythicKey()) then self:MythicKey():Print() end
end

function XFC.Unit:IsOnline()
    return self:Presence() == Enum.ClubMemberPresence.Online or 
           self:Presence() == Enum.ClubMemberPresence.Away or 
           self:Presence() == Enum.ClubMemberPresence.Busy
end

function XFC.Unit:IsOffline()
    return not self:IsOnline()
end

function XFC.Unit:HasRealm()
    return self:Realm() ~= nil
end

function XFC.Unit:HasZone()
    return self:Zone() ~= nil
end

function XFC.Unit:HasRaiderIO()
    return self:RaiderIO() ~= nil
end

function XFC.Unit:HasRace()
    return self:Race() ~= nil
end

function XFC.Unit:HasExpansion()
    return self:Expansion() ~= nil
end

function XFC.Unit:HasSpec()
    return self:Spec() ~= nil
end

function XFC.Unit:HasProfession1()
    return self:Profession1() ~= nil
end

function XFC.Unit:HasProfession2()
    return self:Profession2() ~= nil
end

function XFC.Unit:HasVersion()
    return self:Version() ~= nil
end

function XFC.Unit:HasTeam()
    return self:Team() ~= nil
end

function XFC.Unit:HasGuild()
    return self:Guild() ~= nil
end

function XFC.Unit:HasMythicKey()
    return self:MythicKey() ~= nil
end

function XFC.Unit:IsAlt()
    return self:MainName() ~= nil
end

function XFC.Unit:IsFriend()
    return XFO.Friends:ContainsByGUID(self:GUID())
end

function XFC.Unit:IsSameFaction()
    return self:HasRace() and self:Race():Faction():Equals(XF.Player.Faction)
end

function XFC.Unit:GetChatLink()

    if(self:IsFriend()) then
        local friend = XFO.Friends:GetByGUID(self:GUID())
        return format('BNplayer:%s:%d:0:WHISPER:%s', friend:AccountName(), friend:AccountID(), friend:Name())
    end

    return format('player:%s', self:UnitName())
end

function XFC.Unit:Serialize()
    local data = {}

    data.A = self:AchievementPoints()  
    data.E = XF.WoW:Key()
    data.G = self:Guild():Key()
    data.H = self:Realm():ID()
    data.I = self:ItemLevel()
    data.J = self:Rank()
    data.K = self:Key()
    data.L = self:Level() ~= XF.WoW:MaxLevel() and self:Level() or nil
    data.M = self:HasMythicKey() and self:MythicKey():Serialize() or nil
    data.N = self:Name()
    data.O = self:Presence()
    data.P = self:PvP()
	data.R = self:Race():Key()
    data.S = self:Spec():Key()
    data.T = self:Note()
    data.V = self:Version():Key()
    data.X = self:HasProfession1() and self:Profession1():Key() or nil
	data.Y = self:HasProfession2() and self:Profession2():Key() or nil

	if(self:Zone():HasID()) then
		data.D = self:Zone():ID()
	else
		data.Z = self:Zone():Name()
	end

	return pickle(data)
end

function XFC.Unit:Deserialize(inData)
    local data = unpickle(inData)

    self:AchievementPoints(tonumber(data.A))
    self:Expansion(XFO.Expansions:Get(tonumber(data.E)))
    self:Guild(XFO.Guilds:Get(data.G))
    self:Realm(XFO.Realms:Get(data.H))
    self:ItemLevel(tonumber(data.I))
    self:Rank(data.J)
    self:GUID(data.K)
    self:Key(data.K)
    
    if(data.L ~= nil) then
        self:Level(tonumber(data.L))
    else
        self:Level(self:Expansion():MaxLevel())
    end

    if(data.M ~= nil) then
        -- TODO augment deserialize function
        self:MythicKey(XFO.Keys:Deserialize(data.M))
    end
    self:Name(data.N)
    self:Presence(tonumber(data.O))
    self:PvP(data.P)
    self:Race(XFO.Races:Get(tonumber(data.R)))
    self:Spec(XFO.Specs:Get(tonumber(data.S)))
    self:Note(data.T)

    if(not XFO.Versions:Contains(data.V)) then
        XFO.Versions:Add(data.V)
    end
    self:Version(XFO.Versions:Get(data.V))

    if(data.X ~= nil) then 
        self:Profession1(XFO.Professions:Get(tonumber(data.X)))
    end
    if(data.Y ~= nil) then 
        self:Profession2(XFO.Professions:Get(tonumber(data.Y)))
    end

    if(data.D ~= nil) then
        self:Zone(XFO.Zones:Get(tonumber(data.D)))
    else
        if(not XFO.Zones:Contains(data.Z)) then
            XFO.Zones:Add(data.Z)
        end
        self:Zone(XFO.Zones:Get(data.Z))
    end
end

-- Usually a key check is enough for equality check, but use case is to detect any data differences
function XFC.Unit:Equals(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil)

    if(self:Key() ~= inUnit:Key()) then return false end
    if(self:GUID() ~= inUnit:GUID()) then return false end
    if(self:Presence() ~= inUnit:Presence()) then return false end
    if(self:Level() ~= inUnit:Level()) then return false end
    if(self:Zone() ~= inUnit:Zone()) then return false end
    if(self:Note() ~= inUnit:Note()) then return false end
    if(self:IsOnline() ~= inUnit:IsOnline()) then return false end
    if(self:AchievementPoints() ~= inUnit:AchievementPoints()) then return false end    
    if(self:IsRunningAddon() ~= inUnit:IsRunningAddon()) then return false end
    if(self:MainName() ~= inUnit:MainName()) then return false end
    if(self:Rank() ~= inUnit:Rank()) then return false end
    if(self:ItemLevel() ~= inUnit:ItemLevel()) then return false end
    if(self:PvP() ~= inUnit:PvP()) then return false end

    if(not self:HasProfession1() and inUnit:HasProfession1()) then return false end
    if(self:HasProfession1() and not self:Profession1():Equals(inUnit:Profession1())) then return false end

    if(not self:HasProfession2() and inUnit:HasProfession2()) then return false end
    if(self:HasProfession2() and not self:Profession2():Equals(inUnit:Profession2())) then return false end

    if(not self:HasSpec() and inUnit:HasSpec()) then return false end
    if(self:HasSpec() and not self:Spec():Equals(inUnit:Spec())) then return false end

    if(not self:HasRaiderIO() and inUnit:HasRaiderIO()) then return false end
    if(self:HasRaiderIO() and not inUnit:HasRaiderIO()) then return false end
	if(self:HasRaiderIO() and not self:RaiderIO():Equals(inUnit:RaiderIO())) then return false end
    
    -- Do not consider TimeStamp
    -- A unit cannot change Class, do not consider
	-- A unit cannot change Race while logged in, do not consider
	-- A unit cannot change Name/UnitName while logged in, do not consider
	-- A unit cannot change GUID while logged in, but it is the key so consider
    
    return true
end
--#endregion