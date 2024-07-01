local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Message'

XFC.Message = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Message:new()
    local object = XFC.Message.parent.new(self)
    object.__name = ObjectName
    object.from = nil
    object.type = nil
    object.subject = nil
    object.epochTime = nil
    object.targets = nil
    object.tarCount = 0
    object.unitData = nil
    object.data = nil
    object.initialized = false
    object.packetNumber = 1
    object.totalPackets = 1
    object.version = nil
    object.unitName = nil
    object.mainName = nil
    object.guild = nil
    object.faction = nil
    return object
end

function XFC.Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.targets = {}
        self:From(XF.Player.GUID)
        self:TimeStamp(XFF.TimeCurrent())
        self:SetAllTargets()
        self:SetVersion(XF.Version)
        self:SetFaction(XF.Player.Faction)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function XFC.Message:Deconstructor()
    self:ParentDeconstructor()
    self.from = nil
    self.type = nil
    self.subject = nil
    self.epochTime = nil
    self.targets = nil
    self.tarCount = 0
    self.unitData = nil
    self.data = nil
    self.packetNumber = 1
    self.totalPackets = 1
    self.version = nil
    self.unitName = nil
    self.mainName = nil
    self.guild = nil
    self.faction = nil
    self:Initialize()
end
--#endregion

--#region Properties
function XFC.Message:From(inFrom)
    assert(type(inFrom) == 'string' or inFrom == nil)
    if(inFrom ~= nil) then
        self.from = inFrom
    end
    return self.from
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

function XFC.Message:Data(inData)
    if(inData ~= nil) then
        self.data = inData
    end
    return self.data
end

function XFC.Message:PacketNumber(inPacketNumber)
    assert(type(inPacketNumber) == 'number' or inPacketNumber == nil)
    if(self.packetNumber ~= nil) then
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
--#endregion

--#region Methods
function XFC.Message:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  from (' .. type(self.from) .. '): ' .. tostring(self.from))
    XF:Debug(self:ObjectName(), '  packetNumber (' .. type(self.packetNumber) .. '): ' .. tostring(self.packetNumber))
    XF:Debug(self:ObjectName(), '  totalPackets (' .. type(self.totalPackets) .. '): ' .. tostring(self.totalPackets))
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:ObjectName(), '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XF:Debug(self:ObjectName(), '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XF:Debug(self:ObjectName(), '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
    XF:Debug(self:ObjectName(), '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XF:Debug(self:ObjectName(), '  tarCount (' .. type(self.tarCount) .. '): ' .. tostring(self.tarCount))
    if(self:HasVersion()) then self:GetVersion():Print() end
end

function XFC.Message:IsMyMessage()
    return XF.Player.GUID == self:From()
end
--#endregion



function XFC.Message:HasUnitData()
    return self:Subject() == XF.Enum.Message.DATA or 
           self:Subject() == XF.Enum.Message.LOGIN
end

function XFC.Message:HasVersion()
    return self.version ~= nil
end

function XFC.Message:GetVersion()
    return self.version
end

function XFC.Message:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
    self.version = inVersion
end


function XFC.Message:UnitName(inUnitName)
    assert(type(inUnitName) == 'string' or inUnitName == nil)
    if(inUnitName ~= nil) then
        self.unitName = inUnitName
    end
    return self.unitName
end

function XFC.Message:HasMainName()
    return self.mainName ~= nil
end

function XFC.Message:GetMainName()
    return self.mainName
end

function XFC.Message:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self.mainName = inMainName
end

function XFC.Message:HasGuild()
    return self.guild ~= nil
end

function XFC.Message:GetGuild()
    return self.guild
end

function XFC.Message:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
    self.guild = inGuild
end

function XFC.Message:HasFaction()
    return self.faction ~= nil
end

function XFC.Message:GetFaction()
    return self.faction
end

function XFC.Message:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end

function XFC.Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.targets[inTarget:Key()] ~= nil
end

function XFC.Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(not self:ContainsTarget(inTarget)) then
        self.tarCount = self.tarCount + 1
    end
    self.targets[inTarget:Key()] = inTarget
end

function XFC.Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(self:ContainsTarget(inTarget)) then
        self.targets[inTarget:Key()] = nil
        self.tarCount = self.tarCount - 1
    end
end

function XFC.Message:SetAllTargets()
    for _, target in XF.Targets:Iterator() do
        if(not target:Equals(XF.Player.Target)) then
            self:AddTarget(target)
        end
    end
end

function XFC.Message:HasTargets()
    return self.tarCount > 0
end

function XFC.Message:GetTargets()
    if(self:HasTargets()) then return self.targets end
    return {}
end

function XFC.Message:GetTarCount()
    return self.tarCount
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
    self.tarCount = 0
    local targets = string.Split(inTargetString, '|')
    for _, key in pairs (targets) do
        if(key ~= nil and XF.Targets:Contains(key)) then
            local target = XF.Targets:Get(key)
            if(not XF.Player.Target:Equals(target)) then
                self:AddTarget(target)
            end
        end
    end
end

function XFC.Message:Encode(inTag)
    assert(type(inTag) == 'string' or inTag == nil)
    local serialized = self:Serialize()
	local compressed = XF.Lib.Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
    return inTag == XF.Enum.Tag.BNET and XF.Lib.Deflate:EncodeForPrint(compressed) or XF.Lib.Deflate:EncodeForWoWAddonChannel(compressed)
end

function XFC.Message:Serialize()
    local data = {}

	data.M = self:GetMainName()
	data.N = self:Name()
	data.U = self:UnitName()
	if(self:HasGuild()) then
		data.H = self:GetGuild():Key()
		-- Remove G/R once everyone is on 4.4 build
		data.G = self:GetGuild():Name()
		data.R = self:GetGuild():Realm():ID()
	end

    data.D = self:HasUnitData() and self:Data():Serialize() or self:Data()
	data.K = self:Key()
	data.F = self:From()	
	data.S = self:Subject()
	data.Y = self:Type()
	data.I = self:TimeStamp()
	data.A = self:GetRemainingTargets()
	data.P = self:PacketNumber()
	data.Q = self:TotalPackets()
	data.V = self:GetVersion():Key()
	data.W = self:GetFaction():Key()

	return pickle(data)
end
--#endregion