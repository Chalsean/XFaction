local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
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

--#region Constructors
function Unit:new()
    local object = Unit.parent.new(self)
    object.__name = ObjectName

    -- Note player ID is unique to a guild, not globally
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
    object.isAlt = false
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

    return object
end

function Unit:Deconstructor()
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
    self.isAlt = false
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
end
--#endregion

--#region Initializers
function Unit:Initialize(inMemberID)
    assert(type(inMemberID) == 'number' or inMemberID == nil)
    local unitData
    if(inMemberID ~= nil) then
        unitData = GetMemberInfo(XF.Player.Guild:GetID(), inMemberID)
    else
        unitData = GetMemberInfoForSelf(XF.Player.Guild:GetID())
    end

    -- Failure conditions:
    --   Sometimes fails on initial login
    --   guildRank is nil during a zone transition
    --   Unknown presence means dont know if online or offline
    if(unitData == nil or unitData.guildRank == nil or unitData.presence == Enum.ClubMemberPresence.Unknown) then
        self:IsInitialized(false)
        return
    end

    self:SetGUID(unitData.guid)
    self:SetKey(self:GetGUID())
    self:SetPresence(unitData.presence)    
    self:SetID(unitData.memberId)
    self:SetName(unitData.name)
    self:SetUnitName(unitData.name .. '-' .. XF.Player.Guild:GetRealm():GetAPIName())
	self:SetLevel(unitData.level)	
	self:SetGuild(XF.Player.Guild)
    self:SetTimeStamp(ServerTime())
    self:SetClass(XF.Classes:Get(unitData.classID))
    self:SetRace(XF.Races:Get(unitData.race))
    self:SetRank(unitData.guildRank)
    self:SetNote(unitData.memberNote or '?')
    self:IsPlayer(unitData.isSelf)
    self:SetAchievementPoints(unitData.achievementPoints or 0)

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
    self:SetLastLogin(lastLogin)

    if(self:IsPlayer()) then
        self:SetFaction(XF.Player.Faction)
    elseif(unitData.faction == Enum.PvPFaction.Alliance) then
        self:SetFaction(XF.Factions:GetByName('Alliance'))
    elseif(unitData.faction == Enum.PvPFaction.Horde) then
        self:SetFaction(XF.Factions:GetByName('Horde'))
    else
        self:SetFaction(XF.Factions:GetByName('Neutral'))
    end

    if(unitData.zone and XF.Zones:Contains(unitData.zone)) then
        self:SetZone(XF.Zones:Get(unitData.zone))
    elseif(unitData.zone and strlen(unitData.zone)) then
        XF.Zones:AddZone(unitData.zone)
        self:SetZone(XF.Zones:Get(unitData.zone))
    else
        self:SetZone(XF.Zones:Get('?'))
    end

    if(unitData.profession1ID ~= nil) then
        self:SetProfession1(XF.Professions:Get(unitData.profession1ID))
    end

    if(unitData.profession2ID ~= nil) then
        self:SetProfession2(XF.Professions:Get(unitData.profession2ID))
    end

    local raiderIO = XF.Addons.RaiderIO:Get(self)
    if(raiderIO ~= nil) then
        self:SetRaiderIO(raiderIO)
    end

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        self:SetVersion(XF.Version)
        
        local mythicKey = XFC.MythicKey:new()
        mythicKey:Initialize()
        mythicKey:Refresh()
        self:SetMythicKey(mythicKey)

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
                if(specID ~= nil and XF.Specs:Contains(specID)) then
                    self:SetSpec(XF.Specs:Get(specID))
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
--#endregion

