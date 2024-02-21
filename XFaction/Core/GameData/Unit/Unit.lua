local XF, G = unpack(select(2, ...))GetCurrent
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
    object.spec = nil
    object.zone = nil
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

function XFC.Unit:newChildConstructor()
    local object = XFC.Unit.parent.new(self)
    object.__name = ObjectName
    object.guid = nil
    object.unitName = nil    
    object.rank = nil
    object.level = 70
    object.spec = nil
    object.zone = nil
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

function XFC.Unit:Deconstructor()
    self:ParentDeconstructor()
    self.guid = nil
    self.unitName = nil
    self.rank = nil
    self.level = 60
    self.spec = nil
    self.zone = nil
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
function XFC.Unit:Initialize(inMemberID)
    assert(type(inMemberID) == 'number' or inMemberID == nil)
    local unitData
    if(inMemberID ~= nil) then
        unitData = XFF.GuildGetMember(XF.Player.Guild:GetID(), inMemberID)
    else
        unitData = XFF.GuildGetMyself(XF.Player.Guild:GetID())
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
    self:SetTimeStamp(XFF.TimeGetCurrent())
    self:SetSpec(XFO.Specs:GetInitialClassSpec(unitData.classID))
    self:SetRace(XFO.Races:Get(unitData.race))
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

    XFO.Zones:Add(unitData.zone)
    self:SetZone(XFO.Zones:Get(unitData.zone))

    if(unitData.profession1ID ~= nil) then
        self:SetProfession1(XFO.Professions:Get(unitData.profession1ID))
    end

    if(unitData.profession2ID ~= nil) then
        self:SetProfession2(XFO.Professions:Get(unitData.profession2ID))
    end

    local raiderIO = XFO.RaiderIO:Get(self)
    if(raiderIO ~= nil) then
        self:SetRaiderIO(raiderIO)
    end

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        self:SetVersion(XFO.Versions:GetCurrent())
        
        if(XFO.Keys:HasMyKey()) then
            self:SetMythicKey(XFO.Keys:GetMyKey())
        end

        local permissions = XFF.GuildGetPermissions(unitData.guildRankOrder)
        if(permissions ~= nil) then
            self:CanGuildListen(permissions[1])
            self:CanGuildSpeak(permissions[2])
        end
        
        local itemLevel = XFF.ItemGetIlvl()
        if(type(itemLevel) == 'number') then
            itemLevel = math.floor(itemLevel)
            self:SetItemLevel(itemLevel)
        end

        -- The following call will randomly fail, retries seem to help
        for i = 1, 10 do
            local specGroupID = XFF.SpecGetGroupID()
            if(specGroupID ~= nil) then
    	        local specID = XFF.SpecGetID(specGroupID)
                if(specID ~= nil and XFO.Specs:Contains(specID)) then
                    self:SetSpec(XFO.Specs:Get(specID))
                    break
                end
            end
        end        

        -- Highest PvP rating wins
        local highestRating = 0
        local highestIndex = 1
        for i = 1, 3 do
            local pvpRating = XFF.PvPGetRating(i)
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
function XFC.Unit:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
    XF:Debug(self:GetObjectName(), '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
    XF:Debug(self:GetObjectName(), '  rank (' .. type(self.rank) .. '): ' .. tostring(self.rank))
    XF:Debug(self:GetObjectName(), '  level (' .. type(self.level) .. '): ' .. tostring(self.level))
    XF:Debug(self:GetObjectName(), '  note (' .. type(self.note) .. '): ' .. tostring(self.note))
    XF:Debug(self:GetObjectName(), '  presence (' .. type(self.presence) .. '): ' .. tostring(self.presence))
    XF:Debug(self:GetObjectName(), '  achievements (' .. type(self.achievements) .. '): ' .. tostring(self.achievements))
    XF:Debug(self:GetObjectName(), '  timeStamp (' .. type(self.timeStamp) .. '): ' .. tostring(self.timeStamp))
    XF:Debug(self:GetObjectName(), '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(self:GetObjectName(), '  isAlt (' .. type(self.isAlt) .. '): ' .. tostring(self.isAlt))
    XF:Debug(self:GetObjectName(), '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(self:GetObjectName(), '  isPlayer (' .. type(self.isPlayer) .. '): ' .. tostring(self.isPlayer))
    XF:Debug(self:GetObjectName(), '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
    XF:Debug(self:GetObjectName(), '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
    XF:Debug(self:GetObjectName(), '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
    XF:Debug(self:GetObjectName(), '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
    if(self:HasZone()) then self:GetZone():Print() end
    if(self:HasVersion()) then self.version:Print() end
    if(self:HasGuild()) then self.guild:Print() end
    if(self:HasTeam()) then self.team:Print() end
    if(self:HasRace()) then self.race:Print() end
    if(self:HasSpec()) then self.spec:Print() end
    if(self:HasProfession1()) then self.profession1:Print() end
    if(self:HasProfession2()) then self.profession2:Print() end  
    if(self:HasRaiderIO()) then self:GetRaiderIO():Print() end
    if(self:HasMythicKey()) then self:GetMythicKey():Print() end
end
--#endregion

--#region Accessors
function XFC.Unit:IsPlayer(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isPlayer = inBoolean
    end
    return self.isPlayer
end

function XFC.Unit:GetGUID()
    return self.guid
end

function XFC.Unit:SetGUID(inGUID)
    assert(type(inGUID) == 'string')
    self.guid = inGUID
    self:IsPlayer(self:GetGUID() == XF.Player.GUID)
end

function XFC.Unit:GetUnitName()
    return self.unitName
end

function XFC.Unit:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self.unitName = inUnitName
end

function XFC.Unit:GetRank()
    return self.rank
end

function XFC.Unit:SetRank(inRank)
    assert(type(inRank) == 'string')
    self.rank = inRank
end

function XFC.Unit:GetLevel()
    return self.level
end

function XFC.Unit:SetLevel(inLevel)
    assert(type(inLevel) == 'number')
    self.level = inLevel
end

function XFC.Unit:HasZone()
    return self.zone
end

function XFC.Unit:GetZone()
    return self.zone
end

function XFC.Unit:SetZone(inZone)
    assert(type(inZone) == 'table' and inZone.__name ~= nil and inZone.__name == 'Zone', 'argument must be Zone object')
    self.zone = inZone
end

function XFC.Unit:GetNote()
    return self.note
end

function XFC.Unit:SetMainTeam(inGuildInitials, inTeamInitial)
    if(inTeamInitial ~= nil and XFO.Teams:Contains(inTeamInitial)) then
        self:SetTeam(XFO.Teams:Get(inTeamInitial))
    end    
    local _, _, mainName = string.find(self.note, '%s+([^%s%[%]]+)%s?')
    if(mainName ~= nil) then
        self:IsAlt(true)
        self:SetMainName(mainName)
    end                
end

function XFC.Unit:SetNote(inNote)
    assert(type(inNote) == 'string')
    self.note = inNote

    try(function()

        -- Team tag
        local _, _, teamInitial = string.find(self.note, '%[XFt:(%a-)%]')
        if(teamInitial ~= nil and XFO.Teams:Contains(teamInitial)) then
            self:SetTeam(XFO.Teams:Get(teamInitial))
        else
            local _, _, teamInitial = string.find(self.note, '%[(%a-)%]')
            if(teamInitial ~= nil and XFO.Teams:Contains(teamInitial)) then
                self:SetTeam(XFO.Teams:Get(teamInitial))
            else
                local _, _, teamInitial, guildInitials = string.find(self.note, '%[(%a-)-(%a+)')
                if(teamInitial ~= nil and XFO.Teams:Contains(teamInitial)) then
                    self:SetTeam(XFO.Teams:Get(teamInitial))
                end
                if(guildInitials ~= nil and XFO.Guilds:Contains(guildInitials) and not self:GetGuild():Equals(XFO.Guilds:Get(guildInitials))) then
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
        XF:Trace(self:GetObjectName(), 'Failed to parse player note: [' .. self:GetNote() .. ']')
        XF:Trace(self:GetObjectName(), inErrorMessage)
    end).
    finally(function()
        if(not self:HasTeam()) then
            self:SetTeam(XFO.Teams:Get('?'))
        end
    end)
end

function XFC.Unit:GetPresence()
    return self.presence
end

function XFC.Unit:SetPresence(inPresence)
    assert(type(inPresence) == 'number')
    self.presence = inPresence
end

function XFC.Unit:IsOnline()
    return self:GetPresence() == Enum.ClubMemberPresence.Online or 
           self:GetPresence() == Enum.ClubMemberPresence.Away or 
           self:GetPresence() == Enum.ClubMemberPresence.Busy
end

function XFC.Unit:IsOffline()
    return not self:IsOnline()
end

function XFC.Unit:CanGuildSpeak(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.guildSpeak = inBoolean
    end
    return self.guildSpeak
end

function XFC.Unit:CanGuildListen(inBoolean)
    assert(inBoolean == nil or type(inBoolean == 'boolean'), 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.guildListen = inBoolean
    end
    return self.guildListen
end

function XFC.Unit:GetPvP()
    return self.pvp
end

function XFC.Unit:SetPvP(inScore, inIndex)
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

function XFC.Unit:SetPvPString(inString)
    assert(type(inString) == 'string')
    self.pvp = inString
end

function XFC.Unit:GetAchievementPoints()
    return self.achievements
end

function XFC.Unit:SetAchievementPoints(inPoints)
    assert(type(inPoints) == 'number')
    self.achievements = inPoints
end

function XFC.Unit:HasRaiderIO()
    return self.raiderIO ~= nil
end

function XFC.Unit:GetRaiderIO()
    return self.raiderIO
end

function XFC.Unit:SetRaiderIO(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name == 'RaiderIO', 'argument must be RaiderIO object')
    self.raiderIO = inRaiderIO
end

function XFC.Unit:HasRace()
    return self.race ~= nil
end

function XFC.Unit:GetRace()
    return self.race
end

function XFC.Unit:SetRace(inRace)
    assert(type(inRace) == 'table' and inRace.__name == 'Race', 'argument must be Race object')
    self.race = inRace
end

function XFC.Unit:GetTimeStamp()
    return self.timeStamp
end

function XFC.Unit:SetTimeStamp(inTimeStamp)
    assert(type(inTimeStamp) == 'number')
    self.timeStamp = inTimeStamp
end

function XFC.Unit:HasSpec()
    return self.spec ~= nil
end

function XFC.Unit:GetSpec()
    return self.spec
end

function XFC.Unit:SetSpec(inSpec)
    assert(type(inSpec) == 'table' and inSpec.__name == 'Spec', 'argument must be Spec object')
    self.spec = inSpec
end

function XFC.Unit:HasProfession1()
    return self.profession1 ~= nil and self.profession1:GetKey() ~= nil
end

function XFC.Unit:GetProfession1()
    return self.profession1
end

function XFC.Unit:SetProfession1(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession1 = inProfession
end

function XFC.Unit:HasProfession2()
    return self.profession2 ~= nil and self.profession2:GetKey() ~= nil
end

function XFC.Unit:GetProfession2()
    return self.profession2
end

function XFC.Unit:SetProfession2(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession2 = inProfession
end

function XFC.Unit:IsRunningAddon(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRunningAddon = inBoolean
    end
    return self.isRunningAddon
end

function XFC.Unit:HasVersion()
    return self.version ~= nil
end

function XFC.Unit:GetVersion()
    return self.version
end

function XFC.Unit:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
    self.version = inVersion
end

function XFC.Unit:IsAlt(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isAlt = inBoolean
    end
    return self.isAlt
end

function XFC.Unit:HasMainName()
    return self.mainName ~= nil
end

function XFC.Unit:GetMainName()
    return self.mainName
end

function XFC.Unit:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self.mainName = inMainName
end

function XFC.Unit:HasTeam()
    return self.team ~= nil
end

function XFC.Unit:GetTeam()
    return self.team
end

function XFC.Unit:SetTeam(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name == 'Team', 'argument must be Team object')
    self.team = inTeam
end

function XFC.Unit:HasGuild()
    return self.guild ~= nil
end

function XFC.Unit:GetGuild()
    return self.guild
end

function XFC.Unit:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
    self.guild = inGuild
end

function XFC.Unit:GetItemLevel()
    return self.itemLevel
end

function XFC.Unit:SetItemLevel(inItemLevel)
    assert(type(inItemLevel) == 'number')
    self.itemLevel = inItemLevel
end

function XFC.Unit:IsSameFaction(inUnit)
    return inUnit:GetRace():GetFaction():Equals(self:GetRace():GetFaction())
end

function XFC.Unit:GetLink()
    if(self:IsSameFaction(XF.Player.Unit)) then
        return format('player:%s', self:GetUnitName())
    end

    local friend = XFO.Friends:GetByRealmUnitName(self:GetGuild():GetRealm(), self:GetName())
    if(friend ~= nil) then
        return format('BNplayer:%s:%d:0:WHISPER:%s', friend:GetAccountName(), friend:GetAccountID(), friend:GetName())
    end

    return format('player:%s', self:GetUnitName())
end

function XFC.Unit:GetLastLogin()
    return self.lastLogin
end

function XFC.Unit:SetLastLogin(inDays)
    assert(type(inDays) == 'number')
    self.lastLogin = inDays
end

function XFC.Unit:HasMythicKey()
    return self.mythicKey ~= nil
end

function XFC.Unit:GetMythicKey()
    return self.mythicKey
end

function XFC.Unit:SetMythicKey(inKey)
    assert(type(inKey) == 'table' and inKey.__name ~= nil and inKey.__name == 'MythicKey', 'argument must be MythicKey object')
    self.mythicKey = inKey
end
--#endregion

--#region Network
function XFC.Unit:Broadcast(inSubject)
    assert(type(inSubject) == 'string' or inSubject == nil)
	if(inSubject == nil) then inSubject = XF.Enum.Message.DATA end
    
    local message = nil
    try(function ()
        message = XFO.Chat:Pop()
        message:SetType(XF.Enum.Network.BROADCAST)
        message:SetSubject(inSubject)
        XFO.Chat:Send(message)
    end).
    finally(function ()
        XFO.Chat:Push(message)
    end)
end

function XFC.Unit:Serialize()
	local data = {}
	
	data.A = self:GetAchievementPoints()
    data.C = self:GetRank()
    data.G = self:GetGuild():GetKey()
    data.I = self:GetItemLevel()
    data.K = self:GetGUID()	
    data.L = self:GetLevel()
    data.M = self:HasMythicKey() and self:GetMythicKey():Serialize() or nil
    data.N = self:GetNote()
    data.P = self:GetPresence()
    data.R = self:GetRace():GetKey()
    data.S = self:GetSpec():GetKey()
    data.U = self:GetUnitName()
    data.V = self:GetVersion():GetKey()
    data.W = self:HasProfession1() and self:GetProfession1():GetKey() or nil
    data.X = self:HasProfession2() and self:GetProfession2():GetKey() or nil
    data.Y = self:GetPvP()
    data.Z = self:GetZone():GetKey()

	return pickle(data)
end

function XFC.Unit:Deserialize(inSerialized)
	local deserialized = unpickle(inSerialized)

    self:IsRunningAddon(true)
    self:IsOnline(true)

    self:SetAchievementPoints(deserialized.A)
    self:SetRank(deserialized.C)
    self:SetGuild(XFO.Guilds:Get(deserialized.G))
    self:SetItemLevel(deserialized.I)
    self:SetGUID(deserialized.K)
    self:SetKey(deserialized.K)
    self:SetLevel(deserialized.L)

    if(deserializedData.M ~= nil) then
		local key = XFC.MythicKey:new(); key:Initialize()
		key:Deserialize(deserializedData.M)
		self:SetMythicKey(key)
	end

    self:SetNote(deserialized.N)
    self:SetPresence(tonumber(deserialized.P))
	self:SetRace(XFO.Races:Get(deserialized.R))
    self:SetSpec(XFO.Specs:Get(deserialized.V))
    self:SetUnitName(deserialized.U)

    local unitNameParts = string.Split(deserialized.U, '-')
	self:SetName(unitNameParts[1])  

    XFO.Versions:Add(deserialized.V)
    self:SetVersion(XFO.Versions:Get(deserialized.V))

	if(deserialized.W ~= nil) then
		self:SetProfession1(XFO.Professions:Get(deserialized.W))
	end
	if(deserialized.X ~= nil) then
		self:SetProfession2(XFO.Professions:Get(deserialized.X))
	end
    
    self:SetPvPString(deserialized.Y)

    XFO.Zones:Add(deserialized.Z)
    self:SetZone(XFO.Zones:Get(deserialized.Z))
end
--#endregion

--#region Operators
-- Usually a key check is enough for equality check, but use case is to detect any data differences
function XFC.Unit:Equals(inUnit)
    if(inUnit == nil) then return false end
    if(type(inUnit) ~= 'table' or inUnit.__name == nil or inUnit.__name ~= 'Unit') then return false end

    if(self:GetKey() ~= inUnit:GetKey()) then return false end
    if(self:GetGUID() ~= inUnit:GetGUID()) then return false end
    if(self:GetPresence() ~= inUnit:GetPresence()) then return false end
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