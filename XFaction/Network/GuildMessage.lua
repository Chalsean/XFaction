local XFG, G = unpack(select(2, ...))

GuildMessage = Message:newChildConstructor()

function GuildMessage:new()
    local _Object = GuildMessage.parent.new(self)
    _Object.__name = 'GuildMessage'
    _Object._UnitName = nil
    _Object._MainName = nil
    _Object._Guild = nil
    _Object._Realm = nil
    return _Object
end

function GuildMessage:Print()
    self:ParentPrint()
    XFG:Debug(self:GetObjectName(), "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(self:GetObjectName(), "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(self:GetObjectName(), "  _PacketNumber (" ..type(self._PacketNumber) .. "): ".. tostring(self._PacketNumber))
    XFG:Debug(self:GetObjectName(), "  _TotalPackets (" ..type(self._TotalPackets) .. "): ".. tostring(self._TotalPackets))
    XFG:Debug(self:GetObjectName(), "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
    XFG:Debug(self:GetObjectName(), "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
    XFG:Debug(self:GetObjectName(), "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(self:GetObjectName(), "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(self:GetObjectName(), "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(self:GetObjectName(), "  _Data (" ..type(self._Data) .. ")")
    XFG:DataDumper(self:GetObjectName(), self._Data)
    XFG:Debug(self:GetObjectName(), "  _Version (" ..type(self._Version) .. "): ".. tostring(self._Version))
    if(self:HasRealm()) then self:GetRealm():Print() end
    if(self:HasGuild()) then self:GetGuild():Print() end
    XFG:Debug(self:GetObjectName(), "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    for _, _Target in pairs (self:GetTargets()) do
        _Target:Print()
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