local XFG, G = unpack(select(2, ...))
local ObjectName = 'Guild'

Guild = Object:newChildConstructor()

--#region Constructors
function Guild:new()
    local object = Guild.parent.new(self)
    object.__name = ObjectName
    object.ID = nil        -- Only the player's guild will have an ID
    object.streamID = nil  -- Only the player's guild will have a StreamerID (this is gchat)
    object.initials = nil
    object.faction = nil
    object.realm = nil
    return object
end
--#endregion

--#region Print
function Guild:Print()
    if(XFG.Verbosity) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
        XFG:Debug(ObjectName, '  streamID (' .. type(self.streamID) .. '): ' .. tostring(self.streamID))
        XFG:Debug(ObjectName, '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
        if(self:HasFaction()) then self:GetFaction():Print() end
        if(self:HasRealm()) then self:GetRealm():Print() end
    end
end
--#endregion

--#region Accessors
function Guild:GetInitials()
    return self.initials
end

function Guild:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self.initials = inInitials
end

function Guild:HasID()
    return self.ID ~= nil
end

function Guild:GetID()
    return self.ID
end

function Guild:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Guild:HasStreamID()
    return self.streamID ~= nil
end

function Guild:GetStreamID()
    return self.streamID
end

function Guild:SetStreamID(inStreamID)
    assert(type(inStreamID) == 'number')
    self.streamID = inStreamID
end

function Guild:HasFaction()
    return self.faction ~= nil
end

function Guild:GetFaction()
    return self.faction
end

function Guild:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end

function Guild:HasRealm()
    return self.realm ~= nil
end

function Guild:GetRealm()
    return self.realm
end

function Guild:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
end
--#endregion