local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Message'

XFC.Message = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Message:new()
    local object = XFC.Message.parent.new(self)
    object.__name = ObjectName
    object.from = nil
    object.type = nil
    object.subject = nil
    object.epochTime = nil
    object.data = nil
    object.initialized = false
    object.packetNumber = 1
    object.totalPackets = 1
    object.links = nil
    return object
end

function XFC.Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:From(XF.Player.Unit)
        self:TimeStamp(XFF.TimeCurrent())

        for _, target in XFO.Targets:Iterator() do
            if(not target:Equals(XF.Player.Target)) then
                self:Add(target)
            end
        end

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
    self.data = nil
    self.packetNumber = 1
    self.totalPackets = 1
    self.links = nil
end
--#endregion

--#region Properties
function XFC.Message:From(inFrom)
    assert(type(inFrom) == 'table' and inFrom.__name == 'Unit' or inFrom == nil)
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

function XFC.Message:Links(inSerialized)
    assert(type(inSerialized) == 'string' or inSerialized == nil)
    if(inSerialized ~= nil) then
        self.links = inSerialized
    end
    return self.links
end
--#endregion

--#region Methods
function XFC.Message:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  packetNumber (' .. type(self.packetNumber) .. '): ' .. tostring(self.packetNumber))
    XF:Debug(self:ObjectName(), '  totalPackets (' .. type(self.totalPackets) .. '): ' .. tostring(self.totalPackets))
    XF:Debug(self:ObjectName(), '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XF:Debug(self:ObjectName(), '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XF:Debug(self:ObjectName(), '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XF:Debug(self:ObjectName(), '  links (' .. type(self.links) .. '): ' .. tostring(self.links))
end

function XFC.Message:IsMyMessage()
    return XF.Player.GUID == self:From():GUID()
end

function XFC.Message:HasTargets()
    return self:Count() > 0
end

function XFC.Message:Encode(inTag)
    assert(type(inTag) == 'string' or inTag == nil)
    local serialized = self:Serialize()
	local compressed = XF.Lib.Deflate:CompressDeflate(serialized, {level = XF.Settings.Network.CompressionLevel})
    return inTag == XF.Enum.Tag.BNET and XF.Lib.Deflate:EncodeForPrint(compressed) or XF.Lib.Deflate:EncodeForWoWAddonChannel(compressed)
end

function XFC.Message:Serialize()
    local data = {}

    data.D = self:Data()	
	data.F = self:From():Serialize()	
	data.K = self:Key()
    data.L = self:Links()
	data.N = self:PacketNumber()
	data.P = self:TotalPackets()
    data.S = self:Subject()
    data.T = self:TimeStamp()
    data.Y = self:Type()

    local targets = ''
    for _, target in self:Iterator() do
        targets = targets .. ';' .. target:Serialize()
    end
    if(string.len(targets) > 0) then
        data.R = targets
    end

	return pickle(data)
end

function XFC.Message:Decode(inEncoded, inTag)
    assert(type(inEncoded) == 'string')
    assert(type(inTag) == 'string' or inTag == nil)

    local decoded = XF.Enum.Tag.BNET and XF.Lib.Deflate:DecodeForPrint(inEncoded) or XF.Lib.Deflate:DecodeForWoWAddonChannel(inEncoded)
    local decompressed = XF.Lib.Deflate:DecompressDeflate(decoded)
    self:Deserialize(decompressed)
end

function XFC.Message:Deserialize(inSerial)
    assert(type(inSerial) == 'string')
    local data = unpickle(inSerial)

    self:Data(data.D)
    self:Key(data.K)
    self:Links(data.L)
    self:PacketNumber(data.N)
    self:TotalPackets(data.P)
    self:Subject(data.S)
    self:TimeStamp(data.T)
    self:Type(data.Y)
    
    local unit = nil
    try(function()
        unit = XFO.Confederate:Pop()
        unit:Deserialize(data.F)
        XFO:Confederate:Add(unit)
        self:From(unit)
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
        XFO.Confederate:Push(unit)
    end)

    if(data.R ~= nil) then
        local targets = string.Split(data.R, ';')
        for _, target in ipairs(targets) do
            self:Add(XFO.Targets:Get(target))
        end
    end
end
--#endregion