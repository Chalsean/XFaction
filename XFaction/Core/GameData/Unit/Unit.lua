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
    self.isAlt = false
    self.mainName = nil
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
    self:Key(self:GUID())
    self:Presence(unitData.presence)    
    self:ID(unitData.memberId)
    self:Name(unitData.name)
    self:UnitName(unitData.name .. '-' .. XF.Player.Realm:APIName())
	self:Level(unitData.level)	
	self:SetGuild(XF.Player.Guild)
    self:TimeStamp(XFF.TimeCurrent())
    self:SetClass(XFO.Classes:Get(unitData.classID))
    self:Race(XFO.Races:Get(unitData.race))
    self:Rank(unitData.guildRank)
    self:SetNote(unitData.memberNote or '?')
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
        self:SetFaction(XFO.Factions:Get('Alliance'))
    elseif(unitData.faction == Enum.PvPFaction.Horde) then
        self:SetFaction(XFO.Factions:Get('Horde'))
    else
        self:SetFaction(XFO.Factions:Get('Neutral'))
    end

    if(unitData.zone and XFO.Zones:Contains(unitData.zone)) then
        self:Zone(XFO.Zones:Get(unitData.zone))
    elseif(unitData.zone and strlen(unitData.zone)) then
        XFO.Zones:Add(unitData.zone)
        self:Zone(XFO.Zones:Get(unitData.zone))
    else
        self:Zone(XFO.Zones:Get('?'))
    end

    if(unitData.profession1ID ~= nil) then
        self:SetProfession1(XFO.Professions:Get(unitData.profession1ID))
    end

    if(unitData.profession2ID ~= nil) then
        self:SetProfession2(XFO.Professions:Get(unitData.profession2ID))
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

        local permissions = XFF.GuildMyPermissions(unitData.guildRankOrder)
        if(permissions ~= nil) then
            self:CanGuildListen(permissions[1])
            self:CanGuildSpeak(permissions[2])
        end
        
        local itemLevel = XFF.PlayerIlvl()
        if(type(itemLevel) == 'number') then
            itemLevel = math.floor(itemLevel)
            self:SetItemLevel(itemLevel)
        end

        -- The following call will randomly fail, retries seem to help
        for i = 1, 10 do
            local specGroupID = XFF.SpecGroupID()
            if(specGroupID ~= nil) then
    	        local specID = XFF.SpecID(specGroupID)
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
            local pvpRating = XFF.PlayerPvPRating(i)
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

