local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Message'

XFC.Message = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Message:new()
    local object = XFC.Message.parent.new(self)
    object.__name = 'Message'
    object.to = nil
    object.from = nil
    object.fromUnit = nil
    object.type = nil
    object.subject = nil
    object.epochTime = nil
    object.targets = nil
    object.targetCount = 0
    object.data = nil
    object.initialized = false
    object.packetNumber = 1
    object.totalPackets = 1
    object.version = nil
    object.unitName = nil
    object.mainName = nil
    object.guild = nil
    object.faction = nil
    object.links = nil
    return object
end

function XFC.Message:Deconstructor()
    self:ParentDeconstructor()
    self.to = nil
    self.from = nil
    self.fromUnit = nil
    self.type = nil
    self.subject = nil
    self.epochTime = nil
    self.targets = nil
    self.targetCount = 0
    self.data = nil
    self.packetNumber = 1
    self.totalPackets = 1
    self.version = nil
    self.unitName = nil
    self.mainName = nil
    self.guild = nil
    self.faction = nil
    self.links = nil
end

function XFC.Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.targets = {}
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Properties
function XFC.Message:FromUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil)
    if(inUnit ~= nil) then
        self.fromUnit = inUnit
    end
    return self.fromUnit
end

function XFC.Message:To(inTo)
    assert(type(inTo) == 'string' or inTo == nil)
    if(inTo ~= nil) then
        self.to = inTo
    end
    return self.to
end

function XFC.Message:Type(inType)
    assert(type(inType) == 'string' or inType == nil)
    if(inType ~= nil) then
        self.type = inType
    end
    return self.type
end

function XFC.Message:Subject(inSubject)
    assert(type(inSubject) == 'string' or inSubject == nil)
    if(inSubject ~= nil) then
        self.subject = inSubject
    end
    return self.subject
end

function XFC.Message:TimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number' or inEpochTime == nil)
    if(inEpochTime ~= nil) then
        self.epochTime = inEpochTime
    end
    return self.epochTime
end

function XFC.Message:Links(inLinks)
    assert(type(inLinks) == 'string' or inLinks == nil)
    if(inLinks ~= nil) then
        self.links = inLinks
    end
    return self.links
end

function XFC.Message:Data(inData)
    if(inData ~= nil) then
        self.data = inData
    end
    return self.data
end

function XFC.Message:PacketNumber(inPacketNumber)
    assert(type(inPacketNumber) == 'number' or inPacketNumber == nil)
    if(inPacketNumber ~= nil) then
        self.packetNumber = inPacketNumber
    end
    return self.packetNumber
end

function XFC.Message:TotalPackets(inTotalPackets)
    assert(type(inTotalPackets) == 'number' or inTotalPackets == nil)
    if(inTotalPackets ~= nil) then
        self.totalPackets = inTotalPackets
    end
    return self.totalPackets
end

function XFC.Message:Version(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil)
    if(inVersion ~= nil) then
        self.version = inVersion
    end
    return self.version
end

