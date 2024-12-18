local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Unit'

XFC.Unit = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Unit:new()
    local object = XFC.Unit.parent.new(self)
    object.__name = ObjectName

    -- Note player ID is unique to a guild, not globally
    object.guid = nil
    object.unitName = nil    
    object.rank = nil
    object.level = 70
    object.class = nil
    object.spec = nil
    object.hero = nil
    object.location = nil
    object.note = nil
    object.presence = Enum.ClubMemberPresence.Unknown
    object.race = nil
    object.timeStamp = nil
    object.profession1 = nil
    object.profession2 = nil
    object.achievements = 0
    object.isRunningAddon = false
    object.mainName = nil
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
    object.realm = nil
    object.target = nil
    object.friend = nil
    object.targetCounts = nil
    object.loginEpoch = nil

    return object
end

function XFC.Unit:Initialize(inMemberID)
    assert(type(inMemberID) == 'number' or inMemberID == nil)
    local unitData
    if(inMemberID ~= nil) then
        unitData = XFF.GuildMemberInfo(XF.Player.Guild:ID(), inMemberID)
    else
        unitData = XFF.GuildMyInfo(XF.Player.Guild:ID())
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

    -- If local realm, its just the name. If non-local realm, its the full unitname
    local name = string.Split(unitData.name, '-')
    if(#name == 2) then
        self:Name(name[1])
        self:UnitName(unitData.name)
        self:Realm(XFO.Realms:Get(name[2]))
    else
        self:Name(unitData.name)
        self:UnitName(unitData.name .. '-' .. XF.Player.Realm:APIName())
        self:Realm(XF.Player.Realm)
    end
    
	self:Level(unitData.level)	
	self:Guild(XF.Player.Guild)
    
    self:Target(XF.Player.Target)
    self:TimeStamp(XFF.TimeCurrent())
    self:Class(XFO.Classes:Get(unitData.classID))
    self:Race(XFO.Races:Get(unitData.race))
    self:Rank(unitData.guildRank)
    self:Note(unitData.memberNote or '?')
    self:AchievementPoints(unitData.achievementPoints or 0)

    self.targetCounts = {}
    for _, target in XFO.Targets:Iterator() do
        self.targetCounts[target:Key()] = {
            guild = 0,
            channel = 0,
            bnet = 0
        }
    end

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

    if(unitData.profession1ID ~= nil) then
        self:Profession1(XFO.Professions:Get(unitData.profession1ID))
    end

    if(unitData.profession2ID ~= nil) then
        self:Profession2(XFO.Professions:Get(unitData.profession2ID))
    end

    local raiderIO = XFO.RaiderIO:Get(self)
    if(raiderIO ~= nil) then
        self:RaiderIO(raiderIO)
    end

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        self:Version(XF.Version)

        self:Location(XFO.Locations:GetCurrentLocation())

        local mkey = XFO.Keys:GetMyKey()
        if(mkey ~= nil) then
            self:MythicKey(mkey)
        end

        local permissions = XFF.GuildMyPermissions(unitData.guildRankOrder)
        if(permissions ~= nil) then
            self:CanGuildListen(permissions[1])
            self:CanGuildSpeak(permissions[2])
        end
        
        local itemLevel = XFF.PlayerIlvl()
        if(type(itemLevel) == 'number') then
            itemLevel = math.floor(itemLevel)
            self:ItemLevel(itemLevel)
        end

        -- The following call will randomly fail, retries seem to help
        for i = 1, 10 do
            local specGroupID = XFF.SpecGroupID()
            if(specGroupID ~= nil) then
    	        local specID = XFF.SpecID(specGroupID)
                if(specID ~= nil and XFO.Specs:Contains(specID)) then
                    self:Spec(XFO.Specs:Get(specID))
                    break
                end
            end
        end      
        
        local id = XFF.SpecHeroID()
		if(XFO.Heros:Contains(id)) then
			self:Hero(XFO.Heros:Get(id))
		end

        -- Highest PvP rating wins
        local highestRating = 0
        local highestIndex = 1
        for i = 1, 3 do
            local pvpRating = XFF.PlayerPvPRating(i)
            if(pvpRating > highestRating) then
                highestRating = pvpRating
                highestIndex = i
            end
        end
        if(highestRating > 0) then
            self:PvP(highestRating, highestIndex)
        end
    else
        if(unitData.zone ~= nil and strlen(unitData.zone) > 0) then
            if(not XFO.Locations:Contains(unitData.zone)) then                
                XFO.Locations:Add(unitData.zone)
            end
            self:Location(XFO.Locations:Get(unitData.zone))
        else
            self:Location(XFO.Locations:Get('?'))
        end
    end

    self:IsInitialized(true)
end
--#endregion

--#region Properties
function XFC.Unit:GUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.guid = inGUID
    end
    return self.guid
end

function XFC.Unit:UnitName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.unitName = inName
    end
    return self.unitName
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

function XFC.Unit:Location(inLocation)
    assert(type(inLocation) == 'table' and inLocation.__name == 'Location' or inLocation == nil)
    if(inLocation ~= nil) then
        self.location = inLocation
    end
    return self.location
end

function XFC.Unit:Presence(inPresence)
    assert(type(inPresence) == 'number' or inPresence == nil)
    if(inPresence ~= nil) then
        self.presence = inPresence
    end
    return self.presence
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

function XFC.Unit:TimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number' or inEpochTime == nil)
    if(inEpochTime ~= nil) then
        self.timeStamp = inEpochTime
    end
    return self.timeStamp
end

function XFC.Unit:Race(inRace)
    assert(type(inRace) == 'table' and inRace.__name == 'Race' or inRace == nil)
    if(inRace ~= nil) then
        self.race = inRace
    end
    return self.race
end

function XFC.Unit:Class(inClass)
    assert(type(inClass) == 'table' and inClass.__name == 'Class' or inClass == nil)
    if(inClass ~= nil) then
        self.class = inClass
    end
    return self.class
end

function XFC.Unit:Spec(inSpec)
    assert(type(inSpec) == 'table' and inSpec.__name == 'Spec' or inSpec == nil)
    if(inSpec ~= nil) then
        self.spec = inSpec
    end
    return self.spec
end

function XFC.Unit:Hero(inHero)
    assert(type(inHero) == 'table' and inHero.__name == 'Hero' or inHero == nil)
    if(inHero ~= nil) then
        self.hero = inHero
    end
    return self.hero
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

function XFC.Unit:IsAlt(inBoolean)
    return self:MainName() ~= nil
end

function XFC.Unit:MainName(inMainName)
    assert(type(inMainName) == 'string' or inMainName == nil)
    if(inMainName ~= nil) then
        self.mainName = inMainName
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

function XFC.Unit:Realm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or inRealm == nil)
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end