function XFC.Unit:Zone(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone' or inZone == nil)
    if(inZone ~= nil) then
        self.zone = inZone
    end
    return self.zone
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
    XF:Debug(self:ObjectName(), '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
    XF:Debug(self:ObjectName(), '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
    XF:Debug(self:ObjectName(), '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
    XF:Debug(self:ObjectName(), '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
    if(self:HasZone()) then 
        self:Zone():Print()
    else
        XF:Debug(self:ObjectName(), '  zoneName (' .. type(self.zoneName) .. '): ' .. tostring(self.zoneName))
    end
    if(self:HasVersion()) then self.version:Print() end
    if(self:HasGuild()) then self.guild:Print() end
    if(self:HasTeam()) then self.team:Print() end
    if(self:HasRace()) then self:Race():Print() end
    if(self:HasClass()) then self.class:Print() end
    if(self:HasSpec()) then self.spec:Print() end
    if(self:HasProfession1()) then self.profession1:Print() end
    if(self:HasProfession2()) then self.profession2:Print() end  
    if(self:HasRaiderIO()) then self:GetRaiderIO():Print() end
    if(self:HasMythicKey()) then self:GetMythicKey():Print() end
end

function XFC.Unit:IsPlayer()
    return self:GUID() == XF.Player.GUID
end

function XFC.Unit:HasZone()
    return self.zone ~= nil
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
    return self.race ~= nil
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
        XF:Trace(self:ObjectName(), 'Failed to parse player note: [' .. self:GetNote() .. ']')
        XF:Trace(self:ObjectName(), inErrorMessage)
    end).
    finally(function()
        if(not self:HasTeam()) then
            self:SetTeam(XFO.Teams:Get('?'))
        end
    end)
end

function XFC.Unit:GetFaction()
    return self.faction
end

function XFC.Unit:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be a Faction object')
    self.faction = inFaction
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




function XFC.Unit:HasClass()
    return self.class ~= nil
end

function XFC.Unit:GetClass()
    return self.class
end

function XFC.Unit:SetClass(inClass)
    assert(type(inClass) == 'table' and inClass.__name == 'Class', 'argument must be Class object')
    self.class = inClass
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
    return self.profession1 ~= nil and self.profession1:Key() ~= nil
end

function XFC.Unit:GetProfession1()
    return self.profession1
end

function XFC.Unit:SetProfession1(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession', 'argument must be Profession object')
    self.profession1 = inProfession
end

function XFC.Unit:HasProfession2()
    return self.profession2 ~= nil and self.profession2:Key() ~= nil
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

function XFC.Unit:IsSameFaction()
    return XF.Player.Faction:Equals(self:GetFaction())
end

function XFC.Unit:GetLink()
    if(XF.Player.Faction:Equals(self:GetFaction())) then
        return format('player:%s', self:UnitName())
    end

    local friend = XF.Friends:GetByRealmUnitName(self:GetGuild():GetRealm(), self:Name())
    if(friend ~= nil) then
        return format('BNplayer:%s:%d:0:WHISPER:%s', friend:GetAccountName(), friend:GetAccountID(), friend:Name())
    end

    return format('player:%s', self:UnitName())
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
    -- Update the last sent time, dont need to heartbeat for awhile
    if(self:IsPlayer()) then
        local epoch = XFF.TimeCurrent()
        if(XF.Player.LastBroadcast > epoch - XF.Settings.Player.MinimumHeartbeat) then 
            XF:Debug(self:ObjectName(), 'Not sending broadcast, its been too recent')
            return 
        end
        self:TimeStamp(epoch)
        XF.Player.LastBroadcast = self:TimeStamp()
    end
    local message = nil
    try(function ()
        message = XFO.Mailbox:Pop()
        message:Initialize()
        message:From(self:GUID())
        message:SetGuild(self:GetGuild())
        message:UnitName(self:Name())
        message:Type(XF.Enum.Network.BROADCAST)
        message:Subject(inSubject)
        message:Data(self)
        XFO.Chat:Send(message)
    end).
    finally(function ()
        XFO.Mailbox:Push(message)
    end)
end

function XFC.Unit:Serialize()
    local data = {}

	data.A = self:Race():Key()
	data.B = self:GetAchievementPoints()
	data.C = self:ID()
	data.E = self:Presence()
	data.F = self:GetFaction():Key()	
	data.H = self:GetGuild():Key()
	-- Remove G/R after everyone on 4.4
	data.G = self:GetGuild():Name()
	data.R = self:GetGuild():Realm():ID()
	data.K = self:GUID()
	data.I = self:GetItemLevel()
	data.J = self:Rank()
	data.L = self:Level()
	data.M = self:HasMythicKey() and self:GetMythicKey():Serialize() or nil
	data.N = self:GetNote()
	data.O = self:GetClass():Key()
	data.P1 = self:HasProfession1() and self:GetProfession1():Key() or nil
	data.P2 = self:HasProfession2() and self:GetProfession2():Key() or nil
	data.U = self:UnitName()
	data.V = self:HasSpec() and self:GetSpec():Key() or nil
	data.X = self:GetVersion():Key()
	data.Y = self:GetPvP()

	if(self:Zone():HasID()) then
		data.D = self:Zone():ID()
	else
		data.Z = self:Zone():Name()
	end

	return pickle(data)
end

-- Usually a key check is enough for equality check, but use case is to detect any data differences
function XFC.Unit:Equals(inUnit)
    if(inUnit == nil) then return false end
    if(type(inUnit) ~= 'table' or inUnit.__name == nil or inUnit.__name ~= 'Unit') then return false end

    if(self:Key() ~= inUnit:Key()) then return false end
    if(self:GUID() ~= inUnit:GUID()) then return false end
    if(self:Presence() ~= inUnit:Presence()) then return false end
    if(self:ID() ~= inUnit:ID()) then return false end
    if(self:Level() ~= inUnit:Level()) then return false end
    if(self:GetNote() ~= inUnit:GetNote()) then return false end
    if(self:IsOnline() ~= inUnit:IsOnline()) then return false end
    if(self:GetAchievementPoints() ~= inUnit:GetAchievementPoints()) then return false end    
    if(self:IsRunningAddon() ~= inUnit:IsRunningAddon()) then return false end
    if(self:IsAlt() ~= inUnit:IsAlt()) then return false end
    if(self:GetMainName() ~= inUnit:GetMainName()) then return false end
    if(self:Rank() ~= inUnit:Rank()) then return false end
    if(self:GetItemLevel() ~= inUnit:GetItemLevel()) then return false end
    if(self:GetPvP() ~= inUnit:GetPvP()) then return false end

    if(not self:HasZone() and inUnit:HasZone()) then return false end
    if(self:HasZone() and not self:Zone():Equals(inUnit:Zone())) then return false end

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