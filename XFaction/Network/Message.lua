local XFG, G = unpack(select(2, ...))
local ObjectName = 'Message'
local ServerTime = GetServerTime

Message = Object:newChildConstructor()

--#region Constructors
function Message:new()
    local object = Message.parent.new(self)
    object.__name = 'Message'
    object.to = nil
    object.from = nil
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
    object.realm = nil
    return object
end
--#endregion

--#region Initializers
function Message:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.targets = {}
        self:SetFrom(XFG.Player.Unit:GetGUID())
        self:SetTimeStamp(ServerTime())
        self:SetAllTargets()
        self:SetVersion(XFG.Version)
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Message:Deconstructor()
    self:ParentDeconstructor()
    self.to = nil
    self.from = nil
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
    self.realm = nil
    self:Initialize()
end
--#endregion

--#region Print
function Message:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  to (' .. type(self.to) .. '): ' .. tostring(self.to))
    XFG:Debug(ObjectName, '  from (' .. type(self.from) .. '): ' .. tostring(self.from))
    XFG:Debug(ObjectName, '  packetNumber (' .. type(self.packetNumber) .. '): ' .. tostring(self.packetNumber))
    XFG:Debug(ObjectName, '  totalPackets (' .. type(self.totalPackets) .. '): ' .. tostring(self.totalPackets))
    XFG:Debug(ObjectName, '  type (' .. type(self.type) .. '): ' .. tostring(self.type))
    XFG:Debug(ObjectName, '  subject (' .. type(self.subject) .. '): ' .. tostring(self.subject))
    XFG:Debug(ObjectName, '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    XFG:Debug(ObjectName, '  unitName (' .. type(self.unitName) .. '): ' .. tostring(self.unitName))
    XFG:Debug(ObjectName, '  mainName (' .. type(self.mainName) .. '): ' .. tostring(self.mainName))
    XFG:Debug(ObjectName, '  targetCount (' .. type(self.targetCount) .. '): ' .. tostring(self.targetCount))
    if(self:HasVersion()) then self:GetVersion():Print() end
end
--#endregion

--#region Accessors
function Message:GetTo()
    return self.to
end

function Message:SetTo(inTo)
    assert(type(inTo) == 'string')
    self.to = inTo
end

function Message:GetFrom()
    return self.from
end

function Message:SetFrom(inFrom)
    assert(type(inFrom) == 'string')
    self.from = inFrom
end

function Message:GetType()
    return self.type
end

function Message:SetType(inType)
    assert(type(inType) == 'string')
    self.type = inType
end

function Message:GetSubject()
    return self.subject
end

function Message:SetSubject(inSubject)
    assert(type(inSubject) == 'string')
    self.subject = inSubject
end

function Message:GetTimeStamp()
    return self.epochTime
end

function Message:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.epochTime = inEpochTime
end

function Message:GetData()
    return self.data
end

function Message:SetData(inData)
    self.data = inData
end

function Message:GetPacketNumber()
    return self.packetNumber
end

function Message:SetPacketNumber(inPacketNumber)
    assert(type(inPacketNumber) == 'number')
    self.packetNumber = inPacketNumber
end

function Message:GetTotalPackets()
    return self.totalPackets
end

function Message:SetTotalPackets(inTotalPackets)
    assert(type(inTotalPackets) == 'number')
    self.totalPackets = inTotalPackets
end

function Message:HasUnitData()
    return self:GetSubject() == XFG.Settings.Network.Message.Subject.DATA or 
           self:GetSubject() == XFG.Settings.Network.Message.Subject.LOGIN or
           self:GetSubject() == XFG.Settings.Network.Message.Subject.JOIN
end

function Message:HasVersion()
    return self.version ~= nil
end

function Message:GetVersion()
    return self.version
end

function Message:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
    self.version = inVersion
end

function Message:IsMyMessage()
    return XFG.Player.Unit:GetGUID() == self:GetFrom()
end

function Message:GetUnitName()
    return self.unitName
end

function Message:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self.unitName = inUnitName
end

function Message:HasMainName()
    return self.mainName ~= nil
end

function Message:GetMainName()
    return self.mainName
end

function Message:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self.mainName = inMainName
end

function Message:HasGuild()
    return self.guild ~= nil
end

function Message:GetGuild()
    return self.guild
end

function Message:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name == 'Guild', 'argument must be Guild object')
    self.guild = inGuild
end

function Message:HasRealm()
    return self.realm ~= nil
end

function Message:GetRealm()
    return self.realm
end

function Message:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
end
--#endregion

--#region Target
function Message:ContainsTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    return self.targets[inTarget:GetKey()] ~= nil
end

function Message:AddTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(not self:ContainsTarget(inTarget)) then
        self.targetCount = self.targetCount + 1
    end
    self.targets[inTarget:GetKey()] = inTarget
end

function Message:RemoveTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    if(self:ContainsTarget(inTarget)) then
        self.targets[inTarget:GetKey()] = nil
        self.targetCount = self.targetCount - 1
    end
end

function Message:SetAllTargets()
    for _, target in XFG.Targets:Iterator() do
        if(not target:Equals(XFG.Player.Target)) then
            self:AddTarget(target)
        end
    end
end

function Message:HasTargets()
    return self.targetCount > 0
end

function Message:GetTargets()
    if(self:HasTargets()) then return self.targets end
    return {}
end

function Message:GetTargetCount()
    return self.targetCount
end

function Message:GetRemainingTargets()
    local targetsString = ''
    for _, target in pairs (self:GetTargets()) do
        targetsString = targetsString .. '|' .. target:GetKey()
    end
    return targetsString
end

function Message:SetRemainingTargets(inTargetString)
    wipe(self.targets)
    self.targetCount = 0
    local targets = string.Split(inTargetString, '|')
    for _, key in pairs (targets) do
        if(key ~= nil and XFG.Targets:Contains(key)) then
            local target = XFG.Targets:Get(key)
            if(not XFG.Player.Target:Equals(target)) then
                self:AddTarget(target)
            end
        end
    end
end
--#endregion