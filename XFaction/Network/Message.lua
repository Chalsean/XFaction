local XFG, G = unpack(select(2, ...))
local ObjectName = 'Message'

local ServerTime = GetServerTime

Message = Object:newChildConstructor()

function Message:new()
    local _Object = Message.parent.new(self)
    _Object.__name = 'Message'
    _Object._To = nil
    _Object._From = nil
    _Object._Type = nil
    _Object._Subject = nil
    _Object._EpochTime = nil
    _Object._Targets = nil
    _Object._TargetCount = 0
    _Object._Data = nil
    _Object._Initialized = false
    _Object._PacketNumber = 1
    _Object._TotalPackets = 1
    _Object._Version = nil
    _Object._UnitName = nil
    _Object._MainName = nil
    _Object._Guild = nil
    _Object._Realm = nil
    return _Object
end

function Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self._Targets = {}
        self:SetFrom(XFG.Player.Unit:GetKey())
        self:SetTimeStamp(ServerTime())
        self:SetAllTargets()
        self:SetVersion(XFG.Version)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Message:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
        XFG:Debug(ObjectName, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
        XFG:Debug(ObjectName, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
        XFG:Debug(ObjectName, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
        XFG:Debug(ObjectName, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
        XFG:Debug(ObjectName, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
        XFG:Debug(ObjectName, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
        XFG:Debug(ObjectName, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
        XFG:Debug(ObjectName, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
        XFG:Debug(ObjectName, "  _Data (" ..type(self._Data) .. ")")
        XFG:Debug(ObjectName, self._Data)
        if(self:HasGuild()) then self:GetGuild():Print() end
        if(self:HasRealm()) then self:GetRealm():Print() end
        XFG:Debug(ObjectName, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
        if(self:HasVersion()) then self._Version:Print() end
        for _, _Target in pairs (self:GetTargets()) do
            _Target:Print()
        end
    end
end

function Message:ShallowPrint()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
        XFG:Debug(ObjectName, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
        XFG:Debug(ObjectName, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
        XFG:Debug(ObjectName, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
        XFG:Debug(ObjectName, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
        XFG:Debug(ObjectName, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
        XFG:Debug(ObjectName, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
        XFG:Debug(ObjectName, "  _Data (" ..type(self._Data) .. ")")
        XFG:Debug(ObjectName, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
        XFG:Debug(ObjectName, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
        XFG:Debug(ObjectName, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
        if(self:HasVersion()) then self._Version:Print() end
    end
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
        if(_TargetKey ~= nil and XFG.Targets:Contains(_TargetKey)) then
            local _Target = XFG.Targets:Get(_TargetKey)
            if(not XFG.Player.Target:Equals(_Target)) then
                self:AddTarget(_Target)
            end
        end
    end
end

function Message:HasUnitData()
    return self:GetSubject() == XFG.Settings.Network.Message.Subject.DATA or 
           self:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN or
           self:GetSubject() == XFG.Settings.Network.Message.Subject.JOIN
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

function Message:GetUnitName()
    return self._UnitName
end

function Message:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._UnitName = inUnitName
    return self:GetUnitName()
end

function Message:HasMainName()
    return self._MainName ~= nil
end

function Message:GetMainName()
    return self._MainName
end

function Message:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self._MainName = inMainName
    return self:GetMainName()
end

function Message:HasGuild()
    return self._Guild ~= nil
end

function Message:GetGuild()
    return self._Guild
end

function Message:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
    self._Guild = inGuild
    return self:GetGuild()
end

function Message:HasRealm()
    return self._Realm ~= nil
end

function Message:GetRealm()
    return self._Realm
end

function Message:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    self._Realm = inRealm
    return self:GetRealm()
end

function Message:FactoryReset()
    self:ParentFactoryReset()
    self._To = nil
    self._From = nil
    self._Type = nil
    self._Subject = nil
    self._EpochTime = nil
    self._Targets = nil
    self._TargetCount = 0
    self._Data = nil
    self._PacketNumber = 1
    self._TotalPackets = 1
    self._Version = nil
    self._UnitName = nil
    self._MainName = nil
    self._Guild = nil
    self._Realm = nil
    self:Initialize()
end