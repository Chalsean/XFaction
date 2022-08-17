local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildMessage'

GuildMessage = Message:newChildConstructor()

function GuildMessage:new()
    local _Object = GuildMessage.parent.new(self)
    _Object.__name = ObjectName
    _Object._UnitName = nil
    _Object._MainName = nil
    _Object._Guild = nil
    _Object._Realm = nil
    return _Object
end

function GuildMessage:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _FactoryKey (" .. type(self._FactoryKey) .. "): ".. tostring(self._FactoryKey))
        XFG:Debug(ObjectName, "  _FactoryTime (" .. type(self._FactoryTime) .. "): ".. tostring(self._FactoryTime))
        XFG:Debug(ObjectName, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
        XFG:Debug(ObjectName, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
        XFG:Debug(ObjectName, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
        XFG:Debug(ObjectName, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
        XFG:Debug(ObjectName, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
        XFG:Debug(ObjectName, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
        XFG:Debug(ObjectName, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
        XFG:Debug(ObjectName, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
        XFG:Debug(ObjectName, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
        XFG:Debug(ObjectName, self._Data)
        if(self:HasVersion()) then self:GetVersion():Print() end
        if(self:HasRealm()) then self:GetRealm():Print() end
        if(self:HasGuild()) then self:GetGuild():Print() end
        XFG:Debug(ObjectName, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
        for _, _Target in pairs (self:GetTargets()) do
            _Target:Print()
        end
    end
end

function GuildMessage:ShallowPrint()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _FactoryKey (" .. type(self._FactoryKey) .. "): ".. tostring(self._FactoryKey))
        XFG:Debug(ObjectName, "  _FactoryTime (" .. type(self._FactoryTime) .. "): ".. tostring(self._FactoryTime))
        XFG:Debug(ObjectName, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
        XFG:Debug(ObjectName, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
        XFG:Debug(ObjectName, "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
        XFG:Debug(ObjectName, "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
        XFG:Debug(ObjectName, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
        XFG:Debug(ObjectName, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
        XFG:Debug(ObjectName, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
        XFG:Debug(ObjectName, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
        XFG:Debug(ObjectName, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
        XFG:Debug(ObjectName, self._Data)
        if(self:HasVersion()) then self:GetVersion():Print() end
    end
end

function GuildMessage:GetUnitName()
    return self._UnitName
end

function GuildMessage:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._UnitName = inUnitName
    return self:GetUnitName()
end

function GuildMessage:HasMainName()
    return self._MainName ~= nil
end

function GuildMessage:GetMainName()
    return self._MainName
end

function GuildMessage:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self._MainName = inMainName
    return self:GetMainName()
end

function GuildMessage:HasGuild()
    return self._Guild ~= nil
end

function GuildMessage:GetGuild()
    return self._Guild
end

function GuildMessage:SetGuild(inGuild)
    assert(type(inGuild) == 'table' and inGuild.__name ~= nil and inGuild.__name == 'Guild', 'argument must be Guild object')
    self._Guild = inGuild
    return self:GetGuild()
end

function GuildMessage:HasRealm()
    return self._Realm ~= nil
end

function GuildMessage:GetRealm()
    return self._Realm
end

function GuildMessage:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    self._Realm = inRealm
    return self:GetRealm()
end

function GuildMessage:FactoryReset()
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
    self._Name = nil
    self._UnitName = nil
    self._MainName = nil
    self._Guild = nil
    self._Realm = nil
    self:Initialize()
end