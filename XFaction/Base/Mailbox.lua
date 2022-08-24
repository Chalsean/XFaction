local XFG, G = unpack(select(2, ...))
local ObjectName = 'Mailbox'

local ServerTime = GetServerTime

Mailbox = Factory:newChildConstructor()

function Mailbox:new()
    local _Object = Mailbox.parent.new(self)
	_Object.__name = ObjectName
	_Object._Objects = nil
    _Object._ObjectCount = 0   
    _Object._Packets = nil
	return _Object
end

function Mailbox:newChildConstructor()
    local _Object = Mailbox.parent.new(self)
    _Object.__name = ObjectName
    _Object.parent = self 
	_Object._Objects = nil
    _Object._ObjectCount = 0   
    _Object._Packets = nil
    return _Object
end

function Mailbox:NewObject()
	return Message:new()
end

function Mailbox:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self:IsInitialized(true)
	end
end

function Mailbox:ParentInitialize()
    self._Packets = {}
    self._Objects = {}
    self._CheckedIn = {}
    self._CheckedOut = {}
    self._Key = math.GenerateUID()
end

function Mailbox:ContainsPacket(inKey)
	assert(type(inKey) == 'string')
	return self._Packets[inKey] ~= nil
end

function Mailbox:Add(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and string.find(inMessage.__name, 'Message'), "argument must be Message type object")
	if(not self:Contains(inMessage:GetKey())) then
		self._Objects[inMessage:GetKey()] = ServerTime()
	end
end

function Mailbox:AddPacket(inMessageKey, inPacketNumber, inData)
    assert(type(inMessageKey) == 'string')
    assert(type(inPacketNumber) == 'number')
    assert(type(inData) == 'string')
    if(not self:ContainsPacket(inMessageKey)) then
        self._Packets[inMessageKey] = {}
        self._Packets[inMessageKey].Count = 0
    end
    self._Packets[inMessageKey][inPacketNumber] = inData
    self._Packets[inMessageKey].Count = self._Packets[inMessageKey].Count + 1
end

function Mailbox:RemovePacket(inKey)
	assert(type(inKey) == 'string')
	if(self:ContainsPacket(inKey)) then
		self._Packets[inKey] = nil
	end
end

function Mailbox:SegmentMessage(inEncodedData, inMessageKey)
	assert(type(inEncodedData) == 'string')
	local _Packets = {}
    local _TotalPackets = ceil(strlen(inEncodedData) / XFG.Settings.Network.PacketSize)
    for i = 1, _TotalPackets do
        local _Segment = string.sub(inEncodedData, XFG.Settings.Network.PacketSize * (i - 1) + 1, XFG.Settings.Network.PacketSize * i)
        _Segment = tostring(i) .. tostring(_TotalPackets) .. inMessageKey .. _Segment
        _Packets[#_Packets + 1] = _Segment
    end
	return _Packets
end

function Mailbox:HasAllPackets(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    assert(type(inTotalPackets) == 'number')
    if(self._Packets[inKey] == nil) then return false end
    return self._Packets[inKey].Count == inTotalPackets
end

function Mailbox:RebuildMessage(inKey, inTotalPackets)
    assert(type(inKey) == 'string')
    local _Message = ''
    -- Stitch the data back together again
    for i = 1, inTotalPackets do
        _Message = _Message .. self._Objects[inKey][i]
    end
    self:RemovePacket(inKey)
	return _MessageData
end

function Mailbox:Purge(inEpochTime)
	assert(type(inEpochTime) == 'number')
	for _Key, _ReceivedTime in self:Iterator() do
		if(_ReceivedTime < inEpochTime) then
			self:Remove(_Key)
		end
	end
end

function Mailbox:IsAddonTag(inTag)
	local _AddonTag = false
    for _, _Tag in pairs (XFG.Settings.Network.Message.Tag) do
        if(inTag == _Tag) then
            _AddonTag = true
            break
        end
    end
	return _AddonTag
end