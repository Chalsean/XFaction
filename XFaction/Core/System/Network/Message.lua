local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Message'

XFC.Message = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Message:new()
    local object = XFC.Message.parent.new(self)
    object.__name = ObjectName
    object.from = nil
    object.fromUnit = nil
    object.subject = nil
    object.epochTime = nil
    object.data = nil
    object.initialized = false
    object.totalPackets = 1
    object.links = nil    
    return object
end

function XFC.Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:From(XF.Player.GUID)
        self:FromUnit(XF.Player.Unit)
        self:TimeStamp(XFF.TimeCurrent())
        self:Links(XFO.Links:Serialize(true))

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
    self.fromUnit = nil
    self.subject = nil
    self.epochTime = nil
    self.data = nil
    self.totalPackets = 1
    self.links = nil    
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

function XFC.Message:FromUnit(inUnit)
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit' or inUnit == nil)
    if(inUnit ~= nil) then
        self.fromUnit = inUnit
    end
    return self.fromUnit
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
    XF:Debug(self:ObjectName(), '  totalPackets (' .. type(self.totalPackets) .. '): ' .. tostring(self.totalPackets))
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

function XFC.Message:HasFromUnit()
    return self:FromUnit() ~= nil
end

function XFC.Message:HasLinks()
    return self:Links() ~= nil and string.len(self:Links()) > 0
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
	data.F = self:From()
	data.K = self:Key()
    data.L = self:Links()
	data.P = self:TotalPackets()
    data.S = self:Subject()
    data.T = self:TimeStamp()
    data.U = self:HasFromUnit() and self:FromUnit():Serialize() or nil

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

    self:ParentInitialize()

    self:Data(data.D)
    self:From(data.F)
    -- self:FromUnit(XFO.Confederate:Deserialize(data.U))
    self:Key(data.K)
    -- self:Links(data.L)
    self:TotalPackets(data.P)
    self:Subject(data.S)
    self:TimeStamp(data.T)
    
    -- if(data.R ~= nil) then
    --     local targets = string.Split(data.R, ';')
    --     for _, target in ipairs(targets) do
    --         self:Add(XFO.Targets:Get(target))
    --     end
    -- end
end
--#endregion