--#region Print
function Unit:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
    XF:Debug(ObjectName, '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
    XF:Debug(ObjectName, '  rank (' .. type(self.rank) .. '): ' .. tostring(self.rank))
    XF:Debug(ObjectName, '  level (' .. type(self.level) .. '): ' .. tostring(self.level))
    XF:Debug(ObjectName, '  note (' .. type(self.note) .. '): ' .. tostring(self.note))
    XF:Debug(ObjectName, '  presence (' .. type(self.presence) .. '): ' .. tostring(self.presence))
    XF:Debug(ObjectName, '  achievements (' .. type(self.achievements) .. '): ' .. tostring(self.achievements))
    XF:Debug(ObjectName, '  timeStamp (' .. type(self.timeStamp) .. '): ' .. tostring(self.timeStamp))
    XF:Debug(ObjectName, '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(ObjectName, '  isAlt (' .. type(self.isAlt) .. '): ' .. tostring(self.isAlt))
    XF:Debug(ObjectName, '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(ObjectName, '  isPlayer (' .. type(self.isPlayer) .. '): ' .. tostring(self.isPlayer))
    XF:Debug(ObjectName, '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
    XF:Debug(ObjectName, '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
    XF:Debug(ObjectName, '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
    XF:Debug(ObjectName, '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
    if(self:HasZone()) then 
        self:GetZone():Print()
    else
        XF:Debug(ObjectName, '  zoneName (' .. type(self.zoneName) .. '): ' .. tostring(self.zoneName))
    end
    if(self:HasVersion()) then self.version:Print() end
    if(self:HasGuild()) then self.guild:Print() end
    if(self:HasTeam()) then self.team:Print() end
    if(self:HasRace()) then self.race:Print() end
    if(self:HasClass()) then self.class:Print() end
    if(self:HasSpec()) then self.spec:Print() end
    if(self:HasProfession1()) then self.profession1:Print() end
    if(self:HasProfession2()) then self.profession2:Print() end  
    if(self:HasRaiderIO()) then self:GetRaiderIO():Print() end
    if(self:HasMythicKey()) then self:GetMythicKey():Print() end
end
--#endregion

--#region Accessors
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
    self:IsPlayer(self:GetGUID() == XF.Player.GUID)
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
    if(inTeamInitial ~= nil and XF.Teams:Contains(inTeamInitial)) then
        self:SetTeam(XF.Teams:Get(inTeamInitial))
    end    
    local _, _, mainName = string.find(self.note, '%s+([^%s%[%]]+)%s?')
    if(mainName ~= nil) then
        self:IsAlt(true)
        self:SetMainName(mainName)
    end                
end

function Unit:SetNote(inNote)
    assert(type(inNote) == 'string')
    self.note = inNote

    try(function()

        -- Team tag
        local _, _, teamInitial = string.find(self.note, '%[XFt:(%a-)%]')
        if(teamInitial ~= nil and XF.Teams:Contains(teamInitial)) then
            self:SetTeam(XF.Teams:Get(teamInitial))
        else
            local _, _, teamInitial = string.find(self.note, '%[(%a-)%]')
            if(teamInitial ~= nil and XF.Teams:Contains(teamInitial)) then
                self:SetTeam(XF.Teams:Get(teamInitial))
            else
                local _, _, teamInitial, guildInitials = string.find(self.note, '%[(%a-)-(%a+)')
                if(teamInitial ~= nil and XF.Teams:Contains(teamInitial)) then
                    self:SetTeam(XF.Teams:Get(teamInitial))
                end
                if(guildInitials ~= nil and XF.Guilds:Contains(guildInitials) and not self:GetGuild():Equals(XF.Guilds:Get(guildInitials))) then
                    self:IsAlt(true)
                    local _, _, mainName = string.find(self.note, '%s+([^%s%[%]]+)%s?')
                    if(mainName ~= nil) then           
                        self:SetMainName(mainName)
                    end
                end 
            end
        end

        -- Alt tag
        local _, _, altName = string.find(self.note, '%[XFa:([^%s%[%]]-)%]')
        if(altName ~= nil) then
            self:IsAlt(true)
            self:SetMainName(altName)
        end
    end).
    catch(function(inErrorMessage)
        XF:Trace(ObjectName, 'Failed to parse player note: [' .. self:GetNote() .. ']')
        XF:Trace(ObjectName, inErrorMessage)
    end).
    finally(function()
        if(not self:HasTeam()) then
            self:SetTeam(XF.Teams:Get('?'))
        end
    end)
end

function Unit:GetFaction()
    return self.faction
end

function Unit:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be a Faction object')
    self.faction = inFaction
end

function Unit:GetPresence()
    return self.presence
end

function Unit:SetPresence(inPresence)
    assert(type(inPresence) == 'number')
    self.presence = inPresence
end

function Unit:IsOnline()
    return self:GetPresence() == Enum.ClubMemberPresence.Online or 
           self:GetPresence() == Enum.ClubMemberPresence.Away or 
           self:GetPresence() == Enum.ClubMemberPresence.Busy
end

function Unit:IsOffline()
    return not self:IsOnline()
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

function Unit:HasRaiderIO()
    return self.raiderIO ~= nil
end

function Unit:GetRaiderIO()
    return self.raiderIO
end

function Unit:SetRaiderIO(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name == 'RaiderIO', 'argument must be RaiderIO object')
    self.raiderIO = inRaiderIO
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
    return XF.Player.Faction:Equals(self:GetFaction())
end

function Unit:GetLink()
    if(XF.Player.Faction:Equals(self:GetFaction())) then
        return format('player:%s', self:GetUnitName())
    end

    local friend = XF.Friends:GetByRealmUnitName(self:GetGuild():GetRealm(), self:GetName())
    if(friend ~= nil) then
        return format('BNplayer:%s:%d:0:WHISPER:%s', friend:GetAccountName(), friend:GetAccountID(), friend:GetName())
    end

    return format('player:%s', self:GetUnitName())
end

function Unit:GetLastLogin()
    return self.lastLogin
end

function Unit:SetLastLogin(inDays)
    assert(type(inDays) == 'number')
    self.lastLogin = inDays
end

function Unit:HasMythicKey()
    return self.mythicKey ~= nil
end

function Unit:GetMythicKey()
    return self.mythicKey
end

function Unit:SetMythicKey(inKey)
    assert(type(inKey) == 'table' and inKey.__name ~= nil and inKey.__name == 'MythicKey', 'argument must be MythicKey object')
    self.mythicKey = inKey
end
--#endregion

--#region Network
function Unit:Broadcast(inSubject)
    assert(type(inSubject) == 'string' or inSubject == nil)
	if(inSubject == nil) then inSubject = XF.Enum.Message.DATA end
    -- Update the last sent time, dont need to heartbeat for awhile
    if(self:IsPlayer()) then
        local epoch = ServerTime()
        if(XF.Player.LastBroadcast > epoch - XF.Settings.Player.MinimumHeartbeat) then 
            XF:Debug(ObjectName, 'Not sending broadcast, its been too recent')
            return 
        end
        self:SetTimeStamp(epoch)
        XF.Player.LastBroadcast = self:GetTimeStamp()
    end
    local message = nil
    try(function ()
        message = XF.Mailbox.Chat:Pop()
        message:Initialize()
        message:SetFrom(self:GetGUID())
        message:SetGuild(self:GetGuild())
        message:SetUnitName(self:GetName())
        message:SetType(XF.Enum.Network.BROADCAST)
        message:SetSubject(inSubject)
        message:SetData(self)
        XF.Mailbox.Chat:Send(message)
    end).
    finally(function ()
        XF.Mailbox.Chat:Push(message)
    end)
end
--#endregion

--#region Operators
-- Usually a key check is enough for equality check, but use case is to detect any data differences
function Unit:Equals(inUnit)
    if(inUnit == nil) then return false end
    if(type(inUnit) ~= 'table' or inUnit.__name == nil or inUnit.__name ~= 'Unit') then return false end

    if(self:GetKey() ~= inUnit:GetKey()) then return false end
    if(self:GetGUID() ~= inUnit:GetGUID()) then return false end
    if(self:GetPresence() ~= inUnit:GetPresence()) then return false end
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

    if(not self:HasProfession1() and inUnit:HasProfession1()) then return false end
    if(self:HasProfession1() and not self:GetProfession1():Equals(inUnit:GetProfession1())) then return false end

    if(not self:HasProfession2() and inUnit:HasProfession2()) then return false end
    if(self:HasProfession2() and not self:GetProfession2():Equals(inUnit:GetProfession2())) then return false end

    if(not self:HasSpec() and inUnit:HasSpec()) then return false end
    if(self:HasSpec() and not self:GetSpec():Equals(inUnit:GetSpec())) then return false end

    if(not self:HasRaiderIO() and inUnit:HasRaiderIO()) then return false end
    if(self:HasRaiderIO() and not inUnit:HasRaiderIO()) then return false end
	if(self:HasRaiderIO() and not self:GetRaiderIO():Equals(inUnit:GetRaiderIO())) then return false end
    
    -- Do not consider TimeStamp
    -- A unit cannot change Class, do not consider
	-- A unit cannot change Race while logged in, do not consider
	-- A unit cannot change Name/UnitName while logged in, do not consider
	-- A unit cannot change GUID while logged in, but it is the key so consider
    
    return true
end
--#endregion