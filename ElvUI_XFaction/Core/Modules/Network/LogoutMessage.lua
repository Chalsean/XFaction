local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'LogoutMessage'
local LogCategory = 'NLMessage'

LogoutMessage = Message:newChildConstructor()

function LogoutMessage:new()
    local _Object = LogoutMessage.parent.new(self)

    _Object.__name = 'LogoutMessage'
    _Object._MainName = nil
    _Object._UnitName = nil
    
    return _Object
end

function LogoutMessage:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _GuildID (" ..type(self._GuildID) .. "): ".. tostring(self._GuildID))
    XFG:Debug(LogCategory, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
    XFG:Debug(LogCategory, "  _UnitName (" ..type(self._UnitName) .. "): ".. tostring(self._UnitName))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
    XFG:Debug(LogCategory, "  _TargetCount (" ..type(self._TargetCount) .. "): ".. tostring(self._TargetCount))
    for _, _Target in self:TargetIterator() do
        _Target:Print()
    end
end

function LogoutMessage:HasMainName()
    return self._MainName ~= nil
end

function LogoutMessage:GetMainName()
    return self._MainName
end

function LogoutMessage:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self._MainName = inMainName
    return self:GetMainName()
end

function LogoutMessage:HasUnitName()
    return self._UnitName ~= nil
end

function LogoutMessage:GetUnitName()
    return self._UnitName
end

function LogoutMessage:SetUnitName(inUnitName)
    assert(type(inUnitName) == 'string')
    self._UnitName = inUnitName
    return self:GetUnitName()
end