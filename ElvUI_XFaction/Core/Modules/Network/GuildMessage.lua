local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'GuildMessage'
local LogCategory = 'NGMessage'

GuildMessage = Message:newChildConstructor()

function GuildMessage:new()
    local _Object = GuildMessage.parent.new(self)

    _Object.__name = 'GuildMessage'
    _Object._FromGUID = nil
    _Object._Flags = nil
    _Object._LineID = nil
    _Object._Faction = nil
    _Object._GuildShortName = nil
    _Object._MainName = nil

    return _Object
end

function GuildMessage:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _To (" .. type(self._To) .. "): ".. tostring(self._To))
    XFG:Debug(LogCategory, "  _From (" ..type(self._From) .. "): ".. tostring(self._From))
    XFG:Debug(LogCategory, "  _FromGUID (" ..type(self._FromGUID) .. "): ".. tostring(self._FromGUID))
    XFG:Debug(LogCategory, "  _Flags (" ..type(self._Flags) .. "): ".. tostring(self._Flags))
    XFG:Debug(LogCategory, "  _LineID (" ..type(self._LineID) .. "): ".. tostring(self._LineID))
    XFG:Debug(LogCategory, "  _Faction (" ..type(self._Faction) .. "): ".. tostring(self._Faction))
    XFG:Debug(LogCategory, "  _GuildShortName (" ..type(self._GuildShortName) .. "): ".. tostring(self._GuildShortName))
    XFG:Debug(LogCategory, "  _MainName (" ..type(self._MainName) .. "): ".. tostring(self._MainName))
    XFG:Debug(LogCategory, "  _Type (" ..type(self._Type) .. "): ".. tostring(self._Type))
    XFG:Debug(LogCategory, "  _Subject (" ..type(self._Subject) .. "): ".. tostring(self._Subject))
    XFG:Debug(LogCategory, "  _EpochTime (" ..type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
    XFG:Debug(LogCategory, "  _Data (" ..type(self._Data) .. ")")
    XFG:Debug(LogCategory, "  _Initialized (" ..type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function GuildMessage:GetFromGUID()
    return self._FromGUID
end

function GuildMessage:SetFromGUID(inFromGUID)
    assert(type(inFromGUID) == 'string')
    self._FromGUID = inFromGUID
    return self:GetFromGUID()
end

function GuildMessage:GetFlags()
    return self._Flags
end

function GuildMessage:SetFlags(inFlags)
    assert(type(inFlags) == 'string')
    self._Flags = inFlags
    return self:GetFlags()
end

function GuildMessage:GetLineID()
    return self._LineID
end

function GuildMessage:SetLineID(inLineID)
    assert(type(inLineID) == 'number')
    self._LineID = inLineID
    return self:GetLineID()
end

function GuildMessage:GetFaction()
    return self._Faction
end

function GuildMessage:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', "argument must be Faction object")
    self._Faction = inFaction
    return self:GetFaction()
end

function GuildMessage:GetGuildShortName()
    return self._GuildShortName
end

function GuildMessage:SetGuildShortName(inGuildShortName)
    assert(type(inGuildShortName) == 'string')
    self._GuildShortName = inGuildShortName
    return self:GetGuildShortName()
end

function GuildMessage:GetMainName()
    return self._MainName
end

function GuildMessage:SetMainName(inMainName)
    assert(type(inMainName) == 'string')
    self._MainName = inMainName
    return self:GetMainName()
end