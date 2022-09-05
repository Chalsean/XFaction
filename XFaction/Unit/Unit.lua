local XFG, G = unpack(select(2, ...))
local ObjectName = 'Unit'
local GetMemberInfo = C_Club.GetMemberInfo
local GetMemberInfoForSelf = C_Club.GetMemberInfoForSelf
local ServerTime = GetServerTime
local GetPermissions = C_GuildInfo.GuildControlGetRankFlags
local GetAverageIlvl = GetAverageItemLevel
local GetSpecGroupID = GetSpecialization
local GetSpecID = GetSpecializationInfo
local GetPvPRating = GetPersonalRatedInfo
local GetPlayerBNetInfo = BNGetInfo

Unit = Object:newChildConstructor()

function Unit:new()
    local object = Unit.parent.new(self)
    object.__name = ObjectName

    object.guid = nil
    object.unitName = nil
    object.ID = 0  -- Note player ID is unique to a guild, not globally
    object.rank = nil
    object.level = 70
    object.class = nil
    object.spec = nil
    object.zone = nil
    object.zoneName = nil
    object.note = nil
    object.isOnline = false
    object.race = nil
    object.timeStamp = nil
    object.profession1 = nil
    object.profession2 = nil
    object.achievements = 0
    object.isRunningAddon = false
    object.isAlt = false
    object.mainName = nil
    object.isPlayer = false
    object.faction = nil
    object.team = nil
    object.guild = nil
    object.realm = nil
    object.version = nil
    object.itemLevel = 0
    object.pvp = ''
    object.guildSpeak = true
    object.guildListen = true
    object.raidIO = nil

    return object
end

function Unit:Initialize(inMemberID)
    assert(type(inMemberID) == 'number' or inMemberID == nil)
    local unitData
    if(inMemberID ~= nil) then
        unitData = GetMemberInfo(XFG.Player.Guild:GetID(), inMemberID)
    else
        unitData = GetMemberInfoForSelf(XFG.Player.Guild:GetID())
    end

    -- Sometimes fails on initial login and odd, but guildRank is nil during a zone transition
    if(unitData == nil or unitData.guildRank == nil) then
        return
    end
 
    self:SetGUID(unitData.guid)
    self:SetKey(self:GetGUID())

    if(not self:IsPlayer() and 
       XFG.Confederate:Contains(self:GetKey()) and 
       XFG.Confederate:Get(self:GetKey()):IsRunningAddon()) then
        self:IsInitialized(false)
        return
    end

    self:IsOnline(unitData.presence == 1 or unitData.presence == 4 or unitData.presence == 5)
    if(self:IsOffline()) then
        self:IsInitialized(true)
        return
    end
    
    self:SetID(unitData.memberId)
    self:SetName(unitData.name)
    self:SetUnitName(unitData.name .. '-' .. XFG.Player.Realm:GetAPIName())
	self:SetLevel(unitData.level)	
	self:SetFaction(XFG.Player.Faction)
    self:SetGuild(XFG.Player.Guild)
    self:SetRealm(XFG.Player.Realm)
    self:SetTimeStamp(ServerTime())
    self:SetClass(XFG.Classes:Get(unitData.classID))
    self:SetRace(XFG.Races:Get(unitData.race))
    self:SetRank(unitData.guildRank)
    self:SetNote(unitData.memberNote or '?')
    self:IsPlayer(unitData.isSelf)
    self:SetAchievementPoints(unitData.achievementPoints or 0)

    if(unitData.zone and XFG.Zones:Contains(unitData.zone)) then
        self:SetZone(XFG.Zones:Get(unitData.zone))
    elseif(unitData.zone and strlen(unitData.zone)) then
        XFG.Zones:AddZone(unitData.zone)
        self:SetZone(XFG.Zones:Get(unitData.zone))
    else
        self:SetZone(XFG.Zones:Get('?'))
    end

    if(unitData.profession1ID ~= nil) then
        self:SetProfession1(XFG.Professions:Get(unitData.profession1ID))
    end

    if(unitData.profession2ID ~= nil) then
        self:SetProfession2(XFG.Professions:Get(unitData.profession2ID))
    end

    local raidIO = XFG.RaidIO:Get(self)
    if(raidIO ~= nil) then
        self:SetRaidIO(raidIO)
    end

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        self:SetVersion(XFG.Version)

        local permissions = GetPermissions(unitData.guildRankOrder)
        if(permissions ~= nil) then
            self:CanGuildListen(permissions[1])
            self:CanGuildSpeak(permissions[2])
        end
        
        local itemLevel = GetAverageIlvl()
        if(type(itemLevel) == 'number') then
            itemLevel = math.floor(itemLevel)
            self:SetItemLevel(itemLevel)
        end

        -- The following call will randomly fail, retries seem to help
        for i = 1, 10 do
            local specGroupID = GetSpecGroupID()
            if(specGroupID ~= nil) then
    	        local specID = GetSpecID(specGroupID)
                if(specID ~= nil and XFG.Specs:Contains(specID)) then
                    self:SetSpec(XFG.Specs:Get(specID))
                    break
                end
            end
        end        

        -- Highest PvP rating wins
        local highestRating = 0
        local highestIndex = 1
        for i = 1, 3 do
            local pvpRating = GetPvPRating(i)
            if(pvpRating > highestRating) then
                highestRating = pvpRating
                highestIndex = i
            end
        end
        if(highestRating > 0) then
            self:SetPvP(highestRating, highestIndex)
        end
    end

    self:IsInitialized(true)
