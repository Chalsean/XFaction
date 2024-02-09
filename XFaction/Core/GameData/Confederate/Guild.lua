local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Guild'
local GetClubMembers = C_Club.GetClubMembers

XFC.Guild = Object:newChildConstructor()

--#region Constructors
function XFC.Guild:new()
    local object = XFC.Guild.parent.new(self)
    object.__name = ObjectName
    object.streamID = nil  -- Only the player's guild will have a StreamerID (this is gchat)
    object.initials = nil
    object.faction = nil
    object.realm = nil
    return object
end
--#endregion

--#region Print
function XFC.Guild:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  streamID (' .. type(self.streamID) .. '): ' .. tostring(self.streamID))
    XF:Debug(ObjectName, '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
    if(self:HasFaction()) then self:GetFaction():Print() end
    if(self:HasRealm()) then self:GetRealm():Print() end
end

function XFC.Guild:PrintAudit()
    XF:Info('Audit', 'Name,Note,Rank,LastLoginDaysAgo')
    for _, memberID in pairs (GetClubMembers(XF.Player.Guild:GetID(), XF.Player.Guild:GetStreamID())) do
        local unit = Unit:new()
        unit:Initialize(memberID)
        if(unit:IsInitialized()) then
            XF:Info('Audit', '%s,%s,%s,%d', unit:GetName(), unit:GetNote(), unit:GetRank(), unit:GetLastLogin())
        end
    end
end
--#endregion

--#region Accessors
function XFC.Guild:GetInitials()
    return self.initials
end

function XFC.Guild:SetInitials(inInitials)
    assert(type(inInitials) == 'string')
    self.initials = inInitials
end

function XFC.Guild:HasStreamID()
    return self.streamID ~= nil
end

function XFC.Guild:GetStreamID()
    return self.streamID
end

function XFC.Guild:SetStreamID(inStreamID)
    assert(type(inStreamID) == 'number')
    self.streamID = inStreamID
end

function XFC.Guild:HasFaction()
    return self.faction ~= nil
end

function XFC.Guild:GetFaction()
    return self.faction
end

function XFC.Guild:SetFaction(inFaction)
    assert(type(inFaction) == 'table' and inFaction.__name == 'Faction', 'argument must be Faction object')
    self.faction = inFaction
end

function XFC.Guild:HasRealm()
    return self.realm ~= nil
end

function XFC.Guild:GetRealm()
    return self.realm
end

function XFC.Guild:SetRealm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm', 'argument must be Realm object')
    self.realm = inRealm
end
--#endregion