--#region Deprecated, remove after 4.13
function XFC.Message:From(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.from = inGUID
    end
    return self.from
end

function XFC.Message:UnitName(inUnitName)
    assert(type(inUnitName) == 'string' or inUnitName == nil)
    if(inUnitName ~= nil) then
        self.unitName = inUnitName
    end
    return self.unitName
end

function XFC.Message:MainName(inMainName)
    assert(type(inMainName) == 'string' or inMainName == nil)
    if(inMainName ~= nil) then
        self.mainName = inMainName
    end
    return self.mainName
end

function XFC.Message:Guild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild' or inGuild == nil)
    if(inGuild ~= nil) then
        self.guild = inGuild
    end
    return self.guild
end

function XFC.Message:Faction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction' or inFaction == nil)
    if(inFaction ~= nil) then
        self.faction = inFaction
    end
    return self.faction
end
--#endregion
--#endregion

--#region Methods
function XFC.Message:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  to (' .. type(self.to) .. '): ' .. tostring(self.to))
    XF:Debug(self:ObjectName(), '  from (' .. type(self.from) .. '): ' .. tostring(self.from))
    XF:Debug(self:ObjectName(), '  packetNumber (' .. type(self.packetNumber) .. '): ' .. tostring(self.packetNumber))
    XF:Debug(self:ObjectName(), '  totalPackets (' .. type(self.totalPackets) .. '): ' .. tostring(self.totalPackets))
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:ObjectName(), '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XF:Debug(self:ObjectName(), '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XF:Debug(self:ObjectName(), '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
    XF:Debug(self:ObjectName(), '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(self:ObjectName(), '  targetCount (' .. type(self.targetCount) .. '): ' .. tostring(self.targetCount))
    XF:Debug(self:ObjectName(), '  links (' .. type(self.links) .. '): ' .. tostring(self.links))
    if(self:HasVersion()) then self:Version():Print() end
    if(self:HasGuild()) then self:Guild():Print() end
    if(self:HasFromUnit()) then self:FromUnit():Print() end
end

function XFC.Message:HasFromUnit()
    return self:FromUnit() ~= nil
end

function XFC.Message:HasVersion()
    return self:Version() ~= nil
end

function XFC.Message:IsMyMessage()
    return self:HasFromUnit() and self:FromUnit():IsPlayer()
end

function XFC.Message:HasGuild()
    return self:Guild() ~= nil
end

function XFC.Message:HasFaction()
    return self:Faction() ~= nil
end

function XFC.Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target')
    return self.targets[inTarget:Key()] ~= nil
end

function XFC.Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target')
    if(not self:ContainsTarget(inTarget)) then
        self.targetCount = self.targetCount + 1
    end
    self.targets[inTarget:Key()] = inTarget
end

function XFC.Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target')
    if(self:ContainsTarget(inTarget)) then
        self.targets[inTarget:Key()] = nil
        self.targetCount = self.targetCount - 1
    end
end

function XFC.Message:SetAllTargets()
    for _, target in XFO.Targets:Iterator() do
        if(not target:Equals(XF.Player.Target)) then
            self:AddTarget(target)
        end
    end
end

function XFC.Message:HasTargets()
    return self.targetCount > 0
end

function XFC.Message:GetTargets()
    if(self:HasTargets()) then return self.targets end
    return {}
end

function XFC.Message:GetTargetCount()
    return self.targetCount
end

function XFC.Message:GetRemainingTargets()
    local targetsString = ''
    for _, target in pairs (self:GetTargets()) do
        targetsString = targetsString .. '|' .. target:Key()
    end
    return targetsString
end

function XFC.Message:SetRemainingTargets(inTargetString)
    wipe(self.targets)
    self.targetCount = 0
    local targets = string.Split(inTargetString, '|')
    for _, key in pairs (targets) do
        if(key ~= nil and XFO.Targets:Contains(key)) then
            local target = XFO.Targets:Get(key)
            if(not XF.Player.Target:Equals(target)) then
                self:AddTarget(target)
            end
        end
    end
end

local function _LegacyUnitSerialize(inUnit)
    local data = {}

	data.A = inUnit:Race():Key()
	data.B = inUnit:AchievementPoints()
	data.E = inUnit:Presence()
	data.F = inUnit:Race():Faction():Key()	
	data.H = inUnit:Guild():Key()
	data.K = inUnit:GUID()
	data.I = inUnit:ItemLevel()
	data.J = inUnit:Rank()
	data.L = inUnit:Level()
	data.M = inUnit:HasMythicKey() and inUnit:MythicKey():Serialize() or nil
	data.N = inUnit:Note()
	data.O = inUnit:Spec():Class():Key()
	data.P1 = inUnit:HasProfession1() and inUnit:Profession1():Key() or nil
	data.P2 = inUnit:HasProfession2() and inUnit:Profession2():Key() or nil
	data.U = inUnit:UnitName()
	data.V = inUnit:Spec():Key()
	data.X = inUnit:Version():Key()
	data.Y = inUnit:PvP()

	if(inUnit:Zone():HasID()) then
		data.D = inUnit:Zone():ID()
	else
		data.Z = inUnit:Zone():Name()
	end

	return pickle(data)
end

function XFC.Message:Serialize(inEncodingType)
    local data = {}

    data.K = self:Key()
	data.T = self:To()
    data.S = self:Subject()
	data.Y = self:Type()
	data.I = self:TimeStamp()
	data.A = self:GetRemainingTargets()
	data.P = self:PacketNumber()
	data.Q = self:TotalPackets()
    data.X = self:HasFromUnit() and self:FromUnit():Serialize() or nil
	data.L = self:Links()
    data.D = self:Data()

    --#region Deprecated, remove after 4.13
	data.M = self:MainName()
	data.N = self:Name()
	data.U = self:UnitName()
	data.H = self:HasGuild() and self:Guild():Key() or nil
    data.F = self:From()
    data.V = self:Version():Key()
    data.W = self:HasFaction() and self:Faction():Key() or nil

	if(self:Subject() == XF.Enum.Message.DATA or self:Subject() == XF.Enum.Message.LOGIN) then
		data.D = _LegacyUnitSerialize(self:Data())
	end
    --#endregion

    local serialized = pickle(data)
    local compressed = nil
    for i=1, 10 do
        if(compressed == nil) then
            compressed = XF.Lib.Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
        end
    end
    return inEncodingType == XF.Enum.Tag.BNET and XF.Lib.Deflate:EncodeForPrint(compressed) or XF.Lib.Deflate:EncodeForWoWAddonChannel(compressed)
end

local function _LegacyUnitDeserialize(inSerial)
    local deserializedData = unpickle(inSerial)
	local unit = XFO.Confederate:Pop()
	unit:IsRunningAddon(true)
	unit:Race(XFO.Races:Get(deserializedData.A))
	if(deserializedData.B ~= nil) then unit:AchievementPoints(deserializedData.B) end
	if(deserializedData.C ~= nil) then unit:ID(tonumber(deserializedData.C)) end
	if(deserializedData.E ~= nil) then 
		unit:Presence(tonumber(deserializedData.E)) 
	else
		unit:Presence(Enum.ClubMemberPresence.Online)
	end
	--unit:Faction(XFO.Factions:Get(deserializedData.F))
	unit:GUID(deserializedData.K)
	unit:Key(deserializedData.K)
	--unit:SetClass(XFO.Classes:Get(deserializedData.O))
	local unitNameParts = string.Split(deserializedData.U, '-')
	unit:Name(unitNameParts[1])
	--unit:SetUnitName(deserializedData.U)
	if(deserializedData.H ~= nil and XFO.Guilds:Contains(deserializedData.H)) then
		unit:Guild(XFO.Guilds:Get(deserializedData.H))
		unit:Realm(unit:Guild():Realm())
	end
	if(deserializedData.I ~= nil) then unit:ItemLevel(deserializedData.I) end
	unit:Rank(deserializedData.J)
	unit:Level(deserializedData.L)
	if(deserializedData.M ~= nil) then
		local key = XFC.MythicKey:new(); key:Initialize()
		key:Deserialize(deserializedData.M)
		unit:MythicKey(key)
	end
	unit:Note(deserializedData.N)	
	unit:IsOnline(true)
	if(deserializedData.P1 ~= nil) then
		unit:Profession1(XFO.Professions:Get(tonumber(deserializedData.P1)))
	end
	if(deserializedData.P2 ~= nil) then
		unit:Profession2(XFO.Professions:Get(tonumber(deserializedData.P2)))
	end
	unit:IsRunningAddon(true)
	unit:TimeStamp(XFF.TimeGetCurrent())
	if(deserializedData.V ~= nil) then
		unit:Spec(XFO.Specs:Get(deserializedData.V))
	end

	if(deserializedData.D ~= nil and XFO.Zones:Contains(tonumber(deserializedData.D))) then
		unit:Zone(XFO.Zones:Get(tonumber(deserializedData.D)))
	elseif(deserializedData.Z == nil) then
		unit:Zone(XFO.Zones:Get('?'))
	else
		if(not XFO.Zones:Contains(deserializedData.Z)) then
			XFO.Zones:Add(deserializedData.Z)
		end
		unit:Zone(XFO.Zones:Get(deserializedData.Z))
	end

	if(deserializedData.Y ~= nil) then unit:PvP(deserializedData.Y) end
	if(deserializedData.X ~= nil) then 
		local version = XFO.Versions:Get(deserializedData.X)
		if(version == nil) then
			version = XFC.Version:new()
			version:Key(deserializedData.X)
			XFO.Versions:Add(version)
		end
		unit:Version(version) 
	end

	local raiderIO = XF.Addons.RaiderIO:Get(unit)
    if(raiderIO ~= nil) then
        unit:RaiderIO(raiderIO)
    end
    unit:TimeStamp(XFF.TimeGetCurrent())

	return unit
end

function XFC.Message:Deserialize(inData, inEncodingType)
    try(function()
        local decoded = inEncodingType == XF.Enum.Tag.BNET and XF.Lib.Deflate:DecodeForPrint(inData) or XF.Lib.Deflate:DecodeForWoWAddonChannel(inData)
        local decompressed = nil
        for i = 1, 10 do
            if(decompressed == nil) then
                decompressed = XF.Lib.Deflate:DecompressDeflate(decoded)
            end
        end
        local data = unpickle(decompressed)
        
        self:Initialize()
        if(data.K ~= nil) then self:Key(data.K)	end
        if(data.T ~= nil) then self:To(data.T)	end	
        if(data.S ~= nil) then self:Subject(data.S) end
        if(data.Y ~= nil) then self:Type(data.Y) end	
        if(data.I ~= nil) then self:TimeStamp(data.I) end	
        if(data.A ~= nil) then self:SetRemainingTargets(data.A) end
        if(data.P ~= nil) then self:PacketNumber(data.P) end
        if(data.Q ~= nil) then self:TotalPackets(data.Q) end

        if(data.X ~= nil) then
            local unit = XFO.Confederate:Pop()
            try(function()
                unit:Deserialize(data.X)
                unit:IsRunningAddon(true)
                self:FromUnit(unit)
            end).
            catch(function(err)
                XF:Error(self:ObjectName(), err)
                XFO.Confederate:Push(unit)
            end)
        -- Deprecated, remove after 4.13
        elseif(self:Subject() == XF.Enum.Message.DATA or self:Subject() == XF.Enum.Message.LOGIN) then
            self:Data(_LegacyUnitDeserialize(data.D))
        else
            self:Data(data.D)
        end

        if(data.L ~= nil) then
            XFO.Links:Deserialize(self:FromUnit(), data.L)
        end

        --#region Deprecated, remove after 4.13
        if(data.F ~= nil) then self:From(data.F) end
        if(data.V ~= nil) then 
            local version = XFO.Versions:Get(data.V)
            if(version == nil) then
                version = XFC.Version:new()
                version:Key(data.V)
                XFO.Versions:Add(version)
            end
            self:Version(version)
        end

        if(data.M ~= nil) then self:MainName(data.M) end
        if(data.U ~= nil) then self:UnitName(data.U) end
        if(data.N ~= nil) then 
            self:Name(data.N) 
        elseif(data.U ~= nil) then
            self:Name(self:UnitName())
        end
        if(data.H ~= nil and XFO.Guilds:Contains(data.H)) then
            self:Guild(XFO.Guilds:Get(data.H))
        end		

        if(data.W ~= nil) then self:Faction(XFO.Factions:Get(data.W)) end
        --#endregion
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), 'Failed to deserialize message: ' .. err)
    end)
end
--#endregion