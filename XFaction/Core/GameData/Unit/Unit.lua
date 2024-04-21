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
    object.spec = nil
    object.zone = nil
    object.note = nil
    object.presence = Enum.ClubMemberPresence.Unknown
    object.race = nil
    object.updatedTime = nil
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
    object.target = nil

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
    self.updatedTime = nil
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
    self.target = nil
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

    self:GUID(unitData.guid)
    self:Key(self:GetGUID())
    self:Presence(unitData.presence)    
    self:ID(unitData.memberId)
    self:Name(unitData.name)
    self:UnitName(unitData.name .. '-' .. XF.Player.Guild:GetRealm():GetAPIName())
	self:Level(unitData.level)	
	self:Guild(XF.Player.Guild)
    self:UpdatedTime(XFF.TimeGetCurrent())
    self:Spec(XFO.Specs:GetInitialClassSpec(unitData.classID))
    self:Race(XFO.Races:Get(unitData.race))
    self:Rank(unitData.guildRank)
    self:Note(unitData.memberNote or '?')
    self:Achievements(unitData.achievementPoints or 0)

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

    if(unitData.zone ~= nil) then
        if(not XFO.Zones:Contains(unitData.zone)) then
            XFO.Zones:AddZone(unitData.zone)
        end
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

    local raiderIO = XFO.RaiderIO:Get(self)
    if(raiderIO ~= nil) then
        self:RaiderIO(raiderIO)
    end

    if(self:IsPlayer()) then
        self:IsRunningAddon(true)
        self:Version(XFO.Versions:GetCurrent())
        
        if(XFO.Keys:HasMyKey()) then
            self:MythicKey(XFO.Keys:GetMyKey())
        end

        local permissions = XFF.GuildGetPermissions(unitData.guildRankOrder)
        if(permissions ~= nil) then
            self:CanGuildListen(permissions[1])
            self:CanGuildSpeak(permissions[2])
        end
        
        local itemLevel = XFF.PlayerGetIlvl()
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
    XF:Debug(self:GetObjectName(), '  updatedTime (' .. type(self.updatedTime) .. '): ' .. tostring(self.updatedTime))
    XF:Debug(self:GetObjectName(), '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(self:GetObjectName(), '  isAlt (' .. type(self.isAlt) .. '): ' .. tostring(self.isAlt))
    XF:Debug(self:GetObjectName(), '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(self:GetObjectName(), '  isPlayer (' .. type(self.isPlayer) .. '): ' .. tostring(self.isPlayer))
    XF:Debug(self:GetObjectName(), '  itemLevel (' .. type(self.itemLevel) .. '): ' .. tostring(self.itemLevel))
    XF:Debug(self:GetObjectName(), '  pvp (' .. type(self.pvp) .. '): ' .. tostring(self.pvp))
    XF:Debug(self:GetObjectName(), '  guildSpeak (' .. type(self.guildSpeak) .. '): ' .. tostring(self.guildSpeak))
    XF:Debug(self:GetObjectName(), '  guildListen (' .. type(self.guildListen) .. '): ' .. tostring(self.guildListen))
    if(self:Zone() ~= nil) then self:Zone():Print() end
    if(self:Version() ~= nil) then self:Version():Print() end
    if(self:Guild() ~= nil) then self:Guild():Print() end
    if(self:Team() ~= nil) then self:Team():Print() end
    if(self:Race() ~= nil) then self:Race():Print() end
    if(self:Spec() ~= nil) then self:Spec():Print() end
    if(self:Profession1()) ~= nil then self:Profession1():Print() end
    if(self:Profession2() ~= nil) then self:Profession2():Print() end  
    if(self:RaiderIO() ~= nil) then self:RaiderIO():Print() end
    if(self:MythicKey()) ~= nil then self:MythicKey():Print() end
end
--#endregion

--#region Properties
function XFC.Unit:IsPlayer()
    return self:GetGUID() == XF.Player.GUID
end

function XFC.Unit:GUID(inGUID)
    assert(inGUID == nil or type(inGUID == 'string'), 'argument must be nil or string')
    if(inGUID ~= nil) then
        self.guid = inGUID
    end
    return self.guid
end

function XFC.Unit:UnitName()
    return self:GetName() .. '-' .. self:GetTarget():GetRealm():GetAPIName()
end

function XFC.Unit:Rank(inRank)
    assert(inRank == nil or type(inRank == 'string'), 'argument must be nil or string')
    if(inRank ~= nil) then
        self.rank = inRank
    end
    return self.rank
end

function XFC.Unit:Level(inLevel)
    assert(inLevel == nil or type(inLevel == 'number'), 'argument must be nil or number')
    if(inLevel ~= nil) then
        self.level = inLevel
    end
    return self.level
end

function XFC.Unit:Zone(inZone)
    assert(type(inZone) == 'table' and inZone.__name == 'Zone' or inZone == nil, 'argument must be nil or Zone object')
    if(inZone ~= nil) then
        self.zone = inZone
    end
    self.zone
end

function XFC.Unit:Note(inNote)
    assert(type(inNote) == 'string' or inNote == nil, 'argument must be nil or string')
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
                    if(guildInitials ~= nil and XFO.Guilds:Contains(guildInitials) and not self:GetGuild():Equals(XFO.Guilds:Get(guildInitials))) then
                        self:IsAlt(true)
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
                self:IsAlt(true)
                self:MainName(altName)
            end
        end).
        catch(function(err)
            XF:Trace(self:GetObjectName(), 'Failed to parse player note: [' .. self.note .. ']')
            XF:Trace(self:GetObjectName(), err)
        end).
        finally(function()
            if(self:Team() == nil) then
                self:Team(XFO.Teams:Get('?'))
            end
        end)
    end
    return self.note
end

function XFC.Unit:Presence(inPresence)
    assert(inPresence == nil or type(inPresence == 'number'), 'argument must be nil or number')
    if(inPresence ~= nil) then
        self.presence = inPresence
    end
    self.presence = inPresence
end

function XFC.Unit:IsOnline()
    return self:Presence() == Enum.ClubMemberPresence.Online or 
           self:Presence() == Enum.ClubMemberPresence.Away or 
           self:Presence() == Enum.ClubMemberPresence.Busy
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

function XFC.Unit:PvP(inScore, inIndex)
    assert((type(inScore) == 'number' and type(inIndex) == 'number') or type(inScore) == 'string' or (inScore == nil and inIndex == nil), 'arguments must be nil, number or string')
    -- Both are numbers
    if(inScore ~= nil and inIndex ~= nil) then
        self.pvp = tostring(inScore)
        if(inIndex == 1) then
            self.pvp = self.pvp .. ' (2)'
        elseif(inIndex == 2) then
            self.pvp = self.pvp .. ' (3)'
        else
            self.pvp = self.pvp .. ' (10)'
        end
    -- Resulting PvP string was passed in
    elseif(inScore ~= nil) then
        self.pvp = inScore
    end
    return self.pvp
end

function XFC.Unit:Achievements(inPoints)
    assert(inPoints == nil or type(inPoints == 'number'), 'argument must be nil or number')
    if(inPoints ~= nil) then
        self.achievements = inPoints
    end
    return self.achievements
end

function XFC.Unit:RaiderIO(inRaiderIO)
    assert(type(inRaiderIO) == 'table' and inRaiderIO.__name == 'RaiderIO' or inRaiderIO == nil, 'argument must be RaiderIO object or nil')
    if(inRaiderIO ~= nil) then
        self.raiderIO = inRaiderIO
    end
    return self.raiderIO
end

function XFC.Unit:Race(inRace)
    assert(type(inRace) == 'table' and inRace.__name == 'Race' or inRace == nil, 'argument must be Race object or nil')
    if(inRace ~= nil) then
        self.race = inRace
    end
    return self.race
end

function XFC.Unit:UpdatedTime(inEpoch)
    assert(type(inEpoch) == 'number' or inEpoch == nil, 'argument must be number or nil')
    if(inEpoch ~= nil) then
        self.updatedTime = inEpoch
    end
    return self.updatedTime
end

function XFC.Unit:Spec(inSpec)
    assert(type(inSpec) == 'table' and inSpec.__name == 'Spec' or inSpec == nil, 'argument must be Spec object or nil')
    if(inSpec ~= nil) then
        self.spec = inSpec
    end
    return self.spec
end

function XFC.Unit:Profession1(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession' or inProfession == nil, 'argument must be Profession object or nil')
    if(inProfession ~= nil) then
        self.profession1 = inProfession
    end
    return self.profession1
end

function XFC.Unit:Profession2(inProfession)
    assert(type(inProfession) == 'table' and inProfession.__name == 'Profession' or inProfession == nil, 'argument must be Profession object or nil')
    if(inProfession ~= nil) then
        self.profession2 = inProfession
    end
    return self.profession2
end

function XFC.Unit:IsRunningAddon(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRunningAddon = inBoolean
    end
    return self.isRunningAddon
end

function XFC.Unit:Version(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil, 'argument must be Version object or nil')
    if(inVersion ~= nil) then
        self.version = inVersion
    end
    return self.version
end

function XFC.Unit:IsAlt(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isAlt = inBoolean
    end
    return self.isAlt
end

function XFC.Unit:MainName(inMainName)
    assert(type(inMainName) == 'string' or inMainName == nil, 'argument must be string or nil')
    if(inMainName ~= nil) then
        self.mainName = inMainName
    end
    return self.mainName
end

function XFC.Unit:Team(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name == 'Team' or inTeam == nil, 'argument must be Team object or nil')
    if(inTeam ~= nil) then
        self.team = inTeam
    end
    return self.team
end

function XFC.Unit:Guild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild' or inGuild == nil, 'argument must be Guild object or nil')
    if(inGuild ~= nil) then
        self.guild = inGuild
    end
    return self.guild
end

function XFC.Unit:Target(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil, 'argument must be Target object or nil')
    if(inTarget ~= nil) then
        self.target = inTarget
    end
    return self.target
end

function XFC.Unit:ItemLevel(inItemLevel)
    assert(type(inItemLevel) == 'number' or inItemLevel == nil, 'argument must be number or nil')
    if(inItemLevel ~= nil) then
        self.itemLevel = inItemLevel
    end
    return self.itemLevel
end

function XFC.Unit:Link()
    if(self:Race():Faction():Equals(XF.Player.Unit:Race():Faction())) then
        return format('player:%s', self:UnitName())
    end

    local friend = XFO.Friends:GetByRealmUnitName(self:GetGuild():GetRealm(), self:GetName())
    if(friend ~= nil) then
        return format('BNplayer:%s:%d:0:WHISPER:%s', friend:GetAccountName(), friend:GetAccountID(), friend:GetName())
    end

    return format('player:%s', self:UnitName())
end

function XFC.Unit:LastLogin(inDays)
    assert(type(inDays) == 'number' or inDays == nil, 'argument must be number or nil')
    if(inDays ~= nil) then
        self.lastLogin = inDays
    end
    return self.lastLogin
end

function XFC.Unit:MythicKey(inKey)
    assert(type(inKey) == 'table' and inKey.__name == 'MythicKey' or inKey == nil, 'argument must be MythicKey object or nil')
    if(inKey ~= nil) then
        self.mythicKey = inKey
    end
    return self.mythicKey
end
--#endregion

--#region Networking Methods
function XFC.Unit:Broadcast(inSubject)
    assert(type(inSubject) == 'string' or inSubject == nil)
	if(inSubject == nil) then inSubject = XF.Enum.Message.DATA end
    
    local message = nil
    try(function ()
        message = XFO.Chat:Pop()
        message:Initialize()
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
	
	data.A = self:Achievements()
    data.C = self:Rank()
    data.G = self:Guild():Key()
    data.I = self:ItemLevel()
    data.K = self:GUID()	
    data.L = self:Level()
    data.M = self:MythicKey() ~= nil and self:MythicKey():Serialize() or nil
    data.N = self:Note()
    data.P = self:Presence()
    data.R = self:Race():Key()
    data.S = self:Spec():Key()
    data.U = self:Name()
    data.V = self:Version():Key()
    data.W = self:Profession1() ~= nil and self:Profession1():Key() or nil
    data.X = self:Profession2() ~= nil and self:Profession2():Key() or nil
    data.Y = self:PvP()
    data.Z = self:Zone():ID()

    if(data.Z == nil) then
        data.J = self:Zone():Name()
    end

	return data
end

function XFC.Unit:Deserialize(inSerialized)
    assert(type(inSerialized) == 'table')

    self:IsRunningAddon(true)
    self:IsOnline(true)
    self:UpdatedTime(XFF.TimeGetCurrent())

    self:Achievements(tonumber(inSerialized.A))
    self:Rank(inSerialized.C)
    self:Guild(XFO.Guilds:Get(inSerialized.G))
    self:ItemLevel(inSerialized.I)
    self:GUID(inSerialized.K)
    self:Key(inSerialized.K)
    self:Level(inSerialized.L)

    if(inSerialized.M ~= nil) then
		local key = XFC.MythicKey:new(); key:Initialize()
		key:Deserialize(inSerialized.M)
		self:MythicKey(key)
	end

    self:Note(inSerialized.N)
    self:Presence(tonumber(inSerialized.P))
	self:Race(XFO.Races:Get(inSerialized.R))
    self:Spec(XFO.Specs:Get(inSerialized.S))
    self:Name(inSerialized.U)

    XFO.Versions:Add(inSerialized.V)
    self:Version(XFO.Versions:Get(inSerialized.V))

	if(inSerialized.W ~= nil) then
		self:Profession1(XFO.Professions:Get(inSerialized.W))
	end
	if(inSerialized.X ~= nil) then
		self:Profession2(XFO.Professions:Get(inSerialized.X))
	end
    
    self:PvP(inSerialized.Y)

    if(inSerialized.Z ~= nil and XFO.Zones:ContainsByID(tonumber(inSerialized.Z))) then        
        self:Zone(XFO.Zones:GetByID(tonumber(inSerialized.Z)))
    elseif(inSerialized.J ~= nil) then
        XFO.Zones:Add(inSerialized.J)
        self:Zone(XFO.Zones:Get(inSerialized.J))
    else
        self:Zone(XFO.Zones:Get('?'))
    end
end
--#endregion

--#region Operators
-- Usually a key check is enough for equality check, but use case is to detect any data differences
function XFC.Unit:Equals(inUnit)
    if(inUnit == nil) then return false end
    if(type(inUnit) ~= 'table' or inUnit.__name == nil or inUnit.__name ~= 'Unit') then return false end

    if(self:Key() ~= inUnit:Key()) then return false end
    if(self:GUID() ~= inUnit:GUID()) then return false end
    if(self:Presence() ~= inUnit:Presence()) then return false end
    if(self:Level() ~= inUnit:Level()) then return false end
    if(self:Zone() ~= inUnit:Zone()) then return false end
    if(self:Note() ~= inUnit:Note()) then return false end
    if(self:IsOnline() ~= inUnit:IsOnline()) then return false end
    if(self:Achievements() ~= inUnit:Achievements()) then return false end    
    if(self:IsRunningAddon() ~= inUnit:IsRunningAddon()) then return false end
    if(self:IsAlt() ~= inUnit:IsAlt()) then return false end
    if(self:MainName() ~= inUnit:MainName()) then return false end
    if(self:Rank() ~= inUnit:Rank()) then return false end
    if(self:ItemLevel() ~= inUnit:ItemLevel()) then return false end
    if(self:PvP() ~= inUnit:PvP()) then return false end

    if(not XF:ObjectsEquals(self:Profession1(), inUnit:Profession1())) then return false end
    if(not XF:ObjectsEquals(self:Profession2(), inUnit:Profession2())) then return false end
    if(not XF:ObjectsEquals(self:Spec(), inUnit:Spec())) then return false end
    if(not XF:ObjectsEquals(self:RaiderIO(), inUnit:RaiderIO())) then return false end
    
    -- Do not consider TimeStamp
    -- A unit cannot change Class, do not consider
	-- A unit cannot change Race while logged in, do not consider
	-- A unit cannot change Name/UnitName while logged in, do not consider
	-- A unit cannot change GUID while logged in, but it is the key so consider
    
    return true
end
--#endregion