end

function Unit:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
        XFG:Debug(ObjectName, '  rank (' .. type(self.rank) .. '): ' .. tostring(self.rank))
        XFG:Debug(ObjectName, '  level (' .. type(self.level) .. '): ' .. tostring(self.level))
        XFG:Debug(ObjectName, '  note (' .. type(self.note) .. '): ' .. tostring(self.note))
        XFG:Debug(ObjectName, '  isOnline (' .. type(self.isOnline) .. '): ' .. tostring(self.isOnline))
        XFG:Debug(ObjectName, '  achievements (' .. type(self.achievements) .. '): ' .. tostring(self.achievements))
        XFG:Debug(ObjectName, '  timeStamp (' .. type(self.timeStamp) .. '): ' .. tostring(self.timeStamp))
        XFG:Debug(ObjectName, '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
        XFG:Debug(ObjectName, '  isAlt (' .. type(self.isAlt) .. '): ' .. tostring(self.isAlt))
        XFG:Debug(ObjectName, '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
        XFG:Debug(ObjectName, '  isPlayer (' .. type(self.isPlayer) .. '): ' .. tostring(self.isPlayer))
        XFG:Debug(ObjectName, '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
        XFG:Debug(ObjectName, '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
        XFG:Debug(ObjectName, '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
        XFG:Debug(ObjectName, '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
        if(self:HasZone()) then 
            self:GetZone():Print()
        else
            XFG:Debug(ObjectName, '  zoneName (' .. type(self.zoneName) .. '): ' .. tostring(self.zoneName))
        end
        if(self:HasVersion()) then self.version:Print() end
        if(self:HasRealm()) then self.realm:Print() end
        if(self:HasGuild()) then self.guild:Print() end
        if(self:HasTeam()) then self.team:Print() end
        if(self:HasRace()) then self.race:Print() end
        if(self:HasClass()) then self.class:Print() end
        if(self:HasSpec()) then self.spec:Print() end
        if(self:HasProfession1()) then self.profession1:Print() end
        if(self:HasProfession2()) then self.profession2:Print() end  
        if(self:HasRaidIO()) then self:GetRaidIO():Print() end
    end
end

function Unit:IsPlayer(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isPlayer = inBoolean
    end
    return self.isPlayer
end

function Unit:GetGUID()
    return self.guid
end

function Unit:SetGUID(inGUID)
    assert(type(inGUID) == 'string')
    self.guid = inGUID
    self:IsPlayer(self:GetGUID() == XFG.Player.GUID)
end

function Unit:GetID()
    return self.ID
end

function Unit:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Unit:GetUnitName()
    return self.unitName
end

function Unit:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self.unitName = inUnitName
end

function Unit:GetRank()
    return self.rank
end

function Unit:SetRank(inRank)
    assert(type(inRank) == 'string')
    self.rank = inRank

    if(inRank == XFG.Settings.Confederate.AltRank) then
        self:IsAlt(true)
    end
    -- Temporary hardcoding until I can figure out how to accomodate all the EK rules
    if(inRank == 'Noble Citizen') then
        self:SetTeam(XFG.Teams:Get('S'))
    end
end

function Unit:GetLevel()
    return self.level
end

function Unit:SetLevel(inLevel)
    assert(type(inLevel) == 'number')
    self.level = inLevel
end

function Unit:HasZone()
    return self.zone
end

function Unit:GetZone()
    return self.zone
end

function Unit:SetZone(inZone)
    assert(type(inZone) == 'table' and inZone.__name ~= nil and inZone.__name == 'Zone', 'argument must be Zone object')
    self.zone = inZone
end

function Unit:GetNote()
    return self.note
end

function Unit:SetMainTeam(inGuildInitials, inTeamInitial)
    if(inTeamInitial ~= nil and XFG.Teams:Contains(inTeamInitial)) then
        self:SetTeam(XFG.Teams:Get(inTeamInitial))
    end
    if(inGuildInitials == 'EK') then inGuildInitials = 'EKA' end
    if(inGuildInitials == 'ENKA') then inGuildInitials = 'ENK' end
    if(inGuildInitials == 'ENKH') then inGuildInitials = 'ENK' end
    if(inGuildInitials ~= nil and XFG.Guilds:Contains(inGuildInitials)) then
        local guild = XFG.Guilds:Get(inGuildInitials)
        if(not guild:Equals(self:GetGuild())) then
            self:IsAlt(true)
            local _, _, mainName = string.find(self.note, '%s+([^%s%[%]]+)%s?')
            if(mainName ~= nil) then
                self:SetMainName(mainName)
            end                
        end
        if(XFG.Teams:Contains(guild:GetInitials())) then
            self:SetTeam(XFG.Teams:Get(guild:GetInitials()))
        end
    end    
end

function Unit:SetNote(inNote)
    assert(type(inNote) == 'string')
    self.note = inNote

    --================================
    -- EK standard notes logic
    --================================

    -- New team initial format on main
    local startIndex, _, teamInitial = string.find(self.note, '%[(%a)%]')
    if(startIndex == 1) then
        self:SetMainTeam(nil, teamInitial)
    else
        -- No team format
        local startIndex, _, guildInitials = string.find(self.note, '%[(%a+)%]')
        if(_StartIndex == 1) then
            self:SetMainTeam(guildInitials)            
        end
    end

    -- New team initial format on alt
    local startIndex, _, teamInitial, guildInitials = string.find(self.note, '%[(%a)-(%a+)')
    if(startIndex == 1) then
        self:SetMainTeam(guildInitials, teamInitial)
    else
        -- Some officer specific format
        local startIndex, _, guildInitials = string.find(self.note, '%[(%a%a-)-(%a-)%]')
        if(startIndex == 1) then
            self:SetMainTeam(guildInitials)
        end 
    end

    -- Old team initial format on alt
    local startIndex, _, guildInitials, teamInitial = string.find(self.note, '%[(%a+)%]%s?%[(%a)%]%s?')
    if(startIndex == 1) then
        self:SetMainTeam(guildInitials, teamInitial)
    end

    if(self:GetNote() == '?' and self:GetGuild():GetInitials() == 'ENK') then
        self:SetTeam(XFG.Teams:Get(self:GetGuild():GetInitials()))
    elseif(not self:HasTeam()) then
        local team = XFG.Teams:Get('U')
        self:SetTeam(team)
    end
end

function Unit:GetFaction()
    return self.faction
end

function Unit:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be a Faction object')
    self.faction = inFaction
end

function Unit:IsOnline(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isOnline = inBoolean
    end
    return self.isOnline
end

function Unit:IsOffline()
    return not self.isOnline
end

function Unit:CanGuildSpeak(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.guildSpeak = inBoolean
    end
    return self.guildSpeak
end

function Unit:CanGuildListen(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.guildListen = inBoolean
    end
    return self.guildListen
end

function Unit:GetPvP()
    return self.pvp
end

function Unit:SetPvP(inScore, inIndex)
    assert(type(inScore) == 'number')
    assert(type(inIndex) == 'number')
    self.pvp = tostring(inScore)
    if(inIndex == 1) then
        self.pvp = self.pvp .. ' (2)'
    elseif(inIndex == 2) then
        self.pvp = self.pvp .. ' (3)'
    else
        self.pvp = self.pvp .. ' (10)'
    end
end

function Unit:SetPvPString(inString)
    assert(type(inString) == 'string')
    self.pvp = inString
end

function Unit:GetAchievementPoints()
    return self.achievements
end

function Unit:SetAchievementPoints(inPoints)
    assert(type(inPoints) == 'number')
    self.achievements = inPoints
end

function Unit:HasRaidIO()
    return self.raidIO ~= nil
end

function Unit:GetRaidIO()
    return self.raidIO
end

function Unit:SetRaidIO(inRaidIO)
    assert(type(inRaidIO) == 'table' and inRaidIO.__name == 'RaidIO', 'argument must be RaidIO object')
    self.raidIO = inRaidIO
end

function Unit:HasRace()
    return self.race ~= nil
end

function Unit:GetRace()
    return self.race
end

function Unit:SetRace(inRace)
    assert(type(inRace) == 'table' and inRace.__name == 'Race', 'argument must be Race object')
    self.race = inRace
end

function Unit:GetTimeStamp()
    return self.timeStamp
end

function Unit:SetTimeStamp(inTimeStamp)
    assert(type(inTimeStamp) == 'number')
    self.timeStamp = inTimeStamp
end

function Unit:HasClass()
    return self.class ~= nil
end

function Unit:GetClass()
    return self.class
end

function Unit:SetClass(inClass)
    assert(type(inClass) == 'table' and inClass.__name == 'Class', 'argument must be Class object')
    self.class = inClass
end

function Unit:HasSpec()
    return self.spec ~= nil
end

function Unit:GetSpec()
    return self.spec
end

function Unit:SetSpec(inSpec)
    assert(type(inSpec) == 'table' and inSpec.__name == 'Spec', 'argument must be Spec object')
    self.spec = inSpec
end

function Unit:HasProfession1()
    return self.profession1 ~= nil and self.profession1:GetKey() ~= nil
end

function Unit:GetProfession1()
    return self.profession1
end

function Unit:SetProfession1(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession1 = inProfession
end

function Unit:HasProfession2()
    return self.profession2 ~= nil and self.profession2:GetKey() ~= nil
end

function Unit:GetProfession2()
    return self.profession2
end

function Unit:SetProfession2(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession2 = inProfession
end

function Unit:IsRunningAddon(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRunningAddon = inBoolean
    end
    return self.isRunningAddon
end

function Unit:HasVersion()
    return self.version ~= nil
end

function Unit:GetVersion()
    return self.version
end

function Unit:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
    self.version = inVersion
end

function Unit:IsAlt(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isAlt = inBoolean
    end
    return self.isAlt
end

function Unit:HasMainName()
    return self.mainName ~= nil
end

function Unit:GetMainName()
    return self.mainName
end

function Unit:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self.mainName = inMainName
end

function Unit:HasTeam()
    return self.team ~= nil
end

function Unit:GetTeam()
    return self.team
end

function Unit:SetTeam(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name == 'Team', 'argument must be Team object')
    self.team = inTeam
end

function Unit:HasRealm()
    return self.realm ~= nil
end

function Unit:GetRealm()
    return self.realm
end

function Unit:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
end

function Unit:HasGuild()
    return self.guild ~= nil
end

function Unit:GetGuild()
    return self.guild
end

function Unit:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
    self.guild = inGuild
end

function Unit:GetItemLevel()
    return self.itemLevel
end

function Unit:SetItemLevel(inItemLevel)
    assert(type(inItemLevel) == 'number')
    self.itemLevel = inItemLevel
end

function Unit:IsSameFaction()
    return XFG.Player.Faction:Equals(self:GetFaction())
end

function Unit:GetLink()
    if(XFG.Player.Faction:Equals(self:GetFaction())) then
        return format('player:%s', self:GetUnitName())
    end

    local friend = XFG.Friends:GetByRealmUnitName(self:GetRealm(), self:GetName())
    if(friend ~= nil) then
        return format('BNplayer:%s:%d:0:WHISPER:%s', friend:GetAccountName(), friend:GetAccountID(), friend:GetName())
    end

    return format('player:%s', self:GetUnitName())
end

function Unit:Broadcast(inSubject)
    assert(type(inSubject) == 'string' or inSubject == nil)
	if(inSubject == nil) then inSubject = XFG.Settings.Network.Message.Subject.DATA end
    -- Update the last sent time, dont need to heartbeat for awhile
    if(self:IsPlayer()) then
        local epoch = ServerTime()
        if(XFG.Player.LastBroadcast > epoch - XFG.Settings.Player.MinimumHeartbeat) then 
            XFG:Debug(ObjectName, 'Not sending broadcast, its been too recent')
            return 
        end
        self:SetTimeStamp(epoch)
        XFG.Player.LastBroadcast = self:GetTimeStamp()
    end
    local message = nil
    try(function ()
        message = XFG.Mailbox.Chat:Pop()
        message:Initialize()
        message:SetFrom(XFG.Player.Unit:GetKey())
        message:SetType(XFG.Settings.Network.Type.BROADCAST)
        message:SetSubject(inSubject)
        message:SetData(self)
        XFG.Mailbox.Chat:Send(message)
    end).
    finally(function ()
        XFG.Mailbox.Chat:Push(message)
    end)
end

-- Usually a key check is enough for equality check, but use case is to detect any data differences
function Unit:Equals(inUnit)
    if(inUnit == nil) then return false end
    if(type(inUnit) ~= 'table' or inUnit.__name == nil or inUnit.__name ~= 'Unit') then return false end

    if(self:GetKey() ~= inUnit:GetKey()) then return false end
    if(self:GetGUID() ~= inUnit:GetGUID()) then return false end
    if(self:GetID() ~= inUnit:GetID()) then return false end
    if(self:GetLevel() ~= inUnit:GetLevel()) then return false end
    if(self:GetZone() ~= inUnit:GetZone()) then return false end
    if(self:GetNote() ~= inUnit:GetNote()) then return false end
    if(self:IsOnline() ~= inUnit:IsOnline()) then return false end
    if(self:GetAchievementPoints() ~= inUnit:GetAchievementPoints()) then return false end    
    if(self:IsRunningAddon() ~= inUnit:IsRunningAddon()) then return false end
    if(self:IsAlt() ~= inUnit:IsAlt()) then return false end
    if(self:GetMainName() ~= inUnit:GetMainName()) then return false end
    if(self:GetRank() ~= inUnit:GetRank()) then return false end
    if(self:GetItemLevel() ~= inUnit:GetItemLevel()) then return false end
    if(self:GetPvP() ~= inUnit:GetPvP()) then return false end

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

    if(self:HasSpec() == false and inUnit:HasSpec()) then return false end
    if(self:HasSpec()) then
        local _CachedSpec = self:GetSpec()
        if(_CachedSpec:Equals(inUnit:GetSpec()) == false) then return false end
    end

    if(not self:HasRaidIO() and inUnit:HasRaidIO()) then return false end
    if(self:HasRaidIO() and not inUnit:HasRaidIO()) then return false end
	if(self:HasRaidIO() and not self:GetRaidIO():Equals(inUnit:GetRaidIO())) then return false end
    
    -- Do not consider TimeStamp
    -- A unit cannot change Class, do not consider
	-- A unit cannot change Race while logged in, do not consider
	-- A unit cannot change Name/UnitName while logged in, do not consider
	-- A unit cannot change GUID while logged in, but it is the key so consider
    
    return true
end

function Unit:FactoryReset()
    self:ParentFactoryReset()
    self.guid = nil
    self.unitName = nil
    self.ID = 0
    self.rank = nil
    self.level = 60
    self.class = nil
    self.spec = nil
    self.zone = nil
    self.zoneName = nil
    self.note = nil
    self.isOnline = false
    self.race = nil
    self.timeStamp = nil
    self.profession1 = nil
    self.profession2 = nil
    self.achievements = 0
    self.isRunningAddon = false
    self.isAlt = false
    self.mainName = nil
    self.isPlayer = false
    self.faction = nil
    self.team = nil
    self.guild = nil
    self.realm = nil
    self.version = nil
    self.itemLevel = 0
    self.pvp = ''
    self.guildSpeak = true
    self.guildListen = true
    self.raidIO = nil
end
