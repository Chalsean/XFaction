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
    object.epochTime = nil
    object.targets = nil
    object.targetCount = 0
    object.initialized = false
    return object
end
--#endregion

--#region Initializers
function XFC.Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.targets = {}
        self:SetFrom(XF.Player.Unit)
        self:SetTimeStamp(XFF.TimeGetCurrent())
        self:SetAllTargets()
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
    self.epochTime = nil
    self.targets = nil
    self.targetCount = 0
    self.data = nil
    self:Initialize()
end
--#endregion

--#region Print
function XFC.Message:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  to (' .. type(self.to) .. '): ' .. tostring(self.to))
    XF:Debug(self:GetObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:GetObjectName(), '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XF:Debug(self:GetObjectName(), '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XF:Debug(self:GetObjectName(), '  targetCount (' .. type(self.targetCount) .. '): ' .. tostring(self.targetCount))
    if(self:IsFromUnit()) then
        self:GetFrom():Print()
    else
        XF:Debug(self:GetObjectName(), '  from (' .. type(self.from) .. '): ' .. tostring(self.from))
    end
end
--#endregion

--#region Accessors
function XFC.Message:GetTo()
    return self.to
end

function XFC.Message:SetTo(inTo)
    assert(type(inTo) == 'string')
    self.to = inTo
end

function XFC.Message:HasFrom()
    return self.from ~= nil
end

function XFC.Message:GetFrom()
    return self.from
end

function XFC.Message:SetFrom(inFrom)
    assert(type(inFrom) == 'table' and inFrom.__name ~= nil and inFrom.__name == 'Unit', 'argument must be Unit object')
    self.from = inFrom
end

function XFC.Message:IsFromUnit()
    return type(self.from) == 'table' and self.from.__name ~= nil and self.from__name == 'Unit'
end

function XFC.Message:GetType()
    return self.type
end

function XFC.Message:SetType(inType)
    assert(type(inType) == 'string')
    self.type = inType
end

function XFC.Message:GetSubject()
    return self.subject
end

function XFC.Message:SetSubject(inSubject)
    assert(type(inSubject) == 'string')
    self.subject = inSubject
end

function XFC.Message:GetTimeStamp()
    return self.epochTime
end

function XFC.Message:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.epochTime = inEpochTime
end

function XFC.Message:GetData()
    return self.data
end

function XFC.Message:SetData(inData)
    self.data = inData
end

function XFC.Message:IsMyMessage()
    return self:GetFrom():Equals(XF.Player.Unit)
end
--#endregion

--#region Target
function XFC.Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.targets[inTarget:GetKey()] ~= nil
end

function XFC.Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(not self:ContainsTarget(inTarget)) then
        self.targetCount = self.targetCount + 1
    end
    self.targets[inTarget:GetKey()] = inTarget
end

function XFC.Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(self:ContainsTarget(inTarget)) then
        self.targets[inTarget:GetKey()] = nil
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
        targetsString = targetsString .. '|' .. target:GetKey()
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
--#endregion

--#region Network
-- I'm sure there's a cooler way of doing this but this works for me :)
function XFC.Message:Serialize()
	local data = {}

	data.F = self:GetFrom():Serialize()
	data.R = self:GetRemainingTargets()
    data.S = self:GetSubject()
    data.T = self:GetTo()	
	data.Y = self:GetType()

	return pickle(data)
end

function ConvertLegacyUnit(inLegacy)
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

    XF:DataDumper(self:GetObjectName(), data)

    self:SetSubject(data.S)
    if(data.T ~= nil) then self:SetTo(data.T) end
    self:SetType(data.Y)    
    self:SetTimeStamp(XFF.TimeGetCurrent())

    local unit = nil
    try(function()
        unit = XFO.Confederate:Pop()
        unit:IsRunningAddon(true)
        unit:IsOnline(true)

        --if(data.K == nil) then        
        --    self:SetRemainingTargets(data.R)
        --    unit:Deserialize(data.F)
            
        -- Legacy format
        --else
            self:SetRemainingTargets(data.A)
            self:SetData(data.D)
            -- Old data message
            if(self:GetSubject() == XF.Enum.Message.DATA or self:GetSubject() == XF.Enum.Message.LOGIN) then
                unit:Deserialize(ConvertLegacyUnit(unpickle(data.D)))
                self:SetFrom(unit)
            -- Old chat/achievement message
            elseif(not self:GetSubject() == XF.Enum.Message.LINK) then
                unit:SetName(data.N)
                unit:SetUnitName(data.U)
                if(data.M ~= nil) then
                    unit:IsAlt(true)
                    unit:SetMainName(data.M)
                end            
                if(XFO.Guilds:Contains(data.H)) then
                    unit:SetGuild(XFO.Guilds:Get(data.H))
                end
                self:SetFrom(unit)
            end            
        --end
        
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
        XFO.Confederate:Push(unit)
    end)
end

function XFC.Message:Encode(inProtocol)
    local compressed = XF.Lib.Deflate:CompressDeflate(self:Serialize(), {level = XF.Settings.Network.CompressionLevel})
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
        segment = tostring(i) .. tostring(totalPackets) .. self:GetKey() .. segment
        packets[#packets + 1] = segment
    end
	return packets
end
--#endregion