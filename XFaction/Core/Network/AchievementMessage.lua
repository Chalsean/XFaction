local XFG, G = unpack(select(2, ...))
local ObjectName = 'AchievementMessage'
local LogCategory = 'NAMessage'

AchievementMessage = Message:newChildConstructor()

function AchievementMessage:new()
    local _Object = AchievementMessage.parent.new(self)

    _Object.__name = 'AchievementMessage'
    _Object._MainName = nil
    _Object._UnitName = nil
    
    return _Object
end

function AchievementMessage:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
    XFG:Debug(LogCategory, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
    XFG:Debug(LogCategory, "  _GuildID (" ..type(self._GuildID) .. "): ".. tostring(self._GuildID))
    XFG:Debug(LogCategory, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
    XFG:Debug(LogCategory, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    for _, _Target in pairs (self:GetTargets()) do
        _Target:Print()
    end
end

function AchievementMessage:HasMainName()
    return self._MainName ~= nil
end

function AchievementMessage:GetMainName()
    return self._MainName
end

function AchievementMessage:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self._MainName = inMainName
    return self:GetMainName()
end

function AchievementMessage:HasUnitName()
    return self._UnitName ~= nil
end

function AchievementMessage:GetUnitName()
    return self._UnitName
end

function AchievementMessage:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._UnitName = inUnitName
    return self:GetUnitName()
end

function AchievementMessage:Copy(inMessage)
    assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'AchievementMessage', "argument must be AchievementMessage object")
    self._Key = inMessage:GetKey()
    self._To = inMessage:GetTo()
    self._From = inMessage:GetFrom()
    self._Type = inMessage:GetType()
    self._GuildID = inMessage:GetGuildID()
    self._Subject = inMessage:GetSubject()
    self._EpochTime = inMessage:GetTimeStamp()
    self._Data = inMessage:GetData()
    self._Initialized = inMessage:IsInitialized()
    self._PacketNumber = inMessage:GetPacketNumber()
    self._TotalPackets = inMessage:GetTotalPackets()
    self._MainName = inMessage:GetMainName()
    self._UnitName = inMessage:GetUnitName()
    for _, _Target in pairs (self:GetTargets()) do
        self:RemoveTarget(_Target)
    end
    for _, _Target in pairs (inMessage:GetTargets()) do
        self:AddTarget(_Target)
    end
end