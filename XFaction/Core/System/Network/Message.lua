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
    object.type = nil
    object.subject = nil
    object.timeStamp = nil
    object.targets = nil
    object.targetCount = 0
    object.initialized = false
    object.version = nil
    return object
end

function XFC.Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.targets = {}
        self:From(XF.Player.Unit)
        self:TimeStamp(XFF.TimeGetCurrent())
        self:SetAllTargets()
        self:Version(XF.Player.Unit:Version())
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function XFC.Message:Deconstructor()
    self:ParentDeconstructor()
    self.to = nil
    self.from = nil
    self.type = nil
    self.subject = nil
    self.timeStamp = nil
    self.targets = nil
    self.targetCount = 0
    self.data = nil
    self.version = nil
end
--#endregion

--#region Properties
function XFC.Message:To(inTo)
    assert(type(inTo) == 'string' or inTo == nil, 'argument must be string or nil')
    if(inTo ~= nil) then
        self.to = inTo
    end
    return self.to
end

function XFC.Message:From(inFrom)
    assert(type(inFrom) == 'table' and inFrom.__name == 'Unit' or inFrom == nil, 'argument must be Unit object or nil')
    if(inFrom ~= nil) then
        self.from = inFrom
    end
    return self.from
end

function XFC.Message:Type(inType)
    assert(type(inType) == 'string' or inType == nil, 'argument must be string or nil')
    if(inType ~= nil) then
        self.type = inType
    end
    return self.type
end

function XFC.Message:Subject(inSubject)
    assert(type(inSubject) == 'string' or inSubject == nil, 'argument must be string or nil')
    if(inSubject ~= nil) then
        self.subject = inSubject
    end
    return self.subject
end

function XFC.Message:TimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number' or inEpochTime == nil, 'argument must be number or nil')
    if(inEpochTime ~= nil) then
        self.timeStamp = inEpochTime
    end
    return self.timeStamp
end

function XFC.Message:Data(inData)
    if(inData ~= nil) then
        self.data = inData
    end
    return self.data
end

function XFC.Message:Targets()
    if(self:TargetCount() > 0) then
        return self.targets
    end
    return {}
end

function XFC.Message:TargetCount()
    return self.targetCount
end

function XFC.Message:Version(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil, 'property can be set using Version object or get with nil')
    if(inVersion ~= nil) then
        self.version = inVersion
    end
    return self.version
end
--#endregion

--#region Methods
function XFC.Message:HasVersion()
    return self:Version() ~= nil
end

function XFC.Message:Print()
    self:ParentPrint()
    -- if(self:From() ~= nil) then
    --     XF:Debug(self:ObjectName(), '  from: ' .. self:From():UnitName())
    -- end
    XF:Debug(self:ObjectName(), '  to (' .. type(self.to) .. '): ' .. tostring(self.to))
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:ObjectName(), '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XF:Debug(self:ObjectName(), '  timeStamp (' .. type(self.timeStamp) .. '): ' .. tostring(self.timeStamp))
    XF:Debug(self:ObjectName(), '  targetCount (' .. type(self.targetCount) .. '): ' .. tostring(self.targetCount))
    if(self:HasVersion()) then self:Version():Print() end
end

function XFC.Message:IsMyMessage()
    return self:From():IsPlayer()
end

function XFC.Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.targets[inTarget:Key()] ~= nil
end

function XFC.Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(not self:ContainsTarget(inTarget)) then
        self.targetCount = self.targetCount + 1
    end
    self.targets[inTarget:Key()] = inTarget
end

function XFC.Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
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

function XFC.Message:GetRemainingTargets()
    local targetsString = ''
    for _, target in pairs (self:Targets()) do
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

function XFC.Message:Serialize()
	local data = {}

    data.K = self:Key()
	data.F = self:From():Key()
	data.R = self:GetRemainingTargets()
    data.S = self:Subject()
    data.T = self:To()	
	data.Y = self:Type()
    data.I = self:TimeStamp()
    data.A = self:GetRemainingTargets()
    data.V = self:From():Version():Key()

    -- TODO
    data.M = self:From():MainName()
    data.N = self:From():Name()
    data.U = self:From():UnitName()
    data.H = self:From():Guild()    

	return data
end

local function ConvertLegacyUnit(inLegacy)
    local converted = {}
    
    converted.R = inLegacy.A
    converted.A = inLegacy.B
    converted.P = inLegacy.E
    converted.G = inLegacy.H
    converted.K = inLegacy.K
    converted.I = inLegacy.I
    converted.C = inLegacy.J
    converted.L = inLegacy.L
    converted.M = inLegacy.M
    converted.N = inLegacy.N
    converted.W = inLegacy.P1
    converted.X = inLegacy.P2
    converted.U = inLegacy.U
    converted.S = inLegacy.V
    converted.V = inLegacy.X
    converted.Y = inLegacy.Y
    converted.Z = inLegacy.D
    converted.J = inLegacy.Z

    return converted
end

function XFC.Message:Deserialize(inData)
	local decompressed = XF.Lib.Deflate:DecompressDeflate(inData)
	local data = unpickle(decompressed)

    XF:DataDumper(self:ObjectName(), data)

    self:Key(data.K)
    self:Subject(data.S)
    if(data.T ~= nil) then self:To(data.T) end
    self:Type(data.Y)    
    self:TimeStamp(data.I)
    self:SetRemainingTargets(data.A)
    self:Data(data.D)

    local unit = nil
    try(function()
        unit = XFO.Confederate:Pop()
        unit:IsRunningAddon(true)
        unit:IsOnline(true)
        self:From(unit)
        unit:Key(data.F)
        unit:GUID(data.F)
        
        if(data.N ~= nil) then
            unit:Name(data.N)
        end

        if(data.M ~= nil) then
            unit:IsAlt(true)
            unit:MainName(data.M)
        end

        if(data.H ~= nil and XFO.Guilds:Contains(data.H)) then
            unit:Guild(XFO.Guilds:Get(data.H))
        end

        if(self:Subject() == XF.Enum.Message.DATA or self:Subject() == XF.Enum.Message.LOGIN) then
            unit:Deserialize(ConvertLegacyUnit(unpickle(data.D)))
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
        XFO.Confederate:Push(unit)
    end)
end

function XFC.Message:Encode(inProtocol)
    local compressed = XF.Lib.Deflate:CompressDeflate(pickle(self:Serialize()), {level = XF.Settings.Network.CompressionLevel})
    if(inProtocol == XF.Enum.Network.BNET) then
        return XF.Lib.Deflate:EncodeForPrint(compressed)
    end
    return XF.Lib.Deflate:EncodeForWoWAddonChannel(compressed)
end

function XFC.Message:Decode(inData, inProtocol)
	if(inProtocol == XF.Enum.Network.BNET) then
        self:Deserialize(XF.Lib.Deflate:DecodeForPrint(inData))
    else
        self:Deserialize(XF.Lib.Deflate:DecodeForWoWAddonChannel(inData))
    end
end

function XFC.Message:Segment(inProtocol)
	local packets = {}
    local encoded = self:Encode(inProtocol)
    local totalPackets = ceil(strlen(encoded) / XF.Settings.Network.Chat.PacketSize)
    for i = 1, totalPackets do
        local segment = string.sub(encoded, XF.Settings.Network.Chat.PacketSize * (i - 1) + 1, XF.Settings.Network.Chat.PacketSize * i)
        segment = tostring(i) .. tostring(totalPackets) .. self:Key() .. segment
        packets[#packets + 1] = segment
    end
	return packets
end
--#endregion