local XFG, G = unpack(select(2, ...))
local ObjectName = 'Guild'

Guild = Object:newChildConstructor()

function Guild:new()
    local _Object = Guild.parent.new(self)
    _Object.__name = ObjectName
    _Object._ID = nil        -- Only the player's guild will have an ID
    _Object._StreamID = nil  -- Only the player's guild will have a StreamerID (this is gchat)
    _Object._Initials = nil
    _Object._Faction = nil
    _Object._Realm = nil
    return _Object
end

function Guild:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  _ID (' .. type(self._ID) .. '): ' .. tostring(self._ID))
        XFG:Debug(ObjectName, '  _StreamID (' .. type(self._StreamID) .. '): ' .. tostring(self._StreamID))
        XFG:Debug(ObjectName, '  _Initials (' .. type(self._Initials) .. '): ' .. tostring(self._Initials))
        if(self:HasFaction()) then self:GetFaction():Print() end
        if(self:HasRealm()) then self:GetRealm():Print() end
    end
end

function Guild:GetInitials()
    return self._Initials
end

function Guild:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self._Initials = inInitials
end

function Guild:HasID()
    return self._ID ~= nil
end

function Guild:GetID()
    return self._ID
end

function Guild:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
end

function Guild:HasStreamID()
    return self._StreamID ~= nil
end

function Guild:GetStreamID()
    return self._StreamID
end

function Guild:SetStreamID(inStreamID)
    assert(type(inStreamID) == 'number')
    self._StreamID = inStreamID
end

function Guild:HasFaction()
    return self._Faction ~= nil
end

function Guild:GetFaction()
    return self._Faction
end

function Guild:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name ~= nil and inFaction.__name == 'Faction', 'argument must be Faction object')
    self._Faction = inFaction
end

function Guild:HasRealm()
    return self._Realm ~= nil
end

function Guild:GetRealm()
    return self._Realm
end

function Guild:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm', 'argument must be Realm object')
    self._Realm = inRealm
end