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
    self._To = nil
    self._From = nil
    self._Type = nil
    self._Subject = nil
    self._EpochTime = nil
    self._TargetCount = 0
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
    self._To = nil
    self._From = nil    
    self._Type = nil
    self._Subject = nil
    self._EpochTime = nil    
    self._TargetCount = 0
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
    XFG:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
    XFG:Debug(LogCategory, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    if(self:HasVersion()) then self._Version:Print() end
    for _, _Target in pairs (self:GetTargets()) do
        _Target:Print()
    end
end

function Message:ShallowPrint()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
    XFG:Debug(LogCategory, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    if(self:HasVersion()) then self._Version:Print() end
end

function Message:GetKey()
    return self._Key
end

function Message:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function Message:GetTo()
    return self._To
end

function Message:SetTo(inTo)
    assert(type(inTo) == 'string')
    self._To = inTo
    return self:GetTo()
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
        self._Targets[inTarget:GetKey()] = nil
        self._TargetCount = self._TargetCount - 1
    end
    return self:ContainsTarget(inTarget) == false
end

function Message:SetAllTargets()
    for _, _Target in XFG.Targets:Iterator() do
        if(not _Target:Equals(XFG.Player.Target)) then
            self:AddTarget(_Target)
        end
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
            local _Target = XFG.Targets:GetTargetByKey(_TargetKey)
            if(not XFG.Player.Target:Equals(_Target)) then
                self:AddTarget(_Target)
            end
        end
    end
end

function Message:Copy(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', "argument must be Message object")
    self._Key = inMessage:GetKey()
    self._To = inMessage:GetTo()
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
end

function Message:HasUnitData()
    return self:GetSubject() == XFG.Settings.Network.Message.Subject.DATA or self:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN
end

function Message:HasVersion()
    return self._Version ~= nil
end

function Message:GetVersion()
    return self._Version
end

function Message:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
    self._Version = inVersion
    return self:GetVersion()
end

function Message:IsMyMessage()
    return XFG.Player.Unit:GetGUID() == self:GetFrom()
end