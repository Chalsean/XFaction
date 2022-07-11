local XFG, G = unpack(select(2, ...))
local ObjectName = 'Message'
local LogCategory = 'NMessage'

Message = {}

function Message:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    
    self._Key = nil
    self._From = nil
    self._Type = nil
    self._Subject = nil
    self._EpochTime = nil
    self._TargetCount = 0
    self._NodeCount = 0
    self._Data = nil
    self._Initialized = false
    self._PacketNumber = 1
    self._TotalPackets = 1
    self._Version = nil

    return _Object
end

function Message:newChildConstructor()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName
    self.parent = self
    
    self._Key = nil
    self._From = nil   
    self._Type = nil
    self._Subject = nil
    self._EpochTime = nil    
    self._TargetCount = 0
    self._NodeCount = 0
    self._Data = nil
    self._Initialized = false
    self._PacketNumber = 1
    self._TotalPackets = 1
    self._Version = nil

    return _Object
end

function Message:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function Message:Initialize()
    if(self:IsInitialized() == false) then
        self._Targets = {}
        self._Nodes = {}
        self:SetKey(math.GenerateUID())
        self:SetFrom(XFG.Player.Unit:GetKey())
        local _EpochTime = GetServerTime()
        self:SetTimeStamp(_EpochTime)
        self:SetAllTargets()
        self:SetVersion(XFG.Version)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Message:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _Nodes (" ..type(self._Nodes) .. "): ".. tostring(self._Nodes))
    XFG:Debug(LogCategory, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
    XFG:Debug(LogCategory, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _Version (" ..type(self._Version) .. "): ".. tostring(self._Version))
    XFG:Debug(LogCategory, "  _NodeCount (" ..type(self._NodeCount) .. "): ".. tostring(self._NodeCount))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    for _, _Target in pairs (self:GetTargets()) do
        _Target:Print()
    end
    for _, _Node in self:NodeIterator() do
        _Node:Print()
    end
end

function Message:ShallowPrint()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _Nodes (" ..type(self._Nodes) .. "): ".. tostring(self._Nodes))
    XFG:Debug(LogCategory, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
    XFG:Debug(LogCategory, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _Version (" ..type(self._Version) .. "): ".. tostring(self._Version))
    XFG:Debug(LogCategory, "  _NodeCount (" ..type(self._NodeCount) .. "): ".. tostring(self._NodeCount))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
end

function Message:GetKey()
    return self._Key
end

function Message:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Message:GetFrom()
    return self._From
end

function Message:SetFrom(inFrom)
    assert(type(inFrom) == 'string')
    self._From = inFrom
    return self:GetFrom()
end

function Message:GetType()
    return self._Type
end

function Message:SetType(inType)
    assert(type(inType) == 'string')
    self._Type = inType
    return self:GetType()
end

function Message:GetSubject()
    return self._Subject
end

function Message:SetSubject(inSubject)
    assert(type(inSubject) == 'string')
    self._Subject = inSubject
    return self:GetSubject()
end

function Message:GetTimeStamp()
    return self._EpochTime
end

function Message:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self._EpochTime = inEpochTime
    return self:GetTimeStamp()
end

function Message:GetData()
    return self._Data
end

function Message:SetData(inData)
    self._Data = inData
    return self:GetData()
end

function Message:GetPacketNumber()
    return self._PacketNumber
end

function Message:SetPacketNumber(inPacketNumber)
    assert(type(inPacketNumber) == 'number')
    self._PacketNumber = inPacketNumber
    return self:GetPacketNumber()
end

function Message:GetTotalPackets()
    return self._TotalPackets
end

function Message:SetTotalPackets(inTotalPackets)
    assert(type(inTotalPackets) == 'number')
    self._TotalPackets = inTotalPackets
    return self:GetTotalPackets()
end

function Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    return self._Targets[inTarget:GetKey()] ~= nil
end

function Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    if(self:ContainsTarget(inTarget) == false) then
        self._TargetCount = self._TargetCount + 1
    end
    self._Targets[inTarget:GetKey()] = inTarget
    return self:ContainsTarget(inTarget)
end

function Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    if(self:ContainsTarget(inTarget)) then
        table.RemoveKey(self._Targets, inTarget:GetKey())
        self._TargetCount = self._TargetCount - 1
    end
    return self:ContainsTarget(inTarget) == false
end

function Message:SetAllTargets()
    for _, _Target in XFG.Targets:Iterator() do
        self:AddTarget(_Target)
    end
end

function Message:HasTargets()
    return self._TargetCount > 0
end

function Message:GetTargets()
    if(self:HasTargets()) then return self._Targets end
    return {}
end

function Message:GetTargetCount()
    return self._TargetCount
end

function Message:GetRemainingTargets()
    local _TargetsString = ''
    for _, _Target in pairs (self:GetTargets()) do
        _TargetsString = _TargetsString .. '|' .. _Target:GetKey()
    end
    return _TargetsString
end

function Message:SetRemainingTargets(inTargetString)
    wipe(self._Targets)
    self._TargetCount = 0
    local _Targets = string.Split(inTargetString, '|')
    for _, _TargetKey in pairs (_Targets) do
        if(_TargetKey ~= nil and XFG.Targets:ContainsByKey(_TargetKey)) then
            self:AddTarget(XFG.Targets:GetTargetByKey(_TargetKey))
        end
    end
end

function Message:Copy(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
    self._Key = inMessage:GetKey()
    self._From = inMessage:GetFrom()
    self._Type = inMessage:GetType()
    self._Subject = inMessage:GetSubject()
    self._EpochTime = inMessage:GetTimeStamp()
    self._Data = inMessage:GetData()
    self._Initialized = inMessage:IsInitialized()
    self._PacketNumber = inMessage:GetPacketNumber()
    self._TotalPackets = inMessage:GetTotalPackets()
    self._Version = inMessage:GetVersion()
    for _, _Target in pairs (self:GetTargets()) do
        self:RemoveTarget(_Target)
    end
    for _, _Target in pairs (inMessage:GetTargets()) do
        self:AddTarget(_Target)
    end
    for _, _Node in self:NodeIterator() do
        self:RemoveNode(_Node)
    end
    for _, _Node in inMessage:NodeIterator() do
        self:AddNode(_Node)
    end
end

function Message:HasUnitData()
    return self:GetSubject() == XFG.Settings.Network.Message.Subject.DATA or self:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN
end

function Message:GetVersion()
    return self._Version
end

function Message:SetVersion(inVersion)
    assert(type(inVersion) == 'string')
    self._Version = inVersion
    return self:GetVersion()
end

function Message:HasNodes()
    return self:GetNodeCount() > 0
end

function Message:GetNodeCount()
    return self._NodeCount
end

function Message:ContainsNode(inKey)
    assert(type(inKey) == 'string')
    return self._Nodes[inKey] ~= nil
end

function Message:AddNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    if(not self:ContainsNode(inNode:GetKey())) then
        self._NodeCount = self._NodeCount + 1
    end
    self._Nodes[inNode:GetKey()] = inNode
    return self:ContainsNode(inNode:GetKey())
end

function Message:RemoveNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    if(self:ContainsNode(inNode:GetKey())) then
        self._NodeCount = self._NodeCount - 1
    end
    self._Nodes[inNode:GetKey()] = nil
    return not self:ContainsNode(inNode:GetKey())
end

function Message:RemoveAllNodes()
    self._Nodes = {}
    self._NodeCount = 0
    return self._NodeCount == 0
end

function Message:NodeIterator()
	return next, self._Nodes, nil
end