function XFC.Unit:MythicKey(inKey)
    assert(type(inKey) == 'table' and inKey.__name == 'MythicKey' or inKey == nil)
    if(inKey ~= nil) then
        self.mythicKey = inKey
    end
    return self.mythicKey
end

function XFC.Unit:Target(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil)
    if(inTarget ~= nil) then
        self.target = inTarget
    end
    return self.target
end

function XFC.Unit:Friend(inFriend)
    assert(type(inFriend) == 'table' and inFriend.__name == 'Friend' or inFriend == nil)
    if(inFriend ~= nil) then
        self.friend = inFriend
    end
    return self.friend
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
                    if(guildInitials ~= nil and XFO.Guilds:ContainsInitials(guildInitials)) then
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
            XF:Trace(self:ObjectName(), 'Failed to parse player note: [' .. self:Note() .. ']')
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

function XFC.Unit:PvP(inScore, inIndex)
    assert(type(inScore) == 'number' or type(inScore) == 'string' or inScore == nil)
    assert(type(inIndex) == 'number' or inIndex == nil)

    if(inIndex ~= nil) then
        self.pvp = tostring(inScore)
        if(inIndex == 1) then
            self.pvp = self.pvp .. ' (2)'
        elseif(inIndex == 2) then
            self.pvp = self.pvp .. ' (3)'
        else
            self.pvp = self.pvp .. ' (10)'
        end
    elseif(inScore ~= nil) then
        self.pvp = inScore
    end
    
    return self.pvp
end

function XFC.Unit:ItemLevel(inItemLevel)
    assert(type(inItemLevel) == 'number' or inItemLevel == nil)
    if(inItemLevel ~= nil) then
        self.itemLevel = inItemLevel
    end
    return self.itemLevel
end

function XFC.Unit:LastLogin(inDays)
    assert(type(inDays) == 'number' or inDays == nil)
    if(inDays ~= nil) then
        self.lastLogin = inDays
    end
    return self.lastLogin
end

function XFC.Unit:LoginEpoch(inEpochTime)
    assert(type(inEpochTime) == 'number' or inEpochTime == nil)
    if(inEpochTime ~= nil) then
        self.loginEpoch = inEpochTime
    end
    return self.loginEpoch
end

function XFC.Unit:TargetGuildCount(inTargetKey, inCount)
    assert(type(inTargetKey) == 'number')
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.targetCounts[inTargetKey].guild = inCount
    end
    return self.targetCounts[inTargetKey].guild
end

function XFC.Unit:TargetChannelCount(inTargetKey, inCount)
    assert(type(inTargetKey) == 'number')
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.targetCounts[inTargetKey].channel = inCount
    end
    return self.targetCounts[inTargetKey].channel
end

function XFC.Unit:TargetBNetCount(inTargetKey, inCount)
    assert(type(inTargetKey) == 'number')
    assert(type(inCount) == 'number' or inCount == nil)
    if(inCount ~= nil) then
        self.targetCounts[inTargetKey].bnet = inCount
    end
    return self.targetCounts[inTargetKey].bnet
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
    XF:Debug(self:ObjectName(), '  loginEpoch (' .. type(self.loginEpoch) .. '): ' .. tostring(self.loginEpoch))
    XF:Debug(self:ObjectName(), '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(self:ObjectName(), '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(self:ObjectName(), '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
    XF:Debug(self:ObjectName(), '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
    XF:Debug(self:ObjectName(), '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
    XF:Debug(self:ObjectName(), '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
    -- if(self:HasVersion()) then self:Version():Print() end
    -- if(self:HasGuild()) then self:Guild():Print() end
    -- if(self:HasRealm()) then self:Realm():Print() end
    -- if(self:HasTarget()) then self:Target():Print() end
    -- if(self:HasTeam()) then self:Team():Print() end
    -- if(self:HasLocation()) then self:Location():Print() end
    -- if(self:HasRace()) then self:Race():Print() end
    -- if(self:HasClass()) then self:Class():Print() end
    -- if(self:HasSpec()) then self:Spec():Print() end
    -- if(self:HasHero()) then self:Hero():Print() end
    -- if(self:HasProfession1()) then self:Profession1():Print() end
    -- if(self:HasProfession2()) then self:Profession2():Print() end  
    -- if(self:HasRaiderIO()) then self:RaiderIO():Print() end
    if(self:HasMythicKey()) then self:MythicKey():Print() end
    -- if(self:IsFriend()) then self:Friend():Print() end
end

function XFC.Unit:IsPlayer()
    return self:GUID() == XF.Player.GUID
end

function XFC.Unit:HasLocation()
    return self:Location() ~= nil
end

function XFC.Unit:IsOnline()
    return self:Presence() == Enum.ClubMemberPresence.Online or 
           self:Presence() == Enum.ClubMemberPresence.Away or 
           self:Presence() == Enum.ClubMemberPresence.Busy
end

function XFC.Unit:IsOffline()
    return not self:IsOnline()
end

function XFC.Unit:HasRace()
    return self:Race() ~= nil
end

function XFC.Unit:Faction()
    return self:Race():Faction()
end

function XFC.Unit:HasFaction()
    return self:HasRace() and self:Race():HasFaction()
end

function XFC.Unit:HasClass()
    return self.class ~= nil
end

function XFC.Unit:HasSpec()
    return self.spec ~= nil
end

function XFC.Unit:HasHero()
    return self.hero ~= nil
end

function XFC.Unit:HasRaiderIO()
    return self.raiderIO ~= nil
end

function XFC.Unit:HasProfession1()
    return self.profession1 ~= nil
end

function XFC.Unit:HasProfession2()
    return self.profession2 ~= nil
end

function XFC.Unit:HasVersion()
    return self:Version() ~= nil
end

function XFC.Unit:HasTeam()
    return self.team ~= nil
end

function XFC.Unit:HasGuild()
    return self.guild ~= nil
end

function XFC.Unit:HasRealm()
    return self.realm ~= nil
end

function XFC.Unit:HasMythicKey()
    return self.mythicKey ~= nil
end

function XFC.Unit:HasTarget()
    return self.target ~= nil
end

function XFC.Unit:IsFriend()
    return self:Friend() ~= nil
end

function XFC.Unit:IsSameRealm()
    return XF.Player.Realm:Equals(self:Realm())
end

function XFC.Unit:IsSameFaction()
    return XF.Player.Faction:Equals(self:Faction())
end

function XFC.Unit:IsSameGuild()
    return XF.Player.Guild:Equals(self:Guild())
end

function XFC.Unit:IsSameTarget()
    return XF.Player.Target:Equals(self:Target())
end

function XFC.Unit:CanChat()
    return self:IsOnline() and self:IsRunningAddon() and self:IsSameFaction() and self:IsSameRealm() and not self:IsPlayer()
end

function XFC.Unit:GetLink()
    if(self:IsFriend()) then
        return format('|HBNplayer:%s:%d:0:WHISPER:%s|h[%s]|h', self:Friend():Name(), self:Friend():AccountID(), self:Friend():Name(), self:Name())
    end

    return format('|Hplayer:%s|h[%s]|h', self:UnitName(), self:Name())
end

function XFC.Unit:UnlinkFriend()
    self.friend = nil
    return not self:IsFriend()
end

function XFC.Unit:GetColoredName()
    return format('|cff%s%s|r', self:Class():Hex(), self:Name())
end

function XFC.Unit:Serialize()
    local data = {}

	data.A = self:AchievementPoints()    
	data.C = self:Class():Serialize()
    data.F = self:Race():Serialize()
	data.G = self:Guild():Serialize()
    data.H = self:HasHero() and self:Hero():Serialize() or nil
	data.I = self:ItemLevel()
	data.J = self:Rank()
    data.K = self:GUID()
	data.L = self:Level()
	data.M = self:HasMythicKey() and self:MythicKey():Serialize() or nil
	data.N = self:Note()
	data.O = self:Presence()
    data.P = self:PvP()	
    data.R = self:Realm():Serialize()
    data.S = self:HasSpec() and self:Spec():Serialize() or nil
    data.T = self:Target():Serialize()
	data.U = self:Name()
	data.V = self:Version():Serialize()
	data.X = self:HasProfession1() and self:Profession1():Serialize() or nil
	data.Y = self:HasProfession2() and self:Profession2():Serialize() or nil
    data.Z = self:Location():Serialize()

    local counts = ''
    if(self:IsPlayer()) then
        for _, target in XFO.Targets:Iterator() do
            local guild = target:IsMyTarget() and XFO.Channels:GuildChannel():Count() or 0
            local channel = not target:IsMyTarget() and target:Count() or 0
            counts = counts .. target:Key() .. ':' .. guild .. ':' .. channel .. ':' .. target:LinkCount() .. ';'
        end
    else        
        for key, data in pairs(self.targetCounts) do
            counts = counts .. key .. ':' .. data.guild .. ':' .. data.channel .. ':' .. data.bnet .. ';'
        end        
    end
    if(string.len(counts) > 0) then
        data.W = counts
    end

	return pickle(data)
end

function XFC.Unit:Deserialize(inSerial)
    assert(type(inSerial) == 'string')
    local data = unpickle(inSerial)

    self.targetCounts = {}
    for _, target in XFO.Targets:Iterator() do
        self.targetCounts[target:Key()] = {
            guild = 0,
            channel = 0,
            bnet = 0
        }
    end

    self:IsRunningAddon(true)
	self:AchievementPoints(data.A)    
    self:Class(XFO.Classes:Get(tonumber(data.C)))
    self:Race(XFO.Races:Get(tonumber(data.F)))
    self:Guild(XFO.Guilds:Get(tonumber(data.G)))
    self:Hero(XFO.Heros:Get(tonumber(data.H)))
	self:ItemLevel(data.I)
	self:Rank(data.J)
    self:GUID(data.K)
    self:Key(data.K)
	self:Level(data.L)
    self:MythicKey(XFO.Keys:Deserialize(data.M))
    self:Print()
	self:Note(data.N)
	self:Presence(data.O)
    self:PvP(data.P)	
    self:Realm(XFO.Realms:Get(tonumber(data.R)))
    self:Spec(XFO.Specs:Get(tonumber(data.S)))
    self:Target(XFO.Targets:Get(tonumber(data.T)))
    self:Profession1(XFO.Professions:Get(tonumber(data.X)))
    self:Profession2(XFO.Professions:Get(tonumber(data.Y)))
    
    self:Name(data.U)
    self:UnitName(self:Name() .. '-' .. self:Realm():APIName())

    if(not XFO.Versions:Contains(data.V)) then
        XFO.Versions:Add(data.V)
    end
    self:Version(XFO.Versions:Get(data.V))

    if(data.Z ~= nil) then
        if(not XFO.Locations:Contains(data.Z)) then
            XFO.Locations:Add(data.Z)
        end
        self:Location(XFO.Locations:Get(data.Z))
    end

    if(data.W ~= nil) then
        local targets = string.Split(data.W, ';')
        for _, target in ipairs(targets) do
            if(target ~= nil and string.len(target) > 0) then
                local counts = string.Split(target, ':')
                self:TargetGuildCount(tonumber(counts[1]), tonumber(counts[2]))
                self:TargetChannelCount(tonumber(counts[1]), tonumber(counts[3]))
                self:TargetBNetCount(tonumber(counts[1]), tonumber(counts[4]))
            end
        end
    end

    self:TimeStamp(XFF.TimeCurrent())
end
--